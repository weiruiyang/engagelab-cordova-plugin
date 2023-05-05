//
//  PushTalkPlugin.h
//  PushTalk
//
//  Created by zhangqinghe on 13-12-13.
//
//

#import <Cordova/CDV.h>

# define MYLog(fmt, ...) NSLog((@"[MTPushEngagelabPlugin] " fmt ""), ##__VA_ARGS__);


@interface MTPushEngagelabUtils{

}

// log NSSet with UTF8
// if not ,log will be \Uxxx
+ (NSString *)logDic:(NSDictionary *)dic;
+ (NSMutableDictionary *)jpushFormatAPNSDic:(NSDictionary *)dic ;

@end



@interface NSDictionary(MTPushEngagelab)
-(NSString*)toJsonString;
@end

@interface NSString (MTPushEngagelab)
-(NSDictionary*)toDictionary;
@end
