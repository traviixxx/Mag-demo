#!/bin/bash

## author: <sebastian.klingberg@magnolia-cms.com>
## Magnolia International Ltd.

export RELEASE_DEFAULT="dev"
export BACKUP_KEY="${RELEASE_DEFAULT}-s3-backup-key"
export BACKUP_KEY_TMP="s3-backup-key.yaml.tmp"

#set -x

echo "
## Migrate s3-backup-secret from Helm Installation ##

Set target Release with:
\$ export RELEASE="mynamespace"

"
# Check vor RELEASE Env
if [ -z $RELEASE ]; then
    echo "> 'RELEASE' Env not defined, use default \$RELEASE --> '${RELEASE_DEFAULT}'"
    RELEASE=$RELEASE_DEFAULT
    echo "> If required, overwrite with 'export RELEASE="myrelease"'"
else
    echo "> Set 'RELEASE' Env set to ${RELEASE}"

fi

# Check for NAMESPACE ENV
if [ -z $NAMESPACE ]; then
    echo "> 'NAMESPACE' Env not defined, set K8s Namespace equal to \$RELEASE --> '${RELEASE}'"
    NAMESPACE=$RELEASE
    echo "> If required, overwrite with 'export NAMESPACE="mynamespace"'"
fi

# Set requested Backup Secret Key
BACKUP_KEY="${RELEASE}-s3-backup-key"
echo "> Set Backupkey to '${BACKUP_KEY}'"

# Check Kubectl connection
echo -n "> Checking Cluster connection ... "
kubectl get secret -n $NAMESPACE $BACKUP_KEY >>/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -n "working"
else
    echo -n "Secret '${BACKUP_KEY}' not found or kubectl connection not working. "
    echo "Check if the cluster communication via Kubectl is working!"
    exit 1
fi

# Control Check
echo "
Namespace   = ${NAMESPACE}
Migrate Key = ${BACKUP_KEY}

Press 'y' if you agree to proceed on migrating this secret
"
read agreed
if ! [ $agreed == 'y' ]; then
    echo "Exit"
    exit 1
fi

# Backup Key
echo "> Back up '${BACKUP_KEY}' to './${BACKUP_KEY_TMP}'"
kubectl get secret -n $NAMESPACE $BACKUP_KEY -o yaml >$BACKUP_KEY_TMP
# delete key
echo "> Delete '${BACKUP_KEY}'"
kubectl delete secret -n $NAMESPACE $BACKUP_KEY
# Apply Kustomize
echo "> Remove Helm References from '${BACKUP_KEY}' (if any) and recreate (find copy @ './${BACKUP_KEY}_new.yaml.tmp')"
kubectl create -k . -o yaml --dry-run=client | tee ${BACKUP_KEY}_new.yaml.tmp | kubectl create -f -
# Final check
echo "> Check Result for '${BACKUP_KEY}' on Cluster"
kubectl get secret -n $NAMESPACE $BACKUP_KEY -o yaml

# Done
echo "Done"
exit 0
