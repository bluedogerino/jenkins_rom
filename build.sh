#!/bin/bash

echo ${TELEGRAM_TOKEN} >/tmp/tg_token
echo $T[ELEGRAM_CHAT} >/tmp/tg_chat
echo ${GITHUB_TOKEN} >/tmp/gh_token

git clone https://github.com/bluedogerino/manifest.git .repo/local_manifests

source ./config.sh

# Email for git
git config --global user.email "bluedogerino@gmail.com"
git config --global user.name "Griffin"

export TELEGRAM_TOKEN
export TELEGRAM_CHAT
export GITHUB_TOKEN

function trim_darwin() {
    cd .repo/manifests
    cat default.xml | grep -v darwin  >temp  && cat temp >default.xml  && rm temp
    git commit -a -m "Magic"
    cd ../
    cat manifest.xml | grep -v darwin  >temp  && cat temp >manifest.xml  && rm temp
    cd ../
}

export outdir="out/target/product/$device"

mkdir "$ROM"
cd "$ROM"
mkdir .repo/local_manifests -p

repo init -u "$manifest_url" -b "$branch" --depth 1 >/dev/null  2>&1
echo "Sync started for "$manifest_url""
telegram -M "Sync Started for ["$ROM"]("$manifest_url")"
SYNC_START=$(date +"%s")
trim_darwin >/dev/null   2>&1
bash ./clone.sh
repo sync --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j64 -q 2>&1 >>logwe 2>&1
SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
if [ -e frameworks/base ]; then
    echo "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    echo "Build Started"
    telegram -M "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds
Build Started: [See Progress]"

    BUILD_START=$(date +"%s")

    . build/envsetup.sh >/dev/null  2>&1
    lunch "$rom_vendor_name"_"$device"-userdebug >/dev/null  2>&1
    mka bacon -j64 | grep "$device"
    BUILD_END=$(date +"%s")
    BUILD_DIFF=$((BUILD_END - BUILD_START))

    export finalzip_path=$(ls "$outdir"/*201*.zip | tail -n -1)
    export zip_name=$(echo "$finalzip_path" | sed "s|"$outdir"/||")
    export tag=$( echo "$zip_name" | sed 's|.zip||')
    if [ -e "$finalzip_path" ]; then
        echo "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"

        echo "Uploading"

        github-release "$release_repo" "$tag" "master" ""$ROM" for "$device"
Date: $(env TZ="$timezone" date)" "$finalzip_path"

        echo "Uploaded"

        telegram -M "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds
Download: ["$zip_name"](https://github.com/"$release_repo"/releases/download/"$tag"/"$zip_name")"

    else
        echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
        telegram -N -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
        exit 1
    fi
else
    echo "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    telegram -N -M "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    exit 1
fi
