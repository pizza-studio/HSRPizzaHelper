#!/bin/bash

rm -rf /var/tmp/temporaryJSON4SRS/ || true
mkdir /var/tmp/temporaryJSON4SRS/
git clone https://github.com/Mar-7th/StarRailScore.git /var/tmp/temporaryJSON4SRS/

cp /var/tmp/temporaryJSON4SRS/score.json ./Packages/EnkaKitHSR/Sources/EnkaKitHSR/EnkaAssets/StarRailScore.json

rm -rf /var/tmp/temporaryJSON4SRS/

cd ./Packages/EnkaKitHSR/Sources/EnkaKitHSR/EnkaAssets/hsr_jsons/
ls

echo 'All tasks done.'
