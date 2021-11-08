#! /bin/sh

cd /src
./svc.sh stop
./svc.sh uninstall

su ubuntu -- ./config.sh remove --unattended --auth pat --token ${DEVOPS_ORG_TOKEN}