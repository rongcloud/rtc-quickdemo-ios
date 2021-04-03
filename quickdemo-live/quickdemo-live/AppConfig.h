//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

FOUNDATION_EXPORT NSString *const AppID;
FOUNDATION_EXPORT NSString *const roomId;



