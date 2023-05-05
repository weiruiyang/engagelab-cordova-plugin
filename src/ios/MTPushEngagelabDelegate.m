/********* MTPushEngagelab.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>


#import "MTPushEngagelabDelegate.h"
#import "MTPushEngagelabUtils.h"
#import "MTPushEngagelabChannels.h"
#import "MTPushService.h"

#import <UserNotifications/UserNotifications.h>


static MTPushEngagelabDelegate *SharedMPushPlugin;
@implementation MTPushEngagelabDelegate

static MTPushEngagelabDelegate *shareSingleton = nil;
 
+ (instancetype)shareSingleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareSingleton = [[super allocWithZone:NULL] init];
    });
    return shareSingleton;
}
 
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [MTPushEngagelabDelegate shareSingleton];
}
 
- (id)copyWithZone:(struct _NSZone *)zone {
    return [MTPushEngagelabDelegate shareSingleton];
}

//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
//  [MTPushService handleRemoteNotification:userInfo];
//  MYLog(@"iOS6及以下系统，收到通知:%@", [self logDic:userInfo]);
//}
//
//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
//    [MTPushService handleRemoteNotification:userInfo];
//    MYLog(@"iOS7及以上系统，收到通知:%@", [self logDic:userInfo]);
//    completionHandler(UIBackgroundFetchResultNewData);
//}


-(void)mtpNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler{

    NSDictionary * userInfo = notification.request.content.userInfo;

    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容

    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题

    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
      [MTPushService handleRemoteNotification:userInfo];
      MYLog(@"iOS10 前台收到远程通知:%@", [MTPushEngagelabUtils logDic:userInfo]);
    } else {
      // 判断为本地通知
      MYLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    [MTPushEngagelabChannels fireDocumentEvent:@"willPresentNotification" jsString:[[MTPushEngagelabUtils jpushFormatAPNSDic:userInfo] toJsonString]];

    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

-(void)mtpNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容

    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题

    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
      [MTPushService handleRemoteNotification:userInfo];
      MYLog(@"iOS10 收到远程通知:%@", [MTPushEngagelabUtils logDic:userInfo]);
    }
    else {
      // 判断为本地通知
      MYLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }

    [MTPushEngagelabChannels fireDocumentEvent:@"didReceiveNotificationResponse" jsString:[[MTPushEngagelabUtils jpushFormatAPNSDic:userInfo] toJsonString]];

    completionHandler();  // 系统要求执行这个方法
}


@end
