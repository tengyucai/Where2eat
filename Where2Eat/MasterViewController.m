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
#include <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#include <stdlib.h>
#include <math.h>
#import "MapViewController.h"

@interface MasterViewController ()

@property (nonatomic,strong) AVAudioPlayer *effectPlayer;

@end

@implementation MasterViewController {
    
    UILabel *nameLabel;
    ANBlurredImageView *backgroundImage;
    UISlider *radiusSlider;
    MapViewController *mapVC;
    BOOL showMap;
    
    float radius_filter;
    
    NSMutableData *_responseData;
    NSDictionary *resultDic;
    BOOL isRunning;
    bool isLastPage,isFirstPage;
    int finishedPages,totalPages;
    CLLocation *currentLocation;
    NSMutableArray *businesses;
    NSDictionary *selectedBusiness;
}

-(void)loadView
{
    [super loadView];
    isRunning=NO;
    backgroundImage = [[ANBlurredImageView alloc] initWithImage:[UIImage imageNamed:@"clouds.jpg"]];
    //[self.view addSubview:backgroundImage];
//    self.view.backgroundColor = RGB(48, 29, 150);
    self.view.backgroundColor = RGB(240, 170, 80);
    
    nameLabel = [UILabel new];
    nameLabel.frame = (CGRect){0, SVB.size.height/3-80/2, 320, 80};
//    nameLabel.textColor = RGB(165, 230, 225);
    nameLabel.textColor = RGB(255,255,255);
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.text = @"Shake your phone!";
    nameLabel.backgroundColor = RGBA(150, 150, 150, 0.3);
    nameLabel.font = [UIFont boldSystemFontOfSize:30];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.numberOfLines = 0;
    nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailAction:)];
    [nameLabel addGestureRecognizer:gr];
    [self.view addSubview:nameLabel];
    
    UILabel *copyrightLabel = [UILabel new];
    copyrightLabel.frame = (CGRect){0,SVB.size.height-30, SVB.size.width, 30};
    //copyrightLabel.backgroundColor = [UIColor redColor];
    copyrightLabel.text = @"Developed by Alex Wang & Kevin Cai.";
    copyrightLabel.textColor = [UIColor grayColor];
    copyrightLabel.textAlignment = NSTextAlignmentCenter;
    copyrightLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:copyrightLabel];
    
    radiusSlider = [[UISlider alloc] initWithFrame:(CGRect){30, SVB.size.height-60, SVB.size.width-2*30, 30}];
    radiusSlider.minimumValue = 100.0f;
    radiusSlider.maximumValue = 40000.0f;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"Radius"]!=nil){
        radiusSlider.value=[[[NSUserDefaults standardUserDefaults]objectForKey:@"Radius"] floatValue];
    } else {
        radiusSlider.value = 1000.0f;
    }
    [radiusSlider addTarget:self
                     action:@selector(getSlidervalue:)
           forControlEvents:UIControlEventValueChanged];
    [radiusSlider addTarget:self
                  action:@selector(sliderDidEndSliding:)
           forControlEvents:(UIControlEventTouchUpOutside|UIControlEventTouchUpInside)];
    [self.view addSubview:radiusSlider];
    
    mapVC = [MapViewController new];
    
    // change later, use NSUserDefault
    radius_filter = radiusSlider.value;
    
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

#pragma UISlider


-(void)getSlidervalue:(UISlider*)slider
{
    if ([slider isEqual:radiusSlider]) {
        float newValue = slider.value/10;
        slider.value = floor(newValue)*10;
        radius_filter = slider.value;
        nameLabel.text = [NSString stringWithFormat:@"%0.0f m", slider.value];
    }
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:slider.value] forKey:@"Radius"];
    NSLog(@"Current distance: %f", slider.value);
}

-(void)sliderDidEndSliding:(UISlider*)slider
{
    nameLabel.text = selectedBusiness ? [NSString stringWithFormat:@"%@",selectedBusiness[@"name"]] : @"Shake your phone!";
}


#pragma mark - Fetch

-(void)didFinishFetch
{
    [self activity:NO];
    
    NSLog(@"%@", resultDic);
    if (businesses.count == 0) {
        nameLabel.text = @"No restaurants nearby";
        return;
    }
    int randomNum = arc4random() % businesses.count;
    selectedBusiness = businesses[randomNum];
    nameLabel.text= [NSString stringWithFormat:@"%@", selectedBusiness[@"name"]];//    [dic objectForKey:@"total"];
    mapVC.address= [businesses[randomNum][@"location"][@"display_address"] componentsJoinedByString:@" "];
}



- (void)fetch {
    if (isRunning) return;
    isRunning=YES;
    isFirstPage=YES;
    businesses=[[NSMutableArray alloc]init];
    finishedPages=0;
    [self activity:YES];
    [self soundEffect];
    // OAuthConsumer doesn't handle pluses in URL, only percent escapes
    // OK: http://api.yelp.com/v2/search?term=restaurants&location=new%20york
    // FAIL: http://api.yelp.com/v2/search?term=restaurants&location=new+york
    
    // OAuthConsumer has been patched to properly URL escape the consumer and token secrets
    currentLocation = [LM currentLocation];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=restaurant&category_filter=chinese&ll=%f,%f&radius_filter=%f&limit=20&mode=0",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude,radius_filter]];
    
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

-(void)fetchNext{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=restaurant&category_filter=chinese&ll=%f,%f&radius_filter=%f&limit=20&mode=0&offset=%d",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude,radius_filter,finishedPages*20]];
    
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

-(void)addToBusinesses{
    [businesses addObjectsFromArray:resultDic[@"businesses"]];
}

#pragma mark - Action

-(void)soundEffect
{
//(NSString *)effectName volume:(float)volume{
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"paper_flipping_page" withExtension:@"aiff"];
    
    self.effectPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    
    _effectPlayer.volume = 1;
    [_effectPlayer prepareToPlay];
    [_effectPlayer play];
    
}

-(void)detailAction:(UIGestureRecognizer*)gr
{
    if (!showMap) {
        
//        mapVC = [MapViewController new];
        //mapVC.address = @"200 University Avenue, Waterloo, ON";
        float y = 20+nameLabel.bounds.size.height;
        mapVC.view.frame = (CGRect){0, y, SVB.size.width, SVB.size.height-y-70};
        mapVC.view.alpha = 0;
        [self addChildViewController:mapVC];
        [self.view addSubview:mapVC.view];
        [mapVC didMoveToParentViewController:self];
        
        [UIView animateWithDuration:0.5 animations:^{
            nameLabel.frame = rectY(nameLabel.frame, 20);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                mapVC.view.alpha = 1;
            }];
            showMap = YES;
        }];
        
    } else {
        
        [UIView animateWithDuration:0.5 animations:^{
            mapVC.view.alpha = 0;
            nameLabel.frame = rectY(nameLabel.frame, SVB.size.height/3-60/2);
        } completion:^(BOOL finished) {
            [mapVC removeFromParentViewController];
            showMap = NO;
        }];
        
    }
    
    
}

#pragma mark - Yelp API


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
    finishedPages++;
    resultDic = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:NULL];
    if (isFirstPage){
        NSInteger num=[resultDic[@"total"] integerValue];
        totalPages=MIN((num-1) / 20+1, 5);
    }
    [self addToBusinesses];
//    [self didFinishFetch];
    if (finishedPages<totalPages){
        [self fetchNext];
    } else {
        isRunning=false;
        for (int i=0;i<businesses.count;i++){
            NSLog(businesses[i][@"name"]);
        }
        [self didFinishFetch];
    }
}


@end
