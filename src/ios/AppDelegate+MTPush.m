

#import "AppDelegate+MTPush.h"
#import "MTPushEngagelabApi.h"

#import <objc/runtime.h>
#import <AdSupport/AdSupport.h>
#import <UserNotifications/UserNotifications.h>
#import "MTPushEngagelab.h"


@implementation AppDelegate(MTPush)

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
    [[MTPushEngagelabApi shareSingleton] applicationDidLaunch:notification];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[MTPushEngagelabApi shareSingleton] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

@end
