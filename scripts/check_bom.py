import logging
import argparse
import os
import shutil
import sys
import glob
import json

cwd = os.path.dirname(os.path.abspath(sys.argv[0]))

logging.basicConfig(format='%(asctime)s %(message)s', level=logging.DEBUG)

parser = argparse.ArgumentParser(description='Export BOM file for Arc-SDNext-Installer')
parser.add_argument('repo_dir', help='SD.Next directory')

args = parser.parse_args()

def check_must_have_files():
    glob_file = os.path.join(cwd, 'BOM/pos.glob')
    with open(glob_file, 'r') as f:
        lines = f.readlines()
    ok = True
    for line in lines:
        line = line.strip()
        if line and not line.startswith('#'):
            fields = line.split()
            count = 1 if len(fields) == 1 else int(fields[1])
            files = glob.glob(fields[0], root_dir=args.repo_dir)
            if len(files) != count:
                logging.error(f"Expect {count} files: {fields[0]}, got {len(files)}")
                ok = False
    return ok

def check_must_not_have_files(auto_remove=False):
    glob_file = os.path.join(cwd, 'BOM/neg.glob')
    with open(glob_file, 'r') as f:
        lines = f.readlines()
    ok = True
    for line in lines:
        line = line.strip()
        if line and not line.startswith('#'):
            files = glob.glob(line, root_dir=args.repo_dir)
            if len(files):
                logging.error(f"Don't expect file: {line} -> {files}")
                if auto_remove:
                    for f in files:
                        p = os.path.join(args.repo_dir, f)
                        if os.path.isdir(p):
                            shutil.rmtree(p)
                        else:
                            os.remove(p)
                    logging.info(f"Auto removed!")
                ok = False
    return ok

def check_config():
    config_file = os.path.join(args.repo_dir, 'config.json')
    with open(config_file, 'r') as f:
        config = json.load(f)
    ok = True
    if "sd_vae" not in config["quicksettings_list"]:
        logging.error("sd_vae not in quicksettings")
        ok = False
    if "sd_model_refiner" not in config["quicksettings_list"]:
        logging.error("sd_model_refiner not in quicksettings")
        ok = False
    if "Euler" not in config["show_samplers"]:
        logging.error("Euler not in show_samplers")
        ok = False
    if config["gradio_theme"] != "gradio/default":
        logging.error("gradio_theme is not gradio/default")
        ok = False
    if config["bilingual_localization_file"] != "I18N_sd-webui-zh_CN":
        logging.error("bilingual_localization_file is not I18N_sd-webui-zh_CN")
        ok = False
    if "sd_model_checkpoint" in config or "sd_checkpoint_hash" in config:
        logging.error("Default model not removed")
        ok = False
    return ok

def check_webui_user():
    user_sh = os.path.join(args.repo_dir, 'webui-user.sh')
    with open(user_sh, 'r') as f:
        lines = f.readlines()
    for line in lines:
        line = line.strip()
        if line and not line.startswith('#'):
            if line.startswith('export COMMANDLINE_ARGS='):
                expected_options = ['--skip-git', '--no-download', '--ad-no-huggingface']
                for opt in expected_options:
                    if opt not in line:
                        logging.error(f"Missing preset COMMANDLINE_ARGS: {opt}")
                        return False
                return True
    return False

if __name__ == '__main__':
    check_must_have_files()
    check_must_not_have_files(auto_remove=True)
    check_config()
    check_webui_user()
