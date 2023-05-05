/********* MTPushEngagelab.m Cordova Plugin Implementation *******/

#import "MTPushEngagelabApi.h"
#import "MTPushService.h"
#import "MTPushEngagelabChannels.h"
#import "MTPushEngagelabSelector.h"
#import "MTPushEngagelabDelegate.h"
#import "MTPushEngagelabUtils.h"


#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@implementation MTPushEngagelabApi


static MTPushEngagelabApi *shareSingleton = nil;

+ (instancetype)shareSingleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareSingleton = [[super allocWithZone:NULL] init];
    });
    return shareSingleton;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [MTPushEngagelabApi shareSingleton];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [MTPushEngagelabApi shareSingleton];
}

NSDictionary * myLaunchOptions;
NSData * myDeviceToken;

-(void)applicationDidLaunch:(NSNotification *)notification{
    // 3.0.0及以后版本注册
    MTPushRegisterEntity * entity = [[MTPushRegisterEntity alloc] init];
    if (@available(iOS 12.0, *)) {
        entity.types = MTPushAuthorizationOptionAlert|MTPushAuthorizationOptionBadge|MTPushAuthorizationOptionSound|MTPushAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        entity.types = MTPushAuthorizationOptionAlert|MTPushAuthorizationOptionBadge|MTPushAuthorizationOptionSound;
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        //    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        //      NSSet<UNNotificationCategory *> *categories;
        //      entity.categories = categories;
        //    }
        //    else {
        //      NSSet<UIUserNotificationCategory *> *categories;
        //      entity.categories = categories;
        //    }
    }
    [MTPushService registerForRemoteNotificationConfig:entity delegate:[MTPushEngagelabDelegate shareSingleton]];


    // 检测通知授权情况。可选项，不一定要放在此处，可以运行一定时间后再调用
    //    [self performSelector:@selector(checkNotificationAuthorization) withObject:nil afterDelay:10];

    [[MTPushEngagelabSelector shareSingleton] initSelector];
    myLaunchOptions = notification.userInfo;

}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const unsigned int *tokenBytes = [deviceToken bytes];
    NSString *tokenString = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                             ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                             ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                             ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    MYLog(@"Device Token: %@", tokenString);
    myDeviceToken = deviceToken;
    [MTPushService registerDeviceToken:deviceToken];
}



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
    }else if ([name isEqualToString:(@"setTcpSSL")]){
        [self setTcpSSL:data];
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


    static NSString *const JPushConfig_FileName     = @"MTPushConfig";
    static NSString *const JPushConfig_Appkey       = @"Appkey";
    static NSString *const JPushConfig_Channel      = @"Channel";
    static NSString *const JPushConfig_IsProduction = @"IsProduction";
    static NSString *const JPushConfig_IsIDFA       = @"IsIDFA";
    static NSString *const JPushConfig_Delay        = @"Delay";

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:JPushConfig_FileName ofType:@"plist"];
    if (plistPath == nil) {
        MYLog(@"error: PushConfig.plist not found");
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
    [MTPushService setupWithOption:myLaunchOptions
                            appKey:appkey
                           channel:channel
                  apsForProduction:[isProduction boolValue]
             advertisingIdentifier:advertisingId];


    [MTPushService registerDeviceToken:myDeviceToken];
}


-(void)registrationIDCompletionHandler:(CDVInvokedUrlCommand*)command{
    [MTPushService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        MYLog(@"resCode : %d,registrationID: %@",resCode,registrationID);
        CDVPluginResult* result;
        if (resCode == 0) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:registrationID];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:resCode];
        }
        [MTPushEngagelabChannels sendPluginResult:result callbackId:command.callbackId];
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

-(void)setTcpSSL:(NSArray* )data {
    bool value = [data objectAtIndex:0];
    [MTPushService setTcpSSL:value];
}

-(void)setTags:(NSArray* )data {
//    NSDictionary* params = [data objectAtIndex:0];
//    NSNumber* sequence = params[@"sequence"];
//    NSArray* tags = params[@"tags"];
//
//    [MTPushService setTags:[NSSet setWithArray:tags] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
//        [MTPushEngagelabApi tagsCallBackChannel:(@"setTags") iResCode:(iResCode) iTags:(iTags) seq:(seq)];
//    } seq:([sequence intValue])];

}


-(void)addTags:(NSArray* )data {
//    NSDictionary* params = [data objectAtIndex:0];
//    NSNumber* sequence = params[@"sequence"];
//    NSArray* tags = params[@"tags"];
//
//    [MTPushService addTags:[NSSet setWithArray:tags] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
//        [MTPushEngagelabApi tagsCallBackChannel:(@"addTags") iResCode:(iResCode) iTags:(iTags) seq:(seq)];
//    } seq:([sequence intValue])];
}


