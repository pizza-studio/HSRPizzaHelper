#!/bin/bash

rm -rf ./Packages/GachaKitHSR/Sources/GachaKitHSR/Assets/GachaMetaDB.json || true

swift ./Script/HSRGachaMetaHashDBGenerator.swift > ./Packages/GachaKitHSR/Sources/GachaKitHSR/Assets/GachaMetaDB.json

echo 'All tasks done.'
