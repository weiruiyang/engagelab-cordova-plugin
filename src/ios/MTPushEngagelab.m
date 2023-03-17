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
    }else if ([name isEqualToString:(@"addTags")]){
        [self addTags:data];
    }else if ([name isEqualToString:(@"deleteTags")]){
        [self deleteTags:data];
    }else if ([name isEqualToString:(@"deleteAllTag")]){
        [self cleanTags:data];
    }else if ([name isEqualToString:(@"queryAllTag")]){
        [self getAllTags:data];
    }else if ([name isEqualToString:(@"queryTag")]){
        [self validTag:data];
    }else if ([name isEqualToString:(@"setAlias")]){
        [self setAlias:data];
    }else if ([name isEqualToString:(@"getAlias")]){
        [self getAlias:data];
    }else if ([name isEqualToString:(@"clearAlias")]){
        [self deleteAlias:data];
    }else if ([name isEqualToString:(@"updateTags")]){
        [self setTags:data];
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


-(void)setTags:(NSArray* )data {
    NSDictionary* params = [data objectAtIndex:0];
    NSNumber* sequence = params[@"sequence"];
    NSArray* tags = params[@"tags"];

    [MTPushService setTags:[NSSet setWithArray:tags] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
            [MTPushEngagelab tagsCallBackChannel:(@"setTags") iResCode:(iResCode) iTags:(iTags) seq:(seq)];
        } seq:([sequence intValue])];

}


-(void)addTags:(NSArray* )data {
    NSDictionary* params = [data objectAtIndex:0];
    NSNumber* sequence = params[@"sequence"];
    NSArray* tags = params[@"tags"];

    [MTPushService addTags:[NSSet setWithArray:tags] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
            [MTPushEngagelab tagsCallBackChannel:(@"addTags") iResCode:(iResCode) iTags:(iTags) seq:(seq)];
        } seq:([sequence intValue])];

}


-(void)deleteTags:(NSArray* )data {
    NSDictionary* params = [data objectAtIndex:0];
    NSNumber* sequence = params[@"sequence"];
    NSArray* tags = params[@"tags"];

    [MTPushService deleteTags:[NSSet setWithArray:tags] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
            [MTPushEngagelab tagsCallBackChannel:(@"deleteTags") iResCode:(iResCode) iTags:(iTags) seq:(seq)];
        } seq:([sequence intValue])];

}


-(void)cleanTags:(NSArray* )data {
    NSDictionary* params = [data objectAtIndex:0];
    NSNumber* sequence = params[@"sequence"];

    [MTPushService cleanTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
            [MTPushEngagelab tagsCallBackChannel:(@"cleanTags") iResCode:(iResCode) iTags:(iTags) seq:(seq)];
        } seq:([sequence intValue])];

}


-(void)getAllTags:(NSArray* )data {
    NSDictionary* params = [data objectAtIndex:0];
    NSNumber* sequence = params[@"sequence"];

    [MTPushService getAllTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
            [MTPushEngagelab tagsCallBackChannel:(@"getAllTags") iResCode:(iResCode) iTags:(iTags) seq:(seq)];
        } seq:([sequence intValue])];

}



-(void)validTag:(NSArray* )data {
    NSDictionary* params = [data objectAtIndex:0];
    NSNumber* sequence = params[@"sequence"];
    NSString* tag = params[@"tag"];
    [MTPushService validTag:tag completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq, BOOL isBind) {
            NSMutableDictionary *data = @{}.mutableCopy;
                    data[@"code"] = @(iResCode);//[NSNumber numberWithInteger:iResCode];
                    data[@"sequence"] = @(seq);
                    if (iResCode == 0) {
                        data[@"tags"] = [iTags allObjects];
                        [data setObject:[NSNumber numberWithBool:isBind] forKey:@"isBind"];
                    }
        [MTPushEngagelab fireDocumentEvent:@"validTag" jsString:[data toJsonString]];
    } seq:([sequence intValue])];
}


-(void)setAlias:(NSArray* )data {
    NSNumber* sequence = [data objectAtIndex:0];
    NSString* alias = [data objectAtIndex:1];
    [MTPushService setAlias:alias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                    [MTPushEngagelab aliasCallBackChannel:(@"setAlias") iResCode:(iResCode) iAlias:(iAlias) seq:(seq)];
    } seq:([sequence intValue])];
}


-(void)deleteAlias:(NSArray* )data {
   NSNumber* sequence = [data objectAtIndex:0];
    [MTPushService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                    [MTPushEngagelab aliasCallBackChannel:(@"deleteAlias") iResCode:(iResCode) iAlias:(iAlias) seq:(seq)];
    } seq:([sequence intValue])];
}


-(void)getAlias:(NSArray* )data {
    NSNumber* sequence = [data objectAtIndex:0];
    [MTPushService getAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                    [MTPushEngagelab aliasCallBackChannel:(@"getAlias") iResCode:(iResCode) iAlias:(iAlias) seq:(seq)];
    } seq:([sequence intValue])];
}


+(void)tagsCallBackChannel:(NSString*)eventName iResCode:(NSInteger)iResCode iTags:(NSSet*)iTags seq:(NSInteger)seq{
    NSMutableDictionary *data = @{}.mutableCopy;
    data[@"code"] = @(iResCode);//[NSNumber numberWithInteger:iResCode];
    data[@"sequence"] = @(seq);
    if (iResCode == 0) {
        data[@"tags"] = [iTags allObjects];
    }
    [MTPushEngagelab fireDocumentEvent:eventName jsString:[data toJsonString]];
};


+(void)aliasCallBackChannel:(NSString*)eventName iResCode:(NSInteger)iResCode iAlias:(NSString*)iAlias seq:(NSInteger)seq {
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSNumber numberWithInteger:seq] forKey:@"sequence"];
            [dic setValue:[NSNumber numberWithUnsignedInteger:iResCode] forKey:@"code"];

            if (iResCode == 0) {
                [dic setObject:iAlias forKey:@"alias"];
            }
        [MTPushEngagelab fireDocumentEvent:eventName jsString:[dic toJsonString]];

};

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
