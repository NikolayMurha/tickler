x``#!/usr/bin/env bash
BASEDIR=$(dirname "$0")
python3 ${BASEDIR}/inventory.py --state=${BASEDIR}/../terraform/ $@
