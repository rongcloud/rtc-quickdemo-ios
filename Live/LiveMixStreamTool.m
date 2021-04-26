//
//  LiveMixStreamTool.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "LiveMixStreamTool.h"

@implementation LiveMixStreamTool

/**
 * 设置合流布局
 */
+ (RCRTCMixConfig *)setOutputConfig:(RCRTCMixLayoutMode)mode{
    
    // 布局配置类
    RCRTCMixConfig *streamConfig = [[RCRTCMixConfig alloc] init];
    
    // 选择模式
    streamConfig.layoutMode = mode;
    
    // 设置合流视频参数 ：宽：300 ，高：300 ，视频帧率 20， 视频码率 500；
    streamConfig.mediaConfig.videoConfig.videoLayout.width = 300;
    streamConfig.mediaConfig.videoConfig.videoLayout.height = 300;
    streamConfig.mediaConfig.videoConfig.videoLayout.fps = 20;
    streamConfig.mediaConfig.videoConfig.videoLayout.bitrate = 500;
    [streamConfig.mediaConfig.videoConfig setBackgroundColor:0x778899];
    
    // 音频配置
    streamConfig.mediaConfig.audioConfig.bitrate = 300;
    
    // 设置是否裁剪
    streamConfig.mediaConfig.videoConfig.videoExtend.renderMode = 1;
    
    
    NSMutableArray *streamArr = [NSMutableArray array];
    
    // 添加本地输出流
    NSArray<RCRTCOutputStream *> *localStreams
    = RCRTCEngine.sharedInstance.room.localUser.streams;
    for (RCRTCOutputStream *vStream in localStreams) {
        if (vStream.mediaType == RTCMediaTypeVideo) {
            [streamArr addObject:vStream];
        }
    }
    
    switch (mode) {
            
            // 自定义布局
        case RCRTCMixLayoutModeCustom:
        {
            // 如果是自定义布局需要设置下面这些
            NSArray<RCRTCRemoteUser *> *remoteUsers = RCRTCEngine.sharedInstance.room.remoteUsers;
            for (RCRTCRemoteUser* remoteUser in remoteUsers) {
                for (RCRTCInputStream *inputStream in remoteUser.remoteStreams) {
                    if (inputStream.mediaType == RTCMediaTypeVideo) {
                        [streamArr addObject:inputStream];
                    }
                }
            }
            [self customLayoutWithStreams:streamArr streamConfig:streamConfig];
        }
            break;
        case RCRTCMixLayoutModeSuspension:
            // 悬浮布局
        {
            RCRTCOutputStream *vStream = [streamArr lastObject];
            streamConfig.hostVideoStream = vStream;
        }
            break;
        case RCRTCMixLayoutModeAdaptive:
            // 自适应布局
        {
            RCRTCOutputStream *vStream = [streamArr lastObject];
            streamConfig.hostVideoStream = vStream;
        }
            break;
        default:
            break;
    }
    
    return streamConfig;
}

/**
 *自定义布局在此方法配置
 */
+ (void)customLayoutWithStreams:(NSMutableArray *)streams streamConfig:(RCRTCMixConfig *)streamConfig{
    NSInteger streamCount = streams.count;
    NSInteger itemWidth = 150;
    NSInteger itemHeight = itemWidth;
    
    // 坐标示例，具体根据自己布局设置
    if (streamCount == 1) {
        RCRTCStream *firstStream = [streams firstObject];
        RCRTCCustomLayout *inputConfig = [[RCRTCCustomLayout alloc] init];
        inputConfig.videoStream = firstStream;
        inputConfig.x = (300-itemWidth)/2;
        inputConfig.y = 0;
        inputConfig.width = itemWidth;
        inputConfig.height = itemHeight;
        [streamConfig.customLayouts addObject:inputConfig];
    }else if (streamCount == 2){
        RCRTCStream *firstStream = [streams firstObject];
        RCRTCStream *lastStream = [streams lastObject];
        
        RCRTCCustomLayout *inputConfig1 = [[RCRTCCustomLayout alloc] init];
        inputConfig1.videoStream = firstStream;
        inputConfig1.x = (300-itemWidth)/2;
        inputConfig1.y = 0;
        inputConfig1.width = itemWidth;
        inputConfig1.height = itemHeight;
        [streamConfig.customLayouts addObject:inputConfig1];
        
        RCRTCCustomLayout *inputConfig2 = [[RCRTCCustomLayout alloc] init];
        inputConfig2.videoStream = lastStream;
        inputConfig2.x = 0;
        inputConfig2.y = itemHeight;
        inputConfig2.width = itemWidth;
        inputConfig2.height = itemHeight;
        [streamConfig.customLayouts addObject:inputConfig2];
    }else if (streamCount == 3){
        RCRTCStream *firstStream = [streams firstObject];
        RCRTCStream *secondStream = streams[1];
        RCRTCStream *lastStream = [streams lastObject];
        
        RCRTCCustomLayout *inputConfig1 = [[RCRTCCustomLayout alloc] init];
        inputConfig1.videoStream = firstStream;
        inputConfig1.x = (300-itemWidth)/2;
        inputConfig1.y = 0;
        inputConfig1.width = itemWidth;
        inputConfig1.height = itemHeight;
        [streamConfig.customLayouts addObject:inputConfig1];
        
        RCRTCCustomLayout *inputConfig2 = [[RCRTCCustomLayout alloc] init];
        inputConfig2.videoStream = secondStream;
        inputConfig2.x = 0;
        inputConfig2.y = itemHeight;
        inputConfig2.width = itemWidth;
        inputConfig2.height = itemHeight;
        [streamConfig.customLayouts addObject:inputConfig2];
        
        RCRTCCustomLayout *inputConfig3 = [[RCRTCCustomLayout alloc] init];
        inputConfig3.videoStream = lastStream;
        inputConfig3.x = itemWidth;   
        inputConfig3.y = itemHeight;
        inputConfig3.width = itemWidth;
        inputConfig3.height = itemHeight;
        [streamConfig.customLayouts addObject:inputConfig3];
        
    }else{
        NSInteger i = 0;
        for (RCRTCStream *stream in streams) {
            RCRTCCustomLayout *inputConfig = [[RCRTCCustomLayout alloc] init];
            inputConfig.videoStream = stream;
            inputConfig.x = 100 * i;
            inputConfig.y = 100 * (i/3);
            inputConfig.width = 100;
            inputConfig.height = 100;
            [streamConfig.customLayouts addObject:inputConfig];
            i++;
        }
    }
}

@end
