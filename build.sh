#!/bin/bash

#  RongCloud RTC Demo
#
#  Copyright © 2021 RongCloud. All rights reserved.

echo "begin build RongCloud RTC Demo"

# 记录根目录
ROOT_PATH=`pwd`
echo "当前目录`pwd`"

# 最终文件生成地址
OUTPUT_PATH="${ROOT_PATH}/output"
echo "结果输出目录${OUTPUT_PATH}"

# 生成文件中间目录
BUILD_DIR="build"

CONFIGURATION="Release"
# 需要集成的 RTC 版本
RTC_VERSION=${build_version}
echo "替换的rtc 版本 ${RTC_VERSION}"

# 需要替换的AppKey
APPKEY=${AppKey}
echo "替换的APPKEY ${APPKEY}"

APPSECRET=${AppSecret}
BUILD_BRANCH=${build_branch}

function clean_last_build(){
  path="./"
  rm -rf $ROOT_PATH/bin
  rm -rf $ROOT_PATH/build
  rm -rf $ROOT_PATH/Pods
  rm -rf $ROOT_PATH/Podfile.lock
  rm -rf $OUTPUT_PATH
}

function pod_update() {
  echo "开始进行 pod"
  if [ -n "${RTC_VERSION}" ]; then
    echo "RTCVersion:${RTC_VERSION}"
    sed -i '' "/pod 'RongCloudRTC'/d" ./Podfile
    sed -i '' -e "/^end/i \ 
  pod 'RongCloudRTC1', '$RTC_VERSION'" ./Podfile
    echo "podfile 替换完成"
  fi
}

clean_last_build

mkdir $OUTPUT_PATH

#删除 demo 中默认配置的相关环境

echo "开始替换参数"
sed -i "" -e 's?^NSString \* const AppKey.*$?NSString \* const AppKey = @\"'${APPKEY}'\";?' ${ROOT_PATH}/RCRTCQuickDemo/Tool/Constant/Constant.m
sed -i "" -e 's?^NSString \* const AppSecret.*$?NSString \* const AppSecret = @\"'${APPSECRET}'\";?' ${ROOT_PATH}/RCRTCQuickDemo/Tool/Constant/Constant.m

pod_update

pod update --no-repo-update
pod install

PROJECT_NAME="RCRTCQuickDemo.xcworkspace"
targetName="RCRTCQuickDemo"
TARGET_DECIVE="iphoneos"
BUILD_APP_PROFILE=""
BUILD_SHARE_PROFILE=""
BIN_DIR="bin"


echo "***开始build iphoneos文件***"
xcodebuild clean -workspace ${PROJECT_NAME} -scheme ${targetName}  -configuration ${CONFIGURATION}
xcodebuild -workspace "${PROJECT_NAME}" -scheme "${targetName}" archive -archivePath "./${BUILD_DIR}/${targetName}.xcarchive" -configuration ${CONFIGURATION} APP_PROFILE="${BUILD_APP_PROFILE}" SHARE_PROFILE="${BUILD_SHARE_PROFILE}" -allowProvisioningUpdates
xcodebuild -exportArchive -archivePath "./${BUILD_DIR}/${targetName}.xcarchive" -exportOptionsPlist "archive.plist" -exportPath "./${BIN_DIR}" -allowProvisioningUpdates
  
mv ./${BIN_DIR}/${targetName}.ipa ${ROOT_PATH}/${BIN_DIR}/${targetName}_v${RTC_VERSION}_${CONFIGURATION}_${CUR_TIME}.ipa
cp -af ./${BUILD_DIR}/${targetName}.xcarchive/dSYMs/${targetName}.app.dSYM ${ROOT_PATH}/${BIN_DIR}/${BUILD_BRANCH}_v${RTC_VERSION}_${CONFIGURATION}.app.dSYM
echo "***编译结束***"

echo "***输出 ipa 与 dsym ***"
cp -af ${BIN_DIR}/*.ipa ${OUTPUT_PATH}/
cp -af ${BIN_DIR}/*.app.dSYM ${OUTPUT_PATH}
