//
//  PushTalkPlugin.h
//  PushTalk
//
//  Created by zhangqinghe on 13-12-13.
//
//

#import <Cordova/CDV.h>

static NSMutableDictionary *_jpushEventCache;

@interface MTPushEngagelab : CDVPlugin{

}

- (void)channelMTPushEngagelab:(CDVInvokedUrlCommand*)command;

# pragma mark - private

+(void)fireDocumentEvent:(NSString*)eventName jsString:(NSString*)jsString;

+(void)setupJPushSDK:(NSDictionary*)userInfo;

@end

static MTPushEngagelab *SharedJPushPlugin;

@interface NSDictionary (JPush)
-(NSString*)toJsonString;
@end

@interface NSString (JPush)
-(NSDictionary*)toDictionary;
@end


