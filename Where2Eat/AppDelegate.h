//
//  AppDelegate.h
//  Where2Eat
//
//  Created by Tengyu Cai on 2014-07-17.
//
//

#import <UIKit/UIKit.h>
#import "DPAPI.h"

@class PaintingWindow;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

//@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PaintingWindow *window;

// DianPingAPI
@property (readonly, nonatomic) DPAPI *dpapi;
@property (strong, nonatomic) NSString *appKey;
@property (strong, nonatomic) NSString *appSecret;

+(AppDelegate*)instance;

@end
