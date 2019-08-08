#!/bin/bash

GITHUB_USER=Griffin
GITHUB_EMAIL=bluedogerino@gmail.com

KBUILD_BUILD_USER="griffin"
KBUILD_BUILD_HOST="GriffinsCloud"

export oem=samsung
export device=j5y17lte

if [[ -z ROMname="LineageOS" ]]; then
ROM="LineageOS"
manifest_url="https://github.com/LineageOS/android"
export rom_vendor_name="lineage"
branch="lineage-16.0"
echo "using LineageOS"
elif [[ -z ROMname="RR" ]]; then
ROM="RR"
manifest_url="https://github.com/ResurrectionRemix/platform_manifest"
export rom_vendor_name="rr"
branch="pie"
echo "using RR"
elif [[ -z ROMname="AOSiP" ]]; then
ROM="RR"
ROM="AOSiP"
manifest_url="https://github.com/AOSiP/platform_manifest"
export rom_vendor_name="aosip"
branch="pie"
echo "Building AOSIP"
fi

telegram -M "Sync Started for ["$ROM"]("$manifest_url")"


release_repo="bluedogerino/symmetrical-broccoli"

timezone="Europe/Sarajevo"
