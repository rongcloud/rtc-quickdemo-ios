//
//  UIViewController+SelectUser.h
//  ImKitDemo
//
//  Created by RongCloud on 2021/1/25.
//

#import <UIKit/UIKit.h>
#import "AppConfig.h"

typedef void(^CompleteHandle)(NSString *uid, NSString *uToken);

@interface UIViewController (SelectUser)
- (NSArray *)readFileUsers;
- (void)selectUserLoginHandle:(CompleteHandle)handle;
- (void)connectWithoutUserid:(NSString *)userid handle:(CompleteHandle)handle;
@end

