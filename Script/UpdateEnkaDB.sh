#!/bin/bash

rm -rf /var/tmp/temporaryJSON4Enka/ || true
mkdir /var/tmp/temporaryJSON4Enka/
git clone https://github.com/EnkaNetwork/API-docs.git /var/tmp/temporaryJSON4Enka/

cp /var/tmp/temporaryJSON4Enka/store/hsr/honker_avatars.json ./Packages/HBEnkaAPI/Sources/HBEnkaAPI/EnkaAssets/hsr_jsons/honker_avatars.json
cp /var/tmp/temporaryJSON4Enka/store/hsr/honker_characters.json ./Packages/HBEnkaAPI/Sources/HBEnkaAPI/EnkaAssets/hsr_jsons/honker_characters.json
cp /var/tmp/temporaryJSON4Enka/store/hsr/honker_meta.json ./Packages/HBEnkaAPI/Sources/HBEnkaAPI/EnkaAssets/hsr_jsons/honker_meta.json
cp /var/tmp/temporaryJSON4Enka/store/hsr/honker_ranks.json ./Packages/HBEnkaAPI/Sources/HBEnkaAPI/EnkaAssets/hsr_jsons/honker_ranks.json
cp /var/tmp/temporaryJSON4Enka/store/hsr/honker_relics.json ./Packages/HBEnkaAPI/Sources/HBEnkaAPI/EnkaAssets/hsr_jsons/honker_relics.json
cp /var/tmp/temporaryJSON4Enka/store/hsr/honker_skills.json ./Packages/HBEnkaAPI/Sources/HBEnkaAPI/EnkaAssets/hsr_jsons/honker_skills.json
cp /var/tmp/temporaryJSON4Enka/store/hsr/honker_skilltree.json ./Packages/HBEnkaAPI/Sources/HBEnkaAPI/EnkaAssets/hsr_jsons/honker_skilltree.json
cp /var/tmp/temporaryJSON4Enka/store/hsr/honker_weps.json ./Packages/HBEnkaAPI/Sources/HBEnkaAPI/EnkaAssets/hsr_jsons/honker_weps.json
cp /var/tmp/temporaryJSON4Enka/store/hsr/hsr.json ./Packages/HBEnkaAPI/Sources/HBEnkaAPI/EnkaAssets/hsr_jsons/hsr.json

rm -rf /var/tmp/temporaryJSON4Enka/

cd ./Packages/HBEnkaAPI/Sources/HBEnkaAPI/EnkaAssets/hsr_jsons/
ls

echo 'All tasks done.'
