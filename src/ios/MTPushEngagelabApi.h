//
//  PushTalkPlugin.h
//  PushTalk
//
//  Created by zhangqinghe on 13-12-13.
//
//

#import <Cordova/CDV.h>


@interface MTPushEngagelabApi: NSObject{
    
}
+ (MTPushEngagelabApi *)shareSingleton;
-(void)applicationDidLaunch:(NSNotification *)notification;
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken ;
- (void)channelMTPushEngagelab:(CDVInvokedUrlCommand*)command;
@end


