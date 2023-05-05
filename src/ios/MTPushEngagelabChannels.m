#import "MTPushEngagelab.h"
#import "MTPushService.h"
#import "MTPushEngagelabUtils.h"

static CDVPlugin *SharedJPushPlugin;
@implementation MTPushEngagelabChannels

static NSMutableArray *_eventCache;

+(void)initPlugin:(CDVPlugin*)mtPush {
    if (!SharedJPushPlugin) {
        SharedJPushPlugin = mtPush;
    }
    [MTPushEngagelabChannels eventCacheCallBackChannel];
}

+(void) eventCacheCallBackChannel {

    MYLog(@"### eventCacheCallBackChannel ");
    if (nil != _eventCache) {
        MYLog(@"### eventCacheCallBackChannel _eventCache");
        for (NSMutableDictionary *data in _eventCache) {
            [MTPushEngagelabChannels fireDocumentEvent:data[@"event_name"] jsString:data[@"event_data"]];
        }
        MYLog(@"eventCacheCallBackChannel");
        [_eventCache removeAllObjects];
    }
}

+(void)fireDocumentEvent:(NSString*)eventName jsString:(NSString*)jsString{
    NSMutableDictionary *data = @{}.mutableCopy;
    data[@"event_name"] = eventName;
    data[@"event_data"] = jsString;

    NSString *toC = [data toJsonString];
    MYLog(@"toC：%@",toC);
    if (SharedJPushPlugin) {
        dispatch_async(dispatch_get_main_queue(), ^{

            //      [SharedJPushPlugin.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireDocumentEvent('MTPushEngagelab.onMTCommonReceiver',%@)", toC]];
            [SharedJPushPlugin.commandDelegate evalJs:[NSString stringWithFormat:@"window.plugins.mTPushEngagelab.onMTCommonReceiver(%@);", toC]];

        });
        return;
    } else{
             if (nil == _eventCache) {
                 _eventCache =  [[NSMutableArray alloc] init];
             }
             MYLog(@"toCache00：%@",data);
             [_eventCache addObject:data];
             MYLog(@"toCache11：%@",data);
    }
}


+(void)sendPluginResult:(CDVPluginResult*)result callbackId:(NSString*)callbackId{
    if (SharedJPushPlugin) {
        [SharedJPushPlugin.commandDelegate sendPluginResult:result callbackId:callbackId];
    }else{
        MYLog(@"sendPluginResult SharedJPushPlugin is null");
    }
}
@end
