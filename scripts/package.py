import argparse
import logging
import os
from pathlib import Path
import requests
import shutil
from subprocess import Popen, PIPE

logging.basicConfig(format='%(asctime)s %(message)s', level=logging.DEBUG)

parser = argparse.ArgumentParser(description='Packaing script for Arc-SDNext-Installer')
parser.add_argument('output_dir', help='Directory to store the packaged artifacts')
parser.add_argument('--version', type=str, required=True, help='Version of packaged installer: <major>.<minor>.<patch>')
parser.add_argument('--stage', nargs='*', help='Packaging stages: image | volume | webui | strip | all')
parser.add_argument('--container', type=str, default='sd-server-package', help='The docker contaier name for packaging')
parser.add_argument('--webui-dir', help='The web ui directory')
parser.add_argument('--webui-dir-with-models', help='The opinionated web ui directory where models are available')

args = parser.parse_args()

MANUAL_CHECKS = [
    'localization file',
    'UI vae',
    'UI theme',
    'image process exact steps',
]

def run(cmd):
    with Popen(cmd, stdout=PIPE, stderr=PIPE) as p:
        o = p.stdout.read().decode('utf-8').strip()
        e = p.stderr.read().decode('utf-8').strip()
        if o:
            logging.info(o)
        if e:
            logging.error(e)
    
    if p.returncode != 0:
        raise Exception(f"Failed to run {' '.join(cmd)}")

def export_image():
    output_file = os.path.join(args.output_dir, 'image.tar')
    image_name = 'nuullll/ipex-arc-sd:latest'
    logging.info(f'Exporting image {image_name} to {output_file}')

    run(['docker', 'save', '--output', output_file, image_name])

def export_volumes():
    logging.info(f'Exporting volumes')
    run(['docker', 'pull', 'ubuntu'])
    run(['docker', 'run', '--rm', '-v', 'deps:/deps', '-v', f'{args.output_dir}:/backup', 'ubuntu', 'tar', 'cvf', '/backup/volume-deps.tar', '/deps'])
    run(['docker', 'run', '--rm', '-v', 'huggingface:/root/.cache/huggingface', '-v', f'{args.output_dir}:/backup', 'ubuntu', 'tar', 'cvf', '/backup/volume-huggingface.tar', '/root/.cache/huggingface'])

def launch_fresh_webui():
    logging.info(f'Setting up a fresh Web UI container (temporary)')
    run(['docker', 'run', '-d',
         '--device', '/dev/dxg',
         '-v', '/usr/lib/wsl:/usr/lib/wsl',
         '-v', f'{args.webui_dir}:/sd-webui',
         '-v', 'deps:/deps',
         '-v', 'huggingface:/root/.cache/huggingface',
         '-p', '7866:7860',
         '--rm',
         'nuullll/ipex-arc-sd:latest',
         '--upgrade', '--no-download'])
    input('Press Enter to continue when Web UI is ready ...')
    
def copy_fresh_webui():
    dst = os.path.join(args.output_dir, 'webui')
    logging.info(f'Copying {args.webui_dir} to {dst}')
    shutil.copytree(args.webui_dir, dst, ignore=shutil.ignore_patterns('sdnext.log', 'outputs/**/*'))

def install_plugins_to(webui_dir):
    modified_dirs = []
    def new_dir(dir_name):
        full_path = os.path.join(webui_dir, dir_name)
        os.makedirs(full_path, exist_ok=True)
        modified_dirs.append(full_path)
        return full_path
    # bilingual localizations
    ## download localization file
    r = requests.get('https://gist.githubusercontent.com/journey-ad/d98ed173321658be6e51f752d6e6163c/raw/aa162c81d9d7d7b6efdffa84ccbfe867be6b711d/I18N_sd-webui-zh_CN.json')
    locale_dir = new_dir('localizations')
    with open(os.path.join(locale_dir, 'I18N_sd-webui-zh_CN.json'), 'wb') as f:
        f.write(r.content)

    ext_dir = new_dir('extensions')
    def add_extension(git_url):
        ext_name = git_url.split('/')[-1][:-4]
        logging.info(f"Cloning extension {ext_name} from {git_url}")
        run(['git', 'clone', git_url, os.path.join(ext_dir, ext_name)])
    # custom extensions
    add_extension('https://github.com/journey-ad/sd-webui-bilingual-localization.git')
    add_extension('https://github.com/DominikDoom/a1111-sd-webui-tagcomplete.git')
    add_extension('https://github.com/Physton/sd-webui-prompt-all-in-one.git')
    add_extension('https://github.com/Coyote-A/ultimate-upscale-for-automatic1111.git')
    add_extension('https://github.com/Bing-su/adetailer.git')

    return modified_dirs

