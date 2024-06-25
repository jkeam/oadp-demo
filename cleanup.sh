#!/bin/bash

oc delete backups/backup1 -n openshift-adp
oc delete $(oc get backuprepository -n openshift-adp -o name) -n openshift-adp
oc delete restores/restore1 -n openshift-adp
