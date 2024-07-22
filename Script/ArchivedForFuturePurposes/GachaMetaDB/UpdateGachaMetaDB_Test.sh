#!/bin/bash

rm -rf ./GachaMetaDB_GeneratedSpecimen_HSRv23.json || true

swift ./HSRGachaMetaHashDBGenerator.swift > ./GachaMetaDB_GeneratedSpecimen_HSRv23.json

echo 'All tasks done.'