-(void)deleteTags:(NSArray* )data {
//    NSDictionary* params = [data objectAtIndex:0];
//    NSNumber* sequence = params[@"sequence"];
//    NSArray* tags = params[@"tags"];
//
//    [MTPushService deleteTags:[NSSet setWithArray:tags] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
//        [MTPushEngagelabApi tagsCallBackChannel:(@"deleteTags") iResCode:(iResCode) iTags:(iTags) seq:(seq)];
//    } seq:([sequence intValue])];

}


-(void)cleanTags:(NSArray* )data {
//    NSDictionary* params = [data objectAtIndex:0];
//    NSNumber* sequence = params[@"sequence"];
//
//    [MTPushService cleanTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
//        [MTPushEngagelabApi tagsCallBackChannel:(@"cleanTags") iResCode:(iResCode) iTags:(iTags) seq:(seq)];
//    } seq:([sequence intValue])];

}


-(void)getAllTags:(NSArray* )data {
//    NSDictionary* params = [data objectAtIndex:0];
//    NSNumber* sequence = params[@"sequence"];
//
//    [MTPushService getAllTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
//        [MTPushEngagelabApi tagsCallBackChannel:(@"getAllTags") iResCode:(iResCode) iTags:(iTags) seq:(seq)];
//    } seq:([sequence intValue])];

}



-(void)validTag:(NSArray* )data {
//    NSDictionary* params = [data objectAtIndex:0];
//    NSNumber* sequence = params[@"sequence"];
//    NSString* tag = params[@"tag"];
//    [MTPushService validTag:tag completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq, BOOL isBind) {
//        NSMutableDictionary *data = @{}.mutableCopy;
//        data[@"code"] = @(iResCode);//[NSNumber numberWithInteger:iResCode];
//        data[@"sequence"] = @(seq);
//        if (iResCode == 0 && nil != iTags) {
//            data[@"tags"] = [iTags allObjects];
//            [data setObject:[NSNumber numberWithBool:isBind] forKey:@"isBind"];
//        }
//        [MTPushEngagelabChannels fireDocumentEvent:@"validTag" jsString:[data toJsonString]];
//    } seq:([sequence intValue])];
}


-(void)setAlias:(NSArray* )data {
//    NSNumber* sequence = [data objectAtIndex:0];
//    NSString* alias = [data objectAtIndex:1];
//    [MTPushService setAlias:alias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
//        [MTPushEngagelabApi aliasCallBackChannel:(@"setAlias") iResCode:(iResCode) iAlias:(iAlias) seq:(seq)];
//    } seq:([sequence intValue])];
}


-(void)deleteAlias:(NSArray* )data {
//    NSNumber* sequence = [data objectAtIndex:0];
//    [MTPushService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
//        [MTPushEngagelabApi aliasCallBackChannel:(@"deleteAlias") iResCode:(iResCode) iAlias:(iAlias) seq:(seq)];
//    } seq:([sequence intValue])];
}


-(void)getAlias:(NSArray* )data {
//    NSNumber* sequence = [data objectAtIndex:0];
//    [MTPushService getAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
//        [MTPushEngagelabApi aliasCallBackChannel:(@"getAlias") iResCode:(iResCode) iAlias:(iAlias) seq:(seq)];
//    } seq:([sequence intValue])];
}


+(void)tagsCallBackChannel:(NSString*)eventName iResCode:(NSInteger)iResCode iTags:(NSSet*)iTags seq:(NSInteger)seq{
    NSMutableDictionary *data = @{}.mutableCopy;
    data[@"code"] = @(iResCode);//[NSNumber numberWithInteger:iResCode];
    data[@"sequence"] = @(seq);
    if (iResCode == 0 && nil != iTags) {
        data[@"tags"] = [iTags allObjects];
    }
    [MTPushEngagelabChannels fireDocumentEvent:eventName jsString:[data toJsonString]];
};


+(void)aliasCallBackChannel:(NSString*)eventName iResCode:(NSInteger)iResCode iAlias:(NSString*)iAlias seq:(NSInteger)seq {
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInteger:seq] forKey:@"sequence"];
    [dic setValue:[NSNumber numberWithUnsignedInteger:iResCode] forKey:@"code"];

    if (iResCode == 0 && nil != iAlias) {
        [dic setObject:iAlias forKey:@"alias"];
    }
    [MTPushEngagelabChannels fireDocumentEvent:eventName jsString:[dic toJsonString]];

};


#pragma mark - 通知权限引导

// 检测通知权限授权情况
- (void)checkNotificationAuthorization {
    [MTPushService requestNotificationAuthorization:^(MTPushAuthorizationStatus status) {
        // run in main thread, you can custom ui
        MYLog(@"notification authorization status:%lu", status);
        [self alertNotificationAuthorization:status];
    }];
}
// 通知未授权时提示，是否进入系统设置允许通知，仅供参考
- (void)alertNotificationAuthorization:(MTPushAuthorizationStatus)status {
    if (status < MTPushAuthorizationStatusAuthorized) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"允许通知" message:@"是否进入设置允许通知？" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

@end
