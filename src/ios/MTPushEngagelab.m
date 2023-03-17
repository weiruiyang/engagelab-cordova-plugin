/********* MTPushEngagelab.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>


#import "AppDelegate+MTPush.h"
#import "MTPushEngagelab.h"
#import "MTPushService.h"
#import <objc/runtime.h>
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <UserNotifications/UserNotifications.h>


@implementation NSDictionary (MTPush)
-(NSString*)toJsonString{
    NSError  *error;
    NSData   *data       = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    NSString *jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return jsonString;
}
@end

@implementation NSString (MTPush)
-(NSDictionary*)toDictionary{
    NSError      *error;
    NSData       *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict     = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    return dict;
}
@end


static MTPushEngagelab *SharedJPushPlugin;
@implementation MTPushEngagelab

- (void)channelMTPushEngagelab:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* name = [command.arguments objectAtIndex:0];
    NSArray* data = [command.arguments objectAtIndex:1];

    if ([name isEqualToString:(@"init")]) {
        [self initSdk];
    }else if ([name isEqualToString:(@"getRegistrationId")]){
        [self registrationIDCompletionHandler:command];
    }else if ([name isEqualToString:(@"setNotificationBadge")]){
        [self setBadge:data];
    }else if ([name isEqualToString:(@"resetNotificationBadge")]){
        [self resetBadge];
    }else if ([name isEqualToString:(@"configDebugMode")]){
        [self setDebugMode:data];
    }

//    if (name != nil && [name length] > 0) {
//        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:name];
//    } else {
//        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
//    }
//
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


-(void)initSdk{

    NSDictionary *launchOptions = AppDelegate.launchOptions;

    static NSString *const JPushConfig_FileName     = @"MTPushConfig";
    static NSString *const JPushConfig_Appkey       = @"Appkey";
    static NSString *const JPushConfig_Channel      = @"Channel";
    static NSString *const JPushConfig_IsProduction = @"IsProduction";
    static NSString *const JPushConfig_IsIDFA       = @"IsIDFA";
    static NSString *const JPushConfig_Delay        = @"Delay";

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:JPushConfig_FileName ofType:@"plist"];
    if (plistPath == nil) {
        NSLog(@"error: PushConfig.plist not found");
        assert(0);
    }

    NSMutableDictionary *plistData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *appkey       = [plistData valueForKey:JPushConfig_Appkey];
    NSString *channel      = [plistData valueForKey:JPushConfig_Channel];
    NSNumber *isProduction = [plistData valueForKey:JPushConfig_IsProduction];
    NSNumber *isIDFA       = [plistData valueForKey:JPushConfig_IsIDFA];

    __block NSString *advertisingId = nil;
    if(isIDFA.boolValue) {
          if (@available(iOS 14, *)) {
              //设置Info.plist中 NSUserTrackingUsageDescription 需要广告追踪权限，用来定位唯一用户标识
              [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                  if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                    advertisingId = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;
                  }
              }];
          } else {
              // 使用原方式访问 IDFA
            advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
          }
    }
    [MTPushService setupWithOption:launchOptions
                           appKey:appkey
                          channel:channel
                 apsForProduction:[isProduction boolValue]
            advertisingIdentifier:advertisingId];
}


-(void)registrationIDCompletionHandler:(CDVInvokedUrlCommand*)command{
    [MTPushService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        NSLog(@"resCode : %d,registrationID: %@",resCode,registrationID);
        CDVPluginResult* result;
        if (resCode == 0) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:registrationID];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:resCode];
        }
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];

}

-(void)setBadge:(NSArray* )data {
    int value = [[data objectAtIndex:0] intValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber = value;
    [MTPushService setBadge:value];
}


-(void)resetBadge {
    [MTPushService resetBadge];
}


-(void)setDebugMode:(NSArray* )data {
    bool value = [data objectAtIndex:0];
    if (value) {
        [MTPushService setDebugMode];
    }
}

#ifdef __CORDOVA_4_0_0

- (void)pluginInitialize {
    NSLog(@"### pluginInitialize ");
    [self initPlugin];
}

#else

- (CDVPlugin*)initWithWebView:(WKWebView*)theWebView{
    NSLog(@"### initWithWebView ");
    if (self=[super initWithWebView:theWebView]) {
    }
    [self initPlugin];
    return self;
}

#endif

-(void)initPlugin{
    if (!SharedJPushPlugin) {
        SharedJPushPlugin = self;
    }
}

+(void)fireDocumentEvent:(NSString*)eventName jsString:(NSString*)jsString{
    NSMutableDictionary *data = @{}.mutableCopy;
    data[@"event_name"] = eventName;
    data[@"event_data"] = jsString;

    NSString *toC = [data toJsonString];
    NSLog(@"toC：%@",toC);
  if (SharedJPushPlugin) {
    dispatch_async(dispatch_get_main_queue(), ^{

//      [SharedJPushPlugin.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireDocumentEvent('MTPushEngagelab.onMTCommonReceiver',%@)", toC]];
        [SharedJPushPlugin.commandDelegate evalJs:[NSString stringWithFormat:@"window.plugins.mTPushEngagelab.onMTCommonReceiver(%@);", toC]];

    });
    return;
  }


}
@end
