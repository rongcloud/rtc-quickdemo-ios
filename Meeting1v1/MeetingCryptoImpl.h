//
//  MeetingCryptoImpl.h
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 自定义加解密的实现类
 */
@interface MeetingCryptoImpl : NSObject <RCRTCCustomizedEncryptorDelegate,RCRTCCustomizedDecryptorDelegate>
 
@end

NS_ASSUME_NONNULL_END
