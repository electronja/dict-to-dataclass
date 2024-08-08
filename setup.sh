#!/usr/bin/env bash

python3 -m venv venv

source ./venv/bin/activate

venv/bin/pip install --upgrade pip
venv/bin/pip install wheel
venv/bin/pip install -r requirements.dev.txt  --upgrade

