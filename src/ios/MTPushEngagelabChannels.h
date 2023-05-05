//
//  PushTalkPlugin.h
//  PushTalk
//
//  Created by zhangqinghe on 13-12-13.
//
//

#import <Cordova/CDV.h>


@interface MTPushEngagelabChannels{

}

+(void)initPlugin:(CDVPlugin*)mtPush ;
+(void)fireDocumentEvent:(NSString*)eventName jsString:(NSString*)jsString;
+(void)sendPluginResult:(CDVPluginResult*)result callbackId:(NSString*)callbackId;
@end


