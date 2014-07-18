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
    
    self.view.backgroundColor = RGB(30, 125, 215);
    
    UIImageView *yelpLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miniMapLogo"]];
    yelpLogoView.frame = (CGRect){SVB.size.width/2-yelpLogoView.bounds.size.width/2, SVB.size.height-yelpLogoView.bounds.size.height-5, yelpLogoView.bounds.size};
    //yelpLogoView.frame = (CGRect){S, SVB.size.height-40, yelpLogoView.bounds.size};
    //yelpLogoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    yelpLogoView.backgroundColor = CCOLOR;
    [self.view addSubview:yelpLogoView];
}
@end
