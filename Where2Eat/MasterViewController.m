//
//  MasterViewController.m
//  Where2Eat
//
//  Created by Tengyu Cai on 2014-07-17.
//
//

#import "MasterViewController.h"
#import "LocationManager.h"
#import "OAuthConsumer.h"
#import "ANBlurredImageView.h"
#include <stdlib.h>

@interface MasterViewController ()

@end

@implementation MasterViewController {
    UILabel *nameLabel;
    ANBlurredImageView *backgroundImage;
    UISlider *radiusSlider;
    
    NSMutableData *_responseData;
    NSDictionary *resultDic;
}

-(void)loadView
{
    [super loadView];
    
    backgroundImage = [[ANBlurredImageView alloc] initWithImage:[UIImage imageNamed:@"clouds.jpg"]];
    [self.view addSubview:backgroundImage];
    
    nameLabel = [UILabel new];
    nameLabel.frame = (CGRect){0, SVB.size.height/3-60/2, 320, 60};
    nameLabel.textColor = RGB(165, 230, 225);
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.text = @"Shake your phone!";
    nameLabel.backgroundColor = RGBA(100, 100, 100, 0.3);
    nameLabel.font = [UIFont boldSystemFontOfSize:20];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.numberOfLines = 0;
    nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //nameLabel.backgroundColor = [UIColor blackColor];
    [self.view addSubview:nameLabel];
    
    UILabel *copyrightLabel = [UILabel new];
    copyrightLabel.frame = (CGRect){0,SVB.size.height-30, SVB.size.width, 30};
    //copyrightLabel.backgroundColor = [UIColor redColor];
    copyrightLabel.text = @"Developed by Alex Wang & Kevin Cai.";
    copyrightLabel.textColor = [UIColor grayColor];
    copyrightLabel.textAlignment = NSTextAlignmentCenter;
    copyrightLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:copyrightLabel];
    
    radiusSlider = [[UISlider alloc] initWithFrame:(CGRect){30, SVB.size.height-60, SVB.size.width/2-30/2, 30}];
    
    
    [LM startUpdatingLocation];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetch) name:@"shake" object:nil];
    
//    NSDateFormatter *dateF = [[NSDateFormatter alloc] init];
//    [dateF setDateStyle:NSDateFormatterFullStyle];
//    NSDate *todayDate = [NSDate date];
//    NSTimeInterval inter = [todayDate timeIntervalSince1970];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [backgroundImage setBlurTintColor:RGBA(0, 0, 0, 0.8)];
    [backgroundImage generateBlurFramesWithCompletion:^{
        [backgroundImage blurInAnimationWithDuration:0.25f];
    }];
}


#pragma mark - Action

-(void)didFinishFetch
{
    [self activity:NO];
    
    NSLog(@"%@", resultDic);
    NSArray *restaurants = resultDic[@"businesses"];
    if (restaurants.count == 0) {
        nameLabel.text = @"No restaurants nearby";
        return;
    }
    int randomNum = arc4random() % restaurants.count;
    nameLabel.text= [NSString stringWithFormat:@"%@",resultDic[@"businesses"][randomNum][@"name"]];//    [dic objectForKey:@"total"];
}




#pragma mark - Yelp API

- (void)fetch {
    [self activity:YES];
    
    // OAuthConsumer doesn't handle pluses in URL, only percent escapes
    // OK: http://api.yelp.com/v2/search?term=restaurants&location=new%20york
    // FAIL: http://api.yelp.com/v2/search?term=restaurants&location=new+york
    
    // OAuthConsumer has been patched to properly URL escape the consumer and token secrets
    CLLocation *currentLocation = [LM currentLocation];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=restaurant&category_filter=chinese&ll=%f,%f&radius_filter=1000&limit=20&mode=1",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude]];
    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:@"cGIReDsqxtdpQ-XLLHMXHw" secret:@"WoAwZGlr-zziq8G5mJwrw-m4dNs"];
    OAToken *token = [[OAToken alloc] initWithKey:@"Q8-qoen7t2h_7iIDWJ5wxcrnuq_Y7UVt" secret:@"nCWjMw9093GFp4LIDIk_ARtALGA"];
    id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init] ;
    NSString *realm = nil;
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:realm
                                                          signatureProvider:provider];
    [request prepare];
    
    _responseData = [[NSMutableData alloc] init];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
    /*NSString *STR = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     NSLog(STR);
     NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:nil error:NULL];
     NSLog(data);
     //NSLog([[_responseData yajl_JSON]yajl_JSONStringWithOptions:YAJLGenOptionsBeautify indentString:@"  "]);
     int i=1;*/
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error: %@, %@", [error localizedDescription], [error localizedFailureReason]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    resultDic = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:NULL];
    [self didFinishFetch];
}


@end
