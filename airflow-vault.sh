cat << EOF > airflow-vault.py

import logging
import hvac
import os
import sys
import json
import subprocess


sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

logging.basicConfig(level=logging.INFO)

# Set parameters
client = hvac.Client(url=os.environ.get("VAULT_ADDR", "https://vault.local.host"),
                     token=os.environ.get("VAULT_TOKEN", "hvs.123"))
mount_point = os.environ.get("VAULT_MOUNT_POINT", "APPS/")
secrets_path = os.environ.get("VAULT_PATH", "airflow")


def get_vault_secrets(mount_point, secrets_path):
    """Get secrets from vault"""
    try:
        value = client.secrets.kv.v2.read_secret_version(mount_point=mount_point, path=secrets_path)
        for data in value['data']['data']:
            logging.info("Find secret: " + data)
        return value['data']['data']
    except hvac.exceptions.VaultError as e:
        print(e)


def create_vault_secrets(path, value):
    try:
        client.secrets.kv.v2.create_or_update_secret(
            mount_point=mount_point,
            path=path,
            secret=value
        )
    except hvac.exceptions.VaultError as e:
        print(e)


subprocess.run('airflow connections export --file-format json connections.json', shell=True)
subprocess.run('airflow variables export variables.json', shell=True)


with open('connections.json') as json_file:
   data = json.load(json_file)
   path = secrets_path + "/connections/"
   for s, v in data.items():
       create_vault_secrets(path+s, v)

with open('variables.json') as json_file:
    data = json.load(json_file)
    path = secrets_path + "/variables/"
    for s, v in data.items():
        value = {'value': v}
        create_vault_secrets(path + s, value)


EOF