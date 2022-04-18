#!/bin/bash

SPLUNK_ETC_DIR="/opt/splunk/etc/deployment-apps"
SPLUNK_DEPLOYS_DIR="/opt/splunk_deploys"
SPLUNK_SEVERCLASS_DIR="/opt/splunk/etc/system/local"
NEW_DEPLOY_DIR="$SPLUNK_DEPLOYS_DIR/$(date +%Y%m%d%H%M%S)"
OLD_DIRECTORIES_TO_PRESERVE=5

# exit if SPLUNK_ETC_DIR is not a symlink
if [ ! -L $SPLUNK_ETC_DIR ]; then
  echo "SPLUNK_ETC_DIR is not a symlink. Exiting."
  exit 1
fi

# exit if SPLUNK_SERVERCLASS_DIR/serverclass.conf is not a symlink
if [ ! -L $SPLUNK_SEVERCLASS_DIR/serverclass.conf ]; then
  echo "$SPLUNK_SEVERCLASS_DIR/serverclass.conf is not a symlink. Exiting."
  exit 1
fi

# create SPLUNK_DEPLOYS_DIR if it doesn't exist
if [ ! -d "$SPLUNK_DEPLOYS_DIR" ]; then
  mkdir -p "$SPLUNK_DEPLOYS_DIR"
fi

# create new deploy directory
mkdir -p "$NEW_DEPLOY_DIR"

# copy content of apps/ to new deploy directory
cp -r apps/* $NEW_DEPLOY_DIR

# symlink new deploy directory to SPLUNK_ETC_DIR
ln -nsf $NEW_DEPLOY_DIR $SPLUNK_ETC_DIR
ln -nsf $NEW_DEPLOY_DIR/serverclass.conf $SPLUNK_SEVERCLASS_DIR/serverclass.conf

# chown SPLUNK_DEPLOYS_DIR and SPLUNK_ETC_DIR
chown -R splunk:splunk $SPLUNK_DEPLOYS_DIR
chown -R splunk:splunk $SPLUNK_ETC_DIR
chown -R splunk:splunk $SPLUNK_SEVERCLASS_DIR

# delete all but the last $OLD_DIRECTORIES_TO_PRESERVER directories in SPLUNK_DEPLOYS_DIR
ls -dt $SPLUNK_DEPLOYS_DIR/* | tail -n +$(($OLD_DIRECTORIES_TO_PRESERVE + 1)) | xargs rm -rf