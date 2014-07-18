//
//  MasterViewController.m
//  Where2Eat
//
//  Created by Tengyu Cai on 2014-07-17.
//
//

#import "MasterViewController.h"
#import "LocationManager.h"

@interface MasterViewController ()

@end

@implementation MasterViewController {
    UILabel *nameLabel;
}

-(void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor purpleColor];
    
    nameLabel = [UILabel new];
    nameLabel.frame = (CGRect){SVB.size.width/2-100/2, SVB.size.height/2-40/2, 100, 40};
    nameLabel.textColor = RGB(165, 230, 225);
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.text = @"Fetch...";
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.backgroundColor = [UIColor blackColor];
    [self.view addSubview:nameLabel];
    
    
    
    [LM startUpdatingLocation];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSDateFormatter *dateF = [[NSDateFormatter alloc] init];
    [dateF setDateStyle:NSDateFormatterFullStyle]; //this format will be according to your own.
    
    NSDate *todayDate = [NSDate date];  //[dateF dateFromString: @"5-MAY-2011 00:00:00 +0000"]; //please note, this date format must match the NSDateFormatter Style, or else return null.
    
    NSTimeInterval inter = [todayDate timeIntervalSince1970];
    
    NSLog(@"%f", inter);
}
//
//- (void) viewWillAppear:(BOOL)animated
//{
//    [shakeView becomeFirstResponder];
//    [super viewWillAppear:animated];
//}
//- (void) viewWillDisappear:(BOOL)animated
//{
//    [shakeView resignFirstResponder];
//    [super viewWillDisappear:animated];
//}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ( event.subtype == UIEventSubtypeMotionShake )
    {
        // Put in code here to handle shake
        
    }
    
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
