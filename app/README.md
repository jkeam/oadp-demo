## Demo Script

## Setup

```shell
# deploy everything
oc new-project jon
oc apply -f ./db.yaml
oc apply -f ./app.yaml

# migrate
oc exec pods/$(oc get pods | grep Running  | grep djangotodos | awk '{print $1}') -- python ./manage.py migrate

# create user
oc exec pods/$(oc get pods | grep Running  | grep djangotodos | awk '{print $1}') -- bash -c "DJANGO_SUPERUSER_PASSWORD=Rj2nia9S6s9i python3 manage.py createsuperuser --username admin --email admin@example.com --noinput"

# csrf
oc set env deployments/djangotodos CSRF_TRUSTED_ORIGINS=$(oc get routes | grep djangotodos | awk '{print $2}')

# get route
echo "https://$(oc get routes/djangotodos -o jsonpath='{.spec.host}')"
```

## Backup

1. Request Backup

  ```shell
  oc apply -f ./backup.yaml
  ```

2. See the resources in AWS S3 bucket

## Destroy

1. Destroy the app

  ```shell
  oc delete project jon
  ```

2. Reload URL and see app is dead

## Restore

1. Request restore
  ```shell
  oc apply -f ./restore.yaml
  ```

2. Watch resources in operator, wait for restore to finish

3. Then look at pods in `jon` namespace

4. Then reload the app and see the data is back

## Cleanup

```shell
./setup/cleanup.sh
```
