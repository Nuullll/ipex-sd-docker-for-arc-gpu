import argparse
import logging
import os
from pathlib import Path
import shutil
import sys
from subprocess import Popen, PIPE

cwd = os.path.dirname(os.path.abspath(sys.argv[0]))

logging.basicConfig(format='%(asctime)s %(message)s', level=logging.DEBUG)

parser = argparse.ArgumentParser(description='Packaing script for Arc-SDNext-Installer')
parser.add_argument('output_dir', help='Directory to store the packaged artifacts')
parser.add_argument('--version', type=str, required=True, help='Version of packaged installer: <major>.<minor>.<patch>')
parser.add_argument('--stage', nargs='*', help='Packaging stages: image | volume | webui | strip | all')
parser.add_argument('--webui-dir', help='The web ui directory')

args = parser.parse_args()

def get_image_version():
    major, minor, _ = args.version.split('.')
    return f"{major}.{minor}"

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
    image_name = f'nuullll/ipex-arc-sd:v{get_image_version()}'
    logging.info(f'Exporting image {image_name} to {output_file}')

    run(['docker', 'save', '--output', output_file, image_name])

def export_volumes():
    logging.info(f'Exporting volumes')
    run(['docker', 'pull', 'ubuntu'])
    run(['docker', 'run', '--rm', '-v', f'deps-{get_image_version()}:/deps', '-v', f'{args.output_dir}:/backup', 'ubuntu', 'tar', 'cvf', '/backup/volume-deps.tar', '/deps'])
    run(['docker', 'run', '--rm', '-v', 'huggingface:/root/.cache/huggingface', '-v', f'{args.output_dir}:/backup', 'ubuntu', 'tar', 'cvf', '/backup/volume-huggingface.tar', '/root/.cache/huggingface'])

def copy_webui():
    dst = os.path.join(args.output_dir, 'webui')
    logging.info(f'Copying {args.webui_dir} to {dst}')
    shutil.copytree(args.webui_dir, dst)

def get_dir_size(dir):
    return sum(f.stat().st_size for f in Path(dir).glob('**/*') if f.is_file()) / (1024*1024*1024)

def copy_install_script():
    src = os.path.join(cwd, 'install.bat')
    dst = os.path.join(args.output_dir, 'install.bat')
    shutil.copy2(src, dst)
    with open(dst, 'r', encoding='utf-8') as f:
        s = f.read()
    s = s.replace('%%IMAGE_VER%%', get_image_version())
    with open(dst, 'w', encoding='utf-8') as f:
        f.write(s)

    src = os.path.join(cwd, '使用说明.txt')
    dst = os.path.join(args.output_dir, '使用说明.txt')
    shutil.copy2(src, dst)

if __name__ == '__main__':
    major, minor, patch = args.version.split('.')
    os.makedirs(args.output_dir, exist_ok=True)

    stages = args.stage
    if 'image' in stages or 'all' in stages:
        export_image()

    if 'webui' in stages or 'all' in stages:
        copy_webui()

    if 'volume' in stages or 'all' in stages:
        export_volumes()

    if 'final' in stages or 'all' in stages:
        copy_install_script()
