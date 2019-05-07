#!/bin/bash

HYSDS_DIR=<%= @hysds_dir %>


# create virtualenv if not found
if [ ! -e "$HYSDS_DIR/bin/activate" ]; then
  /opt/conda/bin/virtualenv --system-site-packages $HYSDS_DIR
  echo "Created virtualenv at $HYSDS_DIR."
fi


# source virtualenv
source $HYSDS_DIR/bin/activate


# install latest pip and setuptools
pip install -U pip
pip install -U setuptools


# create etc directory
if [ ! -d "$HYSDS_DIR/etc" ]; then
  mkdir $HYSDS_DIR/etc
fi


# create log directory
if [ ! -d "$HYSDS_DIR/log" ]; then
  mkdir $HYSDS_DIR/log
fi


# create run directory
if [ ! -d "$HYSDS_DIR/run" ]; then
  mkdir $HYSDS_DIR/run
fi


# set oauth token
OAUTH_CFG="$HOME/.git_oauth_token"
if [ -e "$OAUTH_CFG" ]; then
  source $OAUTH_CFG
  GIT_URL="https://${GIT_OAUTH_TOKEN}@github.com"
else
  GIT_URL="https://github.com"
fi


# create ops directory
OPS="$HYSDS_DIR/ops"
if [ ! -d "$OPS" ]; then
  mkdir $OPS
fi


# export latest sdscli package
cd $OPS
PACKAGE=sdscli
if [ ! -d "$OPS/$PACKAGE" ]; then
  git clone ${GIT_URL}/sdskit/${PACKAGE}.git
fi
cd $OPS/$PACKAGE
pip install -e .
if [ "$?" -ne 0 ]; then
  echo "Failed to run 'pip install -e .' for $PACKAGE."
  exit 1
fi
