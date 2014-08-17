//
//  MasterViewController.h
//  Where2Eat
//
//  Created by Tengyu Cai on 2014-07-17.
//
//

#import "CommonViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

typedef enum {
    APISourceYelp=1,
    APISourceDianPing=2
} APISource;

@interface MasterViewController : CommonViewController

@end
