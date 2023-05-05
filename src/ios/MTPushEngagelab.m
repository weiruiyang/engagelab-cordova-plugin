/********* MTPushEngagelab.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>


#import "AppDelegate+MTPush.h"
#import "MTPushEngagelab.h"
#import "MTPushService.h"
#import "MTPushEngagelabChannels.h"
#import "MTPushEngagelabDelegate.h"
#import "MTPushEngagelabApi.h"
#import "MTPushEngagelabUtils.h"


#import <objc/runtime.h>
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <UserNotifications/UserNotifications.h>



@implementation MTPushEngagelab

- (void)channelMTPushEngagelab:(CDVInvokedUrlCommand*)command
{
    [[MTPushEngagelabApi shareSingleton] channelMTPushEngagelab:command];
}



#ifdef __CORDOVA_4_0_0

- (void)pluginInitialize {
    MYLog(@"### pluginInitialize ");
    [self initPlugin];
}

#else

- (CDVPlugin*)initWithWebView:(WKWebView*)theWebView{
    MYLog(@"### initWithWebView ");
    if (self=[super initWithWebView:theWebView]) {
    }
    [self initPlugin];
    return self;
}

#endif


-(void)initPlugin{
    [MTPushEngagelabChannels initPlugin:self];
}

@end
