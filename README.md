# Airflow migrations variables and connection vault

## Окружение
```bash
export VAULT_ADDR=https://vault.local.host
export VAULT_TOKEN=hvs.123
export VAULT_MOUNT_POINT=APPS/
export VAULT_PATH=airflow
```

Скрипт перенесет все переменные и коннекторы в vault.
Запускать в среде airflow

```bash

python airflow-vault.py
```
airflow.cfg
```yaml
    - name: AIRFLOW__SECRETS__BACKEND
      value: airflow.providers.hashicorp.secrets.vault.VaultBackend
    - name: AIRFLOW__SECRETS__BACKEND_KWARGS
      value: '{"connections_path": "airflow/connections/", "variables_path": "airflow/variables", "token": "hvs.123", "mount_point": "APPS", "url": "https://vault.local.host", "kv_engine_version" : 2  }'
```

Проверка доступности секретов из vault

```bash
airflow connections get smtp_default
airflow variables get test
```