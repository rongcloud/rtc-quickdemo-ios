//
//  MeetingCryptoImpl.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "MeetingCryptoImpl.h"

@implementation MeetingCryptoImpl

#pragma mark - RCRTCCustomizedEncryptorDelegate
- (int)EncryptPayloadData:(const uint8_t *)payloadData payloadSize:(size_t)payloadSize encryptedFrame:(uint8_t *)encryptedFrame bytesWritten:(size_t *)bytesWritten mediastreamId:(NSString *)mediastreamId mediaType:(int)mediatype{
    
    uint8_t fake_key_ = 0x88;
    for (size_t i = 0; i < payloadSize; i++) {
        encryptedFrame[i] = payloadData[i] ^ fake_key_;
    }
    *bytesWritten = payloadSize;
    return 0;
}

- (size_t)GetMaxCiphertextByteSize:(size_t)frameSize mediastreamId:(NSString *)mediastreamId mediaType:(int)mediatype{
    return frameSize;
}

#pragma mark - RCRTCCustomizedDecryptorDelegate
- (int)DecryptFrame:(const uint8_t *)encryptedFrame frameSize:(size_t)encryptedFrameSize frame:(uint8_t *)frame bytesWritten:(size_t *)bytesWritten mediastreamId:(NSString *)mediastreamId mediaType:(int)mediatype{
    
    uint8_t fake_key_ = 0x88;
    
    for (size_t i = 0; i < encryptedFrameSize; i++) {
        frame[i] = encryptedFrame[i]^ fake_key_;
    }
    
    *bytesWritten = encryptedFrameSize;
    return 0;
}

- (size_t)GetMaxPlaintextByteSize:(size_t)frameSize mediastreamId:(NSString *)mediastreamId mediaType:(int)mediatype{
    return frameSize;
}

@end
