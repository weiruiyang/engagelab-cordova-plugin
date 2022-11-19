

#import "AppDelegate+MTPush.h"
#import "MTPushService.h"
#import <objc/runtime.h>
#import <AdSupport/AdSupport.h>
#import <UserNotifications/UserNotifications.h>
#import "MTPushEngagelab.h"

static void *strKey = &strKey;

@implementation AppDelegate(MTPush)

+ (void)setLaunchOptions:(NSDictionary *)launchOptions {
  objc_setAssociatedObject(self, & strKey, launchOptions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSDictionary *)launchOptions {
  return objc_getAssociatedObject(self, &strKey);
}

+(void)load{
    Method origin1;
    Method swizzle1;
    origin1  = class_getInstanceMethod([self class],@selector(init));
    swizzle1 = class_getInstanceMethod([self class], @selector(init_plus));
    method_exchangeImplementations(origin1, swizzle1);
}

-(instancetype)init_plus{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidLaunch:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    return [self init_plus];
}


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
      [MTPushService registerForRemoteNotificationConfig:entity delegate:self];


    // 检测通知授权情况。可选项，不一定要放在此处，可以运行一定时间后再调用
    [self performSelector:@selector(checkNotificationAuthorization) withObject:nil afterDelay:10];


NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
[defaultCenter addObserver:self
  selector:@selector(networkDidReceiveMessage:)
      name:kMTCNetworkDidReceiveMessageNotification
    object:nil];

    AppDelegate.launchOptions = notification.userInfo;
//      self.launchOptions = notification.userInfo;


}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const unsigned int *tokenBytes = [deviceToken bytes];
    NSString *tokenString = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"Device Token: %@", tokenString);
    [MTPushService registerDeviceToken:deviceToken];
}

//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
//  [MTPushService handleRemoteNotification:userInfo];
//  NSLog(@"iOS6及以下系统，收到通知:%@", [self logDic:userInfo]);
//}
//
//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
//    [MTPushService handleRemoteNotification:userInfo];
//    NSLog(@"iOS7及以上系统，收到通知:%@", [self logDic:userInfo]);
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
      NSLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
    } else {
      // 判断为本地通知
      NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    [MTPushEngagelab fireDocumentEvent:@"willPresentNotification" jsString:[[self jpushFormatAPNSDic:userInfo] toJsonString]];

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
      NSLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
    }
    else {
      // 判断为本地通知
      NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }

    [MTPushEngagelab fireDocumentEvent:@"didReceiveNotificationResponse" jsString:[[self jpushFormatAPNSDic:userInfo] toJsonString]];

    completionHandler();  // 系统要求执行这个方法
}

//客户端收到自定义消息
- (void)networkDidReceiveMessage:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  NSString *title = [userInfo valueForKey:@"title"];
  NSString *content = [userInfo valueForKey:@"content"];
  NSDictionary *extra = [userInfo valueForKey:@"extras"];
  NSUInteger messageID = [[userInfo valueForKey:@"_j_msgid"] unsignedIntegerValue];

  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

  [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];

  NSString *currentContent = [NSString
      stringWithFormat:
          @"收到自定义消息:%@\ntitle:%@\ncontent:%@\nextra:%@\nmessage:%ld\n",
          [NSDateFormatter localizedStringFromDate:[NSDate date]
                                         dateStyle:NSDateFormatterNoStyle
                                         timeStyle:NSDateFormatterMediumStyle],
                              title, content, [self logDic:extra],(unsigned long)messageID];
  NSLog(@"%@", currentContent);

    [MTPushEngagelab fireDocumentEvent:@"networkDidReceiveMessage" jsString:[[self jpushFormatAPNSDic:userInfo] toJsonString]];

}


#pragma mark - 通知权限引导

// 检测通知权限授权情况
- (void)checkNotificationAuthorization {
  [MTPushService requestNotificationAuthorization:^(MTPushAuthorizationStatus status) {
    // run in main thread, you can custom ui
    NSLog(@"notification authorization status:%lu", status);
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

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
  if (![dic count]) {
    return nil;
  }
  NSString *tempStr1 =
      [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                   withString:@"\\U"];
  NSString *tempStr2 =
      [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
  NSString *tempStr3 =
      [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
  NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
  NSString *str =
      [NSPropertyListSerialization propertyListFromData:tempData
                                       mutabilityOption:NSPropertyListImmutable
                                                 format:NULL
                                       errorDescription:NULL];
  return str;
}

- (NSMutableDictionary *)jpushFormatAPNSDic:(NSDictionary *)dic {
  NSMutableDictionary *extras = @{}.mutableCopy;
  for (NSString *key in dic) {
    if([key isEqualToString:@"_j_business"]      ||
       [key isEqualToString:@"_j_msgid"]         ||
       [key isEqualToString:@"_j_uid"]           ||
       [key isEqualToString:@"actionIdentifier"] ||
       [key isEqualToString:@"aps"]) {
      continue;
    }
    extras[key] = dic[key];
  }
  NSMutableDictionary *formatDic = dic.mutableCopy;
  formatDic[@"extras"] = extras;
  return formatDic;
}

@end
