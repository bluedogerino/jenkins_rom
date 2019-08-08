#!/bin/bash


GITHUB_USER=Griffin
GITHUB_EMAIL=bluedogerino@gmail.com

KBUILD_BUILD_USER="griffin"
KBUILD_BUILD_HOST="GriffinsCloud"

export oem=samsung
export device=j5y17lte

if [[ "${ROMname}" =~ "LineageOS" ]]; then
ROM="LineageOS"
manifest_url="https://github.com/LineageOS/android"
export rom_vendor_name="lineage"
branch="lineage-16.0"
echo "using LineageOS";
elif [[ "${ROMname}" =~ "RR" ]]; then
ROM="RR"
manifest_url="https://github.com/ResurrectionRemix/platform_manifest"
export rom_vendor_name="rr"
branch="pie"
echo "using RR";
elif [[ "${ROMname}" =~ "AOSiP" ]]; then
ROM="AOSiP"
manifest_url="https://github.com/AOSiP/platform_manifest"
export rom_vendor_name="aosip"
branch="pie"
echo "Building AOSIP";
elif [[ -n "$string" ]]; then
  echo "String is not empty";
fi

telegram -M "Sync Started for ["$ROM"]("$manifest_url")"


release_repo="bluedogerino/symmetrical-broccoli"

timezone="Europe/Sarajevo"

mkdir "$ROM"
cd "$ROM"

repo init -u "$manifest_url" -b "$branch" --depth 1 >/dev/null  2>&1
function trim_darwin() {
    cd .repo/manifests
    cat default.xml | grep -v darwin  >temp  && cat temp >default.xml  && rm temp
    git commit -a -m "Magic"
    cd ../
    cat manifest.xml | grep -v darwin  >temp  && cat temp >manifest.xml  && rm temp
    cd ../
}
export outdir="out/target/product/$device"
mkdir .repo/local_manifests -p
git clone https://github.com/bluedogerino/manifest.git .repo/local_manifests
echo "Sync started for "$manifest_url""
telegram -M "Sync Started for ["$ROM"]("$manifest_url")"
SYNC_START=$(date +"%s")
trim_darwin >/dev/null   2>&1
repo sync --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j64 -q 2>&1 >>logwe 2>&1
SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
if [ -e frameworks/base ]; then
    echo "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    echo "Build Started"
    telegram -M "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds
Build Started: [See Progress]("https://jenkins.turbox.uk/job/${JOB_NAME}/${BUILD_NUMBER}/console")"

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
