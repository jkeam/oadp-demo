# OADP README

## Prerequisite
1. OCP 4.15+
2. Logged in as cluster-admin
3. OADP Operator installed into openshift-adp
4. Something running in the `jon` namespace that we can backup

## Setup

1. Create S3 bucket

  ```shell
  aws s3api create-bucket \
    --bucket jkeam-oadp-demo \
    --region us-east-2 \
    --create-bucket-configuration LocationConstraint=us-east-2
  ```

2. Create User

  ```shell
  # create user
  aws iam create-user --user-name velero

  # attach policy
  aws iam put-user-policy \
  --user-name velero \
  --policy-name velero \
  --policy-document file://velero-policy.json

  # create access key
  aws iam create-access-key --user-name velero
  ```

3. Create secret

  ```shell
  oc create secret generic cloud-credentials -n openshift-adp --from-file cloud=credentials-velero

  # check
  # oc get secrets/cloud-credentials
  ```

2. Create DataProtectionApplication

  ```shell
  oc create -f ./dpa.yaml

  # check on status
  oc get dpa dpa -n openshift-adp -o jsonpath='{.status}'

  # check for backupstoragelocation
  oc get backupStorageLocations -n openshift-adp
  ```

3. Set CSI Snapshot

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

1. Create Backup

  ```shell
  oc apply -f ./backup.yaml

  # get status
  oc get backup backup1 -n openshift-adp -o jsonpath='{.status.phase}'
  ```

2. Destroying

  ```shell
  oc delete -f ./app/db.yaml
  oc delete all -l app=djangotodos
  oc delete namespace jon
  ```

3. Restoring

  ```shell
  oc apply -f ./restore.yaml

  # get status
  oc get restore restore1 -n openshift-adp -o jsonpath='{.status.phase}'
  ```
