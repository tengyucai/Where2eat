//
//  SplashViewController.m
//  Where2Eat
//
//  Created by Tengyu Cai on 2014-07-18.
//
//

#import "SplashViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

-(void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = RGB(240, 170, 80);
    
    UILabel *splashLabel = [UILabel new];
    splashLabel.frame = SVF;
    splashLabel.text = @"WHERE\nTO\nEAT";
    splashLabel.textAlignment = NSTextAlignmentCenter;
    splashLabel.textColor = [UIColor whiteColor];
    splashLabel.numberOfLines = 0;
    splashLabel.lineBreakMode = NSLineBreakByWordWrapping;
    splashLabel.font = [UIFont boldSystemFontOfSize:60];
    splashLabel.backgroundColor = CCOLOR;
    [self.view addSubview:splashLabel];
    
}
@end
