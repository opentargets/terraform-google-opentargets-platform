#!/bin/bash
cd /src
echo "[FETCH] Install dependencies"
yarn
echo "[BUILD] Building the web app bundle"
yarn build
echo "[DONE] Completed"
