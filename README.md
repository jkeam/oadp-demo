# OADP

This is a demo of the OADP functionality.

## Prerequisite

1. OCP 4.15+
2. Logged in as cluster-admin
3. OADP Operator installed into openshift-adp
4. Something running in the `jon` namespace that we can backup
5. AWS CLI installed and logged in using `velero` profile

## Setup

1. Create S3 bucket

  ```shell
  aws s3api create-bucket \
    --bucket jkeam-oadp-demo \
    --region us-east-2 \
    --create-bucket-configuration LocationConstraint=us-east-2 \
    --profile velero
  ```

2. Create User

  ```shell
  # create user
  aws iam create-user --user-name velero --profile velero

  # attach policy
  aws iam put-user-policy \
  --user-name velero \
  --policy-name velero \
  --policy-document file://velero-policy.json \
  --profile velero

  # create access key and put into file named credentials-velero
  aws iam create-access-key --user-name velero --profile velero
  # example credentials-velero file:
  # [default]
  # aws_access_key_id=ASIAIOSFODNN7EXAMPLE
  # aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
  ```

3. Create secret from `credentials-velero` file above

  ```shell
  oc create secret generic cloud-credentials -n openshift-adp --from-file cloud=credentials-velero

  # check
  # oc get secrets/cloud-credentials -n openshift-adp
  ```

2. Create DataProtectionApplication

  ```shell
  oc create -f ./setup/dpa.yaml

  # check on status
  oc get dpa dpa -n openshift-adp -o jsonpath='{.status}'

  # check for backupstoragelocation
  oc get backupStorageLocations -n openshift-adp
  ```

3. Configure VolumeSnapshotClass for use with Velero

  ```yaml
  deletionPolicy: Retain
  metadata:
    labels:
      velero.io/csi-volumesnapshot-class: "true" 
    annotations:
      snapshot.storage.kubernetes.io/is-default-class: "true"
  ```

  ```shell
  oc edit VolumeSnapshotClass ocs-external-storagecluster-rbdplugin-snapclass
  ```

## Running

1. Create Backup (assuming app is running)

  ```shell
  oc apply -f ./backup.yaml

  # get status
  oc get backup backup1 -n openshift-adp -o jsonpath='{.status.phase}'
  ```

2. Destroying

  ```shell
  oc delete namespace jon
  ```

3. Restoring

  ```shell
  oc apply -f ./restore.yaml

  # get status
  oc get restore restore1 -n openshift-adp -o jsonpath='{.status.phase}'
  ```

## Cleanup

```shell
./setup/cleanup.sh
```