def copy_plugins():
    par_dir = os.path.dirname(args.webui_dir)
    basename = os.path.basename(args.webui_dir)
    ws = os.path.join(par_dir, basename + '-plugins')
    if not os.path.exists(ws):
        logging.info(f'Making a copy of fresh Web UI for plugin installation...')
        fresh_webui = os.path.join(args.output_dir, 'webui')
        shutil.copytree(fresh_webui, ws)
    
    modified_dirs = install_plugins_to(ws)
    for d in modified_dirs:
        rel_path = os.path.relpath(d, ws)
        shutil.copytree(d, os.path.join(args.output_dir, 'webui-plugins', rel_path))

def get_dir_size(dir):
    return sum(f.stat().st_size for f in Path(dir).glob('**/*') if f.is_file()) / (1024*1024*1024)

def copy_models():
    # models
    model_dir = os.path.join(args.webui_dir_with_models, 'models')
    exclude_dirs = ['Lora', 'LyCORIS', 'embeddings', 'Stable-diffusion']
    basic_model_output = os.path.join(args.output_dir, 'webui-models')
    shutil.copytree(model_dir, os.path.join(basic_model_output, 'models'), ignore=shutil.ignore_patterns(*exclude_dirs))
    logging.info(f"Copied basic models: {get_dir_size(basic_model_output)} GB")

    # extra large models
    extra_model_output = os.path.join(args.output_dir, 'webui-extra-models')
    ## one SD model
    model_name = 'majicmixRealistic_betterV2V25.safetensors'
    dst = os.path.join(extra_model_output, 'models', 'Stable-diffusion', model_name)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(os.path.join(model_dir, 'Stable-diffusion', model_name), dst)
    ## ControlNet preprocessors
    annotator_path = ['extensions-builtin', 'sd-webui-controlnet', 'annotator', 'downloads']
    cn_annotator_dir = os.path.join(args.webui_dir_with_models, *annotator_path)
    shutil.copytree(cn_annotator_dir, os.path.join(extra_model_output, *annotator_path))
    ## ControlNet models
    cn_model_path = ['extensions-builtin', 'sd-webui-controlnet', 'models']
    shutil.copytree(os.path.join(args.webui_dir_with_models, *cn_model_path), os.path.join(extra_model_output, *cn_model_path))
    logging.info(f"Copied extra models: {get_dir_size(extra_model_output)} GB")

def manual_check():
    par_dir = os.path.dirname(args.webui_dir)
    basename = os.path.basename(args.webui_dir)
    ws = os.path.join(par_dir, basename + '-plugins')
    run(['docker', 'run', '-d',
         '--device', '/dev/dxg',
         '-v', '/usr/lib/wsl:/usr/lib/wsl',
         '-v', f'{ws}:/sd-webui',
         '-v', 'deps:/deps',
         '-v', 'huggingface:/root/.cache/huggingface',
         '-p', '7866:7860',
         '--rm',
         'nuullll/ipex-arc-sd:latest',
         '--insecure', '--skip-git', '--no-download'])
    for item in MANUAL_CHECKS:
        input(f"Check item {item}")

    input("All done! Save edits then press ENTER")
    
    dst_config = os.path.join(args.output_dir, 'webui', 'config.json')
    if os.path.exists(dst_config):
        os.remove(dst_config)
    shutil.copy2(os.path.join(ws, 'config.json'), dst_config)
    logging.info(f"{dst_config} updated!")

if __name__ == '__main__':
    major, minor, patch = args.version.split('.')
    os.makedirs(args.output_dir, exist_ok=True)

    stages = args.stage
    if 'image' in stages or 'all' in stages:
        export_image()

    if 'setup-fresh' in stages or 'all' in stages:
        launch_fresh_webui()

    if 'webui' in stages or 'all' in stages:
        copy_fresh_webui()

    if 'webui-plugins' in stages or 'all' in stages:
        copy_plugins()

    if 'webui-models' in stages or 'all' in stages:
        copy_models()

    if 'manual-check' in stages or 'all' in stages:
        manual_check()

    if 'volume' in stages or 'all' in stages:
        export_volumes()
