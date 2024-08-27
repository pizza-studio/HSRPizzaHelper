#!/bin/bash

rm -rf /var/tmp/temporaryJSON4Enka/ || true
mkdir /var/tmp/temporaryJSON4Enka/
git clone https://github.com/pizza-studio/EnkaDBGenerator.git /var/tmp/temporaryJSON4Enka/

cp /var/tmp/temporaryJSON4Enka/Sources/EnkaDBFiles/Resources/Specimen/HSR/honker_avatars.json ./Packages/EnkaKitHSR/Sources/EnkaKitHSR/EnkaAssets/hsr_jsons/honker_avatars.json
cp /var/tmp/temporaryJSON4Enka/Sources/EnkaDBFiles/Resources/Specimen/HSR/honker_characters.json ./Packages/EnkaKitHSR/Sources/EnkaKitHSR/EnkaAssets/hsr_jsons/honker_characters.json
cp /var/tmp/temporaryJSON4Enka/Sources/EnkaDBFiles/Resources/Specimen/HSR/honker_meta.json ./Packages/EnkaKitHSR/Sources/EnkaKitHSR/EnkaAssets/hsr_jsons/honker_meta.json
cp /var/tmp/temporaryJSON4Enka/Sources/EnkaDBFiles/Resources/Specimen/HSR/honker_ranks.json ./Packages/EnkaKitHSR/Sources/EnkaKitHSR/EnkaAssets/hsr_jsons/honker_ranks.json
cp /var/tmp/temporaryJSON4Enka/Sources/EnkaDBFiles/Resources/Specimen/HSR/honker_relics.json ./Packages/EnkaKitHSR/Sources/EnkaKitHSR/EnkaAssets/hsr_jsons/honker_relics.json
cp /var/tmp/temporaryJSON4Enka/Sources/EnkaDBFiles/Resources/Specimen/HSR/honker_skills.json ./Packages/EnkaKitHSR/Sources/EnkaKitHSR/EnkaAssets/hsr_jsons/honker_skills.json
cp /var/tmp/temporaryJSON4Enka/Sources/EnkaDBFiles/Resources/Specimen/HSR/honker_skilltree.json ./Packages/EnkaKitHSR/Sources/EnkaKitHSR/EnkaAssets/hsr_jsons/honker_skilltree.json
cp /var/tmp/temporaryJSON4Enka/Sources/EnkaDBFiles/Resources/Specimen/HSR/honker_weps.json ./Packages/EnkaKitHSR/Sources/EnkaKitHSR/EnkaAssets/hsr_jsons/honker_weps.json
cp /var/tmp/temporaryJSON4Enka/Sources/EnkaDBFiles/Resources/Specimen/HSR/hsr.json ./Packages/EnkaKitHSR/Sources/EnkaKitHSR/EnkaAssets/hsr_jsons/hsr.json

rm -rf /var/tmp/temporaryJSON4Enka/

cd ./Packages/EnkaKitHSR/Sources/EnkaKitHSR/EnkaAssets/hsr_jsons/
ls

echo 'All tasks done.'
