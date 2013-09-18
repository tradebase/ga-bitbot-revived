#!/bin/bash

for i in `ps auxw|grep -i screen|grep -v grep | awk '{print $13}'` ; do screen -p 0 -S $i -X eval 'stuff ' ; sleep 1 ; screen -p 0 -S $i -X eval 'stuff \"exit\"\015' ; sleep 1 ; done
