//
//  PushTalkPlugin.h
//  PushTalk
//
//  Created by zhangqinghe on 13-12-13.
//
//

#import <Cordova/CDV.h>
#import "MTPushService.h"


@interface MTPushEngagelabDelegate<MTPushRegisterDelegate> : NSObject{

}

+ (MTPushEngagelabDelegate *)shareSingleton;
@end


