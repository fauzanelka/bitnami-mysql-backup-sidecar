# bitnami-mysql-backup-sidecar

Bitnami MySQL Backup sidecar with backup plans
- [x] Daily backup with 7 days retention
- [x] Monthly backup with 365 days retention

## Showcase

- [ ] Adjust [crontab/root](crontab/root) according to your needs (i.e. every 10 minutes)
- [ ] Adjust [kustomize/demo/secret/bitnami-mysql-backup-sidecar.yaml](kustomize/demo/secret/bitnami-mysql-backup-sidecar.yaml) according to your needs.
- [ ] Build the image from source, push to your registry provider.
- [ ] Apply 
  
  ```yaml
  kubectl apply -k kustomize/demo
  ```

## Build image from source

With Docker

```bash
docker build -t fauzanelka/bitnami-mysql-backup-sidecar:latest .
```

## Usage

Create environment variables secret with the reference below

```yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: mysql-backup-env
stringData:
  CRON_TZ: America/New_York
  MYSQL_HOST: localhost
  MYSQL_DATABASE: test
  MYSQL_USER: root
  MYSQL_PASSWORD: root
  DAILY_BACKUP_DIR: /mnt/backup-daily
  MONTHLY_BACKUP_DIR: /mnt/backup-monthly
  RCLONE_S3_PROVIDER: AWS
  RCLONE_S3_ACCESS_KEY_ID: 
  RCLONE_S3_SECRET_ACCESS_KEY: 
  RCLONE_S3_REGION: us-east-1
  RCLONE_S3_ENDPOINT: s3.us-east-1.amazonaws.com
  RCLONE_S3_BUCKET_DAILY: test-bucket
  RCLONE_S3_BUCKET_MONTHLY: test-bucket
```

Apply

```bash
kubectl apply -f mysql-backup-env.yaml
```

Create two persistent volume claim for daily and monthly backup storage with the reference below

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-backup-daily
spec:
  resources:
    requests:
      storage: 8Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-backup-monthly
spec:
  resources:
    requests:
      storage: 8Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
```

Apply

```bash
kubectl apply -f mysql-backup-daily.yaml
kubectl apply -f mysql-backup-monthly.yaml
```

Get bitnami/mysql current release values and output to yaml file

```bash
helm -n <namespace> get values <release> -oyaml > current-release-values.yaml
```

Append extraVolumes and sidecars with the reference below

```yaml
...
primary:
  extraVolumes:
    - name: backup-daily
      persistentVolumeClaim:
        claimName: mysql-backup-daily
    - name: backup-monthly
      persistentVolumeClaim:
        claimName: mysql-backup-monthly
  sidecars:
    - name: mysql-backup
      image: ghcr.io/fauzanelka/bitnami-mysql-backup-sidecar:1@sha256:5fc006759de222f01e432df3035f858a11ea1abe3e907fee53dc920b49aa1bfb
      imagePullPolicy: Always
      envFrom:
        - secretRef:
            name: mysql-backup-env
      volumeMounts:
        - mountPath: /mnt/backup-daily
          name: backup-daily
        - mountPath: /mnt/backup-monthly
          name: backup-monthly
...
```

Apply

```bash
helm -n <namespace> upgrade -f current-release-values.yaml --version <chart-version> <release> bitnami/mysql
```