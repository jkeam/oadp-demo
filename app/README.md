## OpenShift

```shell
oc new-project jon

oc apply -f ./db.yaml
oc apply -f ./app.yaml

# migrate
oc exec pods/$(oc get pods | grep Running  | grep djangotodos | awk '{print $1}') -- python ./manage.py migrate

# create user
oc exec pods/$(oc get pods | grep Running  | grep djangotodos | awk '{print $1}') -- bash -c "DJANGO_SUPERUSER_PASSWORD=Rj2nia9S6s9i python3 manage.py createsuperuser --username admin --email admin@example.com --noinput"

# csrf
oc set env deployments/djangotodos ALLOWED_HOSTS=$(oc get routes | grep djangotodos | awk '{print $2}')

# get route
echo "https://$(oc get routes/djangotodos -o jsonpath='{.spec.host}')"
```
