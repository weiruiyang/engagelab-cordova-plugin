/********* MTPushEngagelab.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>


#import "MTPushService.h"
#import "MTPushEngagelabUtils.h"
#import "MTPushEngagelabSelector.h"
#import "MTPushEngagelabChannels.h"

@implementation MTPushEngagelabSelector


static MTPushEngagelabSelector *shareSingleton = nil;
 
+ (instancetype)shareSingleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareSingleton = [[super allocWithZone:NULL] init];
    });
    return shareSingleton;
}
 
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [MTPushEngagelabSelector shareSingleton];
}
 
- (id)copyWithZone:(struct _NSZone *)zone {
    return [MTPushEngagelabSelector shareSingleton];
}


-(void)initSelector {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
      selector:@selector(networkDidReceiveMessage:)
          name:kMTCNetworkDidReceiveMessageNotification
        object:nil];

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
                              title, content, [MTPushEngagelabUtils logDic:extra],(unsigned long)messageID];
    MYLog(@"%@", currentContent);

    [MTPushEngagelabChannels fireDocumentEvent:@"networkDidReceiveMessage" jsString:[[MTPushEngagelabUtils jpushFormatAPNSDic:userInfo] toJsonString]];

}

@end
