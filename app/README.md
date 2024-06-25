## OpenShift

## Setup

```shell
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

```shell
oc apply -f ./backup.yaml
```

Then see the resources in AWS S3 bucket


## Destroy
oc delete project jon

Reload URL and see app is dead.


## Restore
oc apply -f ./restore.yaml

Watch resources in operator, wait for restore to finish.

Then look at pods in `jon` namespace.

Then reload the app and see the data is back.



## Cleanup

```shell
oc delete backups/backup1 -n openshift-adp
oc delete $(oc get backuprepository -n openshift-adp -o name) -n openshift-adp
oc delete restores/restore1 -n openshift-adp
# delete objects from s3
```
