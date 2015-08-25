#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

realpath() {
  DIRECTORY="$(cd "${1%/*}" && pwd)"
  FILENAME="${1##*/}"
  echo "$DIRECTORY/$FILENAME"
}

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm\""
      xcrun mapc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE=$(realpath "${PODS_ROOT}/$1")
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "DLCImagePickerController/Resources/DLCImagePicker.xib"
  install_resource "DLCImagePickerController/Resources/Filters/02.acv"
  install_resource "DLCImagePickerController/Resources/Filters/06.acv"
  install_resource "DLCImagePickerController/Resources/Filters/17.acv"
  install_resource "DLCImagePickerController/Resources/Filters/aqua.acv"
  install_resource "DLCImagePickerController/Resources/Filters/crossprocess.acv"
  install_resource "DLCImagePickerController/Resources/Filters/purple-green.acv"
  install_resource "DLCImagePickerController/Resources/Filters/yellow-red.acv"
  install_resource "DLCImagePickerController/Images/Overlays/blackframe.png"
  install_resource "DLCImagePickerController/Images/Overlays/mask.png"
  install_resource "DLCImagePickerController/Images/UI/blur-on.png"
  install_resource "DLCImagePickerController/Images/UI/blur-on@2x.png"
  install_resource "DLCImagePickerController/Images/UI/blur.png"
  install_resource "DLCImagePickerController/Images/UI/blur@2x.png"
  install_resource "DLCImagePickerController/Images/UI/camera-button.png"
  install_resource "DLCImagePickerController/Images/UI/camera-button@2x.png"
  install_resource "DLCImagePickerController/Images/UI/camera-icon.png"
  install_resource "DLCImagePickerController/Images/UI/camera-icon@2x.png"
  install_resource "DLCImagePickerController/Images/UI/close.png"
  install_resource "DLCImagePickerController/Images/UI/close@2x.png"
  install_resource "DLCImagePickerController/Images/UI/dock_bg.png"
  install_resource "DLCImagePickerController/Images/UI/dock_bg@2x.png"
  install_resource "DLCImagePickerController/Images/UI/filter-close.png"
  install_resource "DLCImagePickerController/Images/UI/filter-close@2x.png"
  install_resource "DLCImagePickerController/Images/UI/filter-open.png"
  install_resource "DLCImagePickerController/Images/UI/filter-open@2x.png"
  install_resource "DLCImagePickerController/Images/UI/filter.png"
  install_resource "DLCImagePickerController/Images/UI/filter@2x.png"
  install_resource "DLCImagePickerController/Images/UI/flash-auto.png"
  install_resource "DLCImagePickerController/Images/UI/flash-auto@2x.png"
  install_resource "DLCImagePickerController/Images/UI/flash-off.png"
  install_resource "DLCImagePickerController/Images/UI/flash-off@2x.png"
  install_resource "DLCImagePickerController/Images/UI/flash.png"
  install_resource "DLCImagePickerController/Images/UI/flash@2x.png"
  install_resource "DLCImagePickerController/Images/UI/front-camera.png"
  install_resource "DLCImagePickerController/Images/UI/front-camera@2x.png"
  install_resource "DLCImagePickerController/Images/UI/micro_carbon.png"
  install_resource "DLCImagePickerController/Images/UI/micro_carbon@2x.png"
  install_resource "DLCImagePickerController/Images/UI/photo_bar.png"
  install_resource "DLCImagePickerController/Images/UI/photo_bar@2x.png"
  install_resource "DLCImagePickerController/Images/FilterSamples/1.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/10.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/10@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/1@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/2.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/2@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/3.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/3@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/4.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/4@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/5.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/5@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/6.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/6@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/7.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/7@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/8.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/8@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/9.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/9@2x.jpg"
  install_resource "GPUImage/framework/Resources/lookup.png"
  install_resource "GPUImage/framework/Resources/lookup_amatorka.png"
  install_resource "GPUImage/framework/Resources/lookup_miss_etikate.png"
  install_resource "GPUImage/framework/Resources/lookup_soft_elegance_1.png"
  install_resource "GPUImage/framework/Resources/lookup_soft_elegance_2.png"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "DLCImagePickerController/Resources/DLCImagePicker.xib"
  install_resource "DLCImagePickerController/Resources/Filters/02.acv"
  install_resource "DLCImagePickerController/Resources/Filters/06.acv"
  install_resource "DLCImagePickerController/Resources/Filters/17.acv"
  install_resource "DLCImagePickerController/Resources/Filters/aqua.acv"
  install_resource "DLCImagePickerController/Resources/Filters/crossprocess.acv"
  install_resource "DLCImagePickerController/Resources/Filters/purple-green.acv"
  install_resource "DLCImagePickerController/Resources/Filters/yellow-red.acv"
  install_resource "DLCImagePickerController/Images/Overlays/blackframe.png"
  install_resource "DLCImagePickerController/Images/Overlays/mask.png"
  install_resource "DLCImagePickerController/Images/UI/blur-on.png"
  install_resource "DLCImagePickerController/Images/UI/blur-on@2x.png"
  install_resource "DLCImagePickerController/Images/UI/blur.png"
  install_resource "DLCImagePickerController/Images/UI/blur@2x.png"
  install_resource "DLCImagePickerController/Images/UI/camera-button.png"
  install_resource "DLCImagePickerController/Images/UI/camera-button@2x.png"
  install_resource "DLCImagePickerController/Images/UI/camera-icon.png"
  install_resource "DLCImagePickerController/Images/UI/camera-icon@2x.png"
  install_resource "DLCImagePickerController/Images/UI/close.png"
  install_resource "DLCImagePickerController/Images/UI/close@2x.png"
  install_resource "DLCImagePickerController/Images/UI/dock_bg.png"
  install_resource "DLCImagePickerController/Images/UI/dock_bg@2x.png"
  install_resource "DLCImagePickerController/Images/UI/filter-close.png"
  install_resource "DLCImagePickerController/Images/UI/filter-close@2x.png"
  install_resource "DLCImagePickerController/Images/UI/filter-open.png"
  install_resource "DLCImagePickerController/Images/UI/filter-open@2x.png"
  install_resource "DLCImagePickerController/Images/UI/filter.png"
  install_resource "DLCImagePickerController/Images/UI/filter@2x.png"
  install_resource "DLCImagePickerController/Images/UI/flash-auto.png"
  install_resource "DLCImagePickerController/Images/UI/flash-auto@2x.png"
  install_resource "DLCImagePickerController/Images/UI/flash-off.png"
  install_resource "DLCImagePickerController/Images/UI/flash-off@2x.png"
  install_resource "DLCImagePickerController/Images/UI/flash.png"
  install_resource "DLCImagePickerController/Images/UI/flash@2x.png"
  install_resource "DLCImagePickerController/Images/UI/front-camera.png"
  install_resource "DLCImagePickerController/Images/UI/front-camera@2x.png"
  install_resource "DLCImagePickerController/Images/UI/micro_carbon.png"
  install_resource "DLCImagePickerController/Images/UI/micro_carbon@2x.png"
  install_resource "DLCImagePickerController/Images/UI/photo_bar.png"
  install_resource "DLCImagePickerController/Images/UI/photo_bar@2x.png"
  install_resource "DLCImagePickerController/Images/FilterSamples/1.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/10.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/10@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/1@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/2.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/2@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/3.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/3@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/4.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/4@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/5.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/5@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/6.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/6@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/7.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/7@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/8.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/8@2x.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/9.jpg"
  install_resource "DLCImagePickerController/Images/FilterSamples/9@2x.jpg"
  install_resource "GPUImage/framework/Resources/lookup.png"
  install_resource "GPUImage/framework/Resources/lookup_amatorka.png"
  install_resource "GPUImage/framework/Resources/lookup_miss_etikate.png"
  install_resource "GPUImage/framework/Resources/lookup_soft_elegance_1.png"
  install_resource "GPUImage/framework/Resources/lookup_soft_elegance_2.png"
fi

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac

  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "`realpath $PODS_ROOT`*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
