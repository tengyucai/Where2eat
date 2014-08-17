//
//  AppDelegate.m
//  Where2Eat
//
//  Created by Tengyu Cai on 2014-07-17.
//
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "CommonViewController.h"
#import "PaintingWindow.h"
#import "SplashViewController.h"

@implementation AppDelegate {
    SplashViewController *splashVC;
    MasterViewController *masterVC;
}


+ (AppDelegate *)instance {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (id)init {
	self = [super init];
    if (self) {
        _dpapi = [[DPAPI alloc] init];
		_appKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"appkey"];
		if (_appKey.length<1) {
			_appKey = kDPAppKey;
		}
		_appSecret = [[NSUserDefaults standardUserDefaults] valueForKey:@"appsecret"];
		if (_appSecret.length<1) {
			_appSecret = kDPAppSecret;
		}
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[PaintingWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //application.applicationSupportsShakeToEdit = YES;
    
    self.window.rootViewController = [CommonViewController new];
    
    splashVC = [SplashViewController new];
    [self.window.rootViewController addChildViewController:splashVC];
    [self.window.rootViewController.view addSubview:splashVC.view];
    [splashVC didMoveToParentViewController:self.window.rootViewController];
    
    masterVC = [MasterViewController new];
    [self.window.rootViewController addChildViewController:masterVC];
    [self.window.rootViewController.view addSubview:masterVC.view];
    [masterVC didMoveToParentViewController:self.window.rootViewController];
    masterVC.view.alpha = 0;
    
     [self performSelector:@selector(transitionFromSplash) withObject:nil afterDelay:1.5];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


-(void)transitionFromSplash{
    
    [UIView animateWithDuration:1.5 animations:^{
        masterVC.view.alpha = 1.0;
        splashVC.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [splashVC willMoveToParentViewController:nil];
        [splashVC removeFromParentViewController];
        [splashVC.view removeFromSuperview];
    }];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - DianPingAPI

- (void)setAppKey:(NSString *)appKey {
	_appKey = appKey;
	[[NSUserDefaults standardUserDefaults] setValue:appKey forKey:@"appkey"];
}

- (void)setAppSecret:(NSString *)appSecret {
	_appSecret = appSecret;
	[[NSUserDefaults standardUserDefaults] setValue:appSecret forKey:@"appsecret"];
}


@end
