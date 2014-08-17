//
//  MasterViewController.m
//  Where2Eat
//
//  Created by Tengyu Cai on 2014-07-17.
//
//

#import "MasterViewController.h"
#import "AppDelegate.h"
#import "LocationManager.h"
#import "OAuthConsumer.h"
#import "ANBlurredImageView.h"
#include <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#include <stdlib.h>
#include <math.h>
#import "MapViewController.h"
#import "FilterViewController.h"

@interface MasterViewController () <DPRequestDelegate>

@property (nonatomic,strong) AVAudioPlayer *effectPlayer;

@end

@implementation MasterViewController {
    
    APISource apiSource;
    
    UILabel *nameLabel;
    ANBlurredImageView *backgroundImage;
    UISlider *radiusSlider;
    UIImageView *yelpLogo;
    UIImageView *yelpRating;
    
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
    FilterViewController* filterVC;
    BOOL showFilter;
    NSMutableArray *filterNames;
    NSString* filterString;
    
    
    NSDictionary* filterMapping;
}

-(void)loadView
{
    [super loadView];
    isRunning=NO;
    //backgroundImage = [[ANBlurredImageView alloc] initWithImage:[UIImage imageNamed:@"clouds.jpg"]];
    //[self.view addSubview:backgroundImage];
//    self.view.backgroundColor = RGB(48, 29, 150);
    self.view.backgroundColor = RGB(240, 170, 80);
    
    nameLabel = [UILabel new];
    nameLabel.frame = (CGRect){0, SVB.size.height/3-80/2, 320, 80};
//    nameLabel.textColor = RGB(165, 230, 225);
    nameLabel.textColor = RGB(255,255,255);
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.text = @"SHAKE YOUR PHONE!";
    nameLabel.backgroundColor = RGBA(150, 150, 150, 0.3);
    nameLabel.font = [UIFont boldSystemFontOfSize:30];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.numberOfLines = 0;
    nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tabGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapAction:)];
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(filterAction:)];
    [nameLabel addGestureRecognizer:tabGR];
    [nameLabel addGestureRecognizer:panGR];
    [self.view addSubview:nameLabel];
    

    float y = CGRectGetMaxY(nameLabel.frame)+10;
    
    yelpLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miniMapLogo"]];
    yelpLogo.frame = (CGRect){SVB.size.width/3-yelpLogo.bounds.size.width, y, yelpLogo.bounds.size};
    //yelpLogo.backgroundColor = [UIColor blackColor];
    [yelpLogo sizeToFit];
    [self.view addSubview:yelpLogo];
    
    float x = CGRectGetMaxX(yelpLogo.frame) + 10;
    
    yelpRating = [[UIImageView alloc] initWithFrame:(CGRect){x, y, 3*yelpLogo.frame.size.width, yelpLogo.frame.size.height}];
    //yelpRating.backgroundColor = [UIColor blackColor];
    [self.view addSubview:yelpRating];
    
    [self displayRating:NO];
    
    UILabel *copyrightLabel = [UILabel new];
    copyrightLabel.frame = (CGRect){0,SVB.size.height-30, SVB.size.width, 30};
    //copyrightLabel.backgroundColor = [UIColor redColor];
    copyrightLabel.text = @"Developed by Alex Wang & Kevin Cai.";
    copyrightLabel.textColor = [UIColor grayColor];
    copyrightLabel.textAlignment = NSTextAlignmentCenter;
    copyrightLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:copyrightLabel];
    
    radiusSlider = [[UISlider alloc] initWithFrame:(CGRect){30, SVB.size.height-60, SVB.size.width-2*30, 30}];
    radiusSlider.minimumValue = 0.0f;
    radiusSlider.maximumValue = 1.0f;
    radiusSlider.tintColor = [UIColor grayColor];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"Radius"]!=nil){
        radiusSlider.value=[[[NSUserDefaults standardUserDefaults]objectForKey:@"Radius"] floatValue];
    } else {
        radiusSlider.value = sqrt(1000.0f/40000.0f);
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
    radius_filter = radiusSlider.value*radiusSlider.value*40000;

    
    filterVC=[FilterViewController new];
//    filterVC.view.frame=self.view.frame;
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"filterNames"]!=nil){
        filterNames = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"filterNames"]];
    } else {
        filterNames = [[NSMutableArray alloc]init];
    }
    filterVC.selectedFilters = filterNames;
    showFilter = NO;
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]  pathForResource:@"filter" ofType:@"json"]];
    filterMapping = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    
    
    NSLog(@"%i", apiSource);
    

}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setApiSourceAndFetch) name:@"shake" object:nil];
    
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
//        float newValue = slider.value/10;
//        slider.value = floor(newValue)*10;
        radius_filter = slider.value * slider.value * 40000;
        nameLabel.text = [NSString stringWithFormat:@"%0.0f m", radius_filter];
    }
    
    NSLog(@"Current distance: %f", radius_filter);
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:slider.value] forKey:@"Radius"];



}

-(void)sliderDidEndSliding:(UISlider*)slider
{
    nameLabel.text = selectedBusiness ? [NSString stringWithFormat:@"%@",selectedBusiness[@"name"]] : @"SHAKE YOUR PHONE!";
}


#pragma mark - Fetch

-(void)didFinishFetch
{
    [self activity:NO];
    NSLog(@"%@", resultDic);
    
    if (businesses.count == 0) {
        nameLabel.text = @"No restaurants nearby";
        selectedBusiness = NULL;
        return;
    }
    int randomNum = arc4random() % businesses.count;
    selectedBusiness = businesses[randomNum];
    [self fetchRatingImage];
    if (showFilter) {
        [self displayRating:NO];
    } else {
        [self displayRating:YES];
    }
    
    NSLog(@"%@", selectedBusiness[@"name"]);
    nameLabel.text= [NSString stringWithFormat:@"%@", selectedBusiness[@"name"]];//    [dic objectForKey:@"total"];
    
    
    
    if (apiSource == APISourceDianPing) {
        mapVC.address = businesses[randomNum][@"address"];
    } else if (apiSource == APISourceYelp) {
        mapVC.address = [businesses[randomNum][@"location"][@"display_address"] componentsJoinedByString:@" "];
    }
    
}


-(void)fetchRatingImage
{
    NSString *imageUrl;
    if (apiSource == APISourceDianPing) {
        imageUrl = selectedBusiness[@"rating_s_img_url"];
        yelpLogo.image = [UIImage imageNamed:@"dianpingLogo1"];
    } else if (apiSource == APISourceYelp) {
        imageUrl = selectedBusiness[@"rating_img_url"];
        yelpLogo.image = [UIImage imageNamed:@"miniMapLogo"];
    }
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:imageUrl]];
    yelpRating.image = [UIImage imageWithData:imageData];
    yelpRating.frame = rectWidth(yelpRating.frame, yelpRating.bounds.size.width);
    yelpRating.layer.borderColor = RGB(240, 170, 80).CGColor;
    yelpRating.layer.borderWidth = 3.0f;
}

- (void)setApiSourceAndFetch {
    
    if (isRunning) return;
    isRunning=YES;
    [self activity:YES];
    [self soundEffect];
    
    // set source API
    currentLocation = [LM currentLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (placemarks == nil)
             return;
         
         CLPlacemark *currentLocPlacemark = [placemarks objectAtIndex:0];
         NSLog(@"Current country: %@", [currentLocPlacemark country]);
         NSString *ISOCountryCode = [currentLocPlacemark ISOcountryCode];
         NSLog(@"Current country code: %@", ISOCountryCode);
         
         // Current country is China, HK, Macow or Taiwan
         if ([ISOCountryCode isEqualToString:@"CN"] ||
             [ISOCountryCode isEqualToString:@"HK"] ||
             [ISOCountryCode isEqualToString:@"MO"] ||
             [ISOCountryCode isEqualToString:@"TW"]) {
             
             apiSource = APISourceDianPing;
             
             // other countries
         } else {
             
             apiSource = APISourceYelp;
             
         }
         [self fetch];
     }];
}


- (void)fetch {
    
    isFirstPage=YES;
    businesses=[[NSMutableArray alloc]init];
    finishedPages=0;
    filterNames=[filterVC getFilters];
    NSMutableArray* mappedFilterNames=[[NSMutableArray alloc]init];
    for (int i=0;i<filterNames.count;i++){
        if (filterMapping[filterNames[i]]!=nil){
            mappedFilterNames[i]=filterMapping[filterNames[i]];
        } else {
            mappedFilterNames[i]=filterNames[i];
        }
    }
    filterString = [mappedFilterNames containsObject:@"All"] ? @"" : [[mappedFilterNames componentsJoinedByString:@","] lowercaseString];
    NSLog(filterString);
    [self saveFilters];
    
    // OAuthConsumer doesn't handle pluses in URL, only percent escapes
    // OK: http://api.yelp.com/v2/search?term=restaurants&location=new%20york
    // FAIL: http://api.yelp.com/v2/search?term=restaurants&location=new+york
    
    // OAuthConsumer has been patched to properly URL escape the consumer and token secrets
    
    
    currentLocation = [LM currentLocation];
    //[self setApiSource];
    NSLog(@"%i", apiSource);
    // Current country is China, HK, Macow or Taiwan
    if (apiSource == APISourceDianPing) {
        
        NSString *url = @"v1/business/find_businesses";
        NSString *params = [NSString stringWithFormat:@"latitude=%f&longitude=%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
        
        [[[AppDelegate instance] dpapi] requestWithURL:url paramsString:params delegate:self];
        
        
    } else if (apiSource == APISourceYelp) { // other country
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=restaurant&category_filter=%@&ll=%f,%f&radius_filter=%f&limit=20&mode=0",filterString,currentLocation.coordinate.latitude,currentLocation.coordinate.longitude,radius_filter]];
        
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
    
    
}

-(void)fetchNext{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=restaurant&category_filter=%@&ll=%f,%f&radius_filter=%f&limit=20&mode=0&offset=%d",filterString,currentLocation.coordinate.latitude,currentLocation.coordinate.longitude,radius_filter,finishedPages*20]];
    
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

-(void)displayRating:(BOOL)display
{
    if (display) {
        yelpLogo.alpha = 1;
        yelpRating.alpha = 1;
    } else {
        yelpLogo.alpha = 0;
        yelpRating.alpha = 0;
    }
}

-(void)mapAction:(UIGestureRecognizer*)gr
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
            [self displayRating:NO];
            nameLabel.frame = rectY(nameLabel.frame, 20);
            filterVC.view.frame=rectY(filterVC.view.frame, -(SVB.size.height-150));
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                mapVC.view.alpha = 1;
            }];
            showMap = YES;
            showFilter = NO;
        }];
        
    } else {
        
        [UIView animateWithDuration:0.5 animations:^{
            mapVC.view.alpha = 0;
            nameLabel.frame = rectY(nameLabel.frame, SVB.size.height/3-80/2);
        } completion:^(BOOL finished) {
            if (selectedBusiness) {
                [UIView animateWithDuration:0.3 animations:^{
                    [self displayRating:YES];
                }];
            }
            [mapVC removeFromParentViewController];
            showMap = NO;
        }];
        
    }
}

-(void)filterAction:(UIGestureRecognizer*)gr
{
    if (showMap) {
        return;
    }
    [self addChildViewController:filterVC];
    [filterVC didMoveToParentViewController:self];
    [self.view addSubview:filterVC.view];
    static CGPoint startPoint;
    static CGRect selectedRectFrame;
    if (gr.state == UIGestureRecognizerStateBegan) {
        
        gr.view.transform = CGAffineTransformIdentity;
        selectedRectFrame = gr.view.frame;
        startPoint = [gr locationInView:self.view];
        [UIView animateWithDuration:0.3 animations:^{
            [self displayRating:NO];
        }];
        
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        
        CGPoint newPoint = [gr locationInView:self.view];
        //gr.view.frame = rectX(gr.view.frame, selectedRectFrame.origin.x + newPoint.x - startPoint.x);
        if (newPoint.y >= startPoint.y) {
            gr.view.frame = rectY(gr.view.frame, selectedRectFrame.origin.y + newPoint.y - startPoint.y);
        }
        
        
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        
        CGPoint endPoint = [gr locationInView:self.view];
        if (endPoint.y >= (startPoint.y + gr.view.bounds.size.height)) {
            
            [self.view addSubview:filterVC.view];
            [UIView animateWithDuration:0.5 animations:^{
                
                gr.view.frame = rectY(gr.view.frame, SVB.size.height-150);
                filterVC.view.frame=rectY(filterVC.view.frame,0);
                
            } completion:^(BOOL finished) {
                
                showFilter = YES;
                
            }];
            
        } else {
            [self saveFilters];
            [UIView animateWithDuration:0.5 animations:^{
                
                gr.view.frame = (CGRect){0, SVB.size.height/3-80/2, 320, 80};
                filterVC.view.frame=rectY(filterVC.view.frame,-(SVB.size.height-150));
                
            } completion:^(BOOL finished) {
                
                showFilter = NO;
                [UIView animateWithDuration:0.3 animations:^{
                    if (selectedBusiness) {
                        [self displayRating:YES];
                    }
                }];
                
            }];
            
        }
        
    } else if (gr.state == UIGestureRecognizerStateFailed) {
        
    }
}

-(void)saveFilters{
    [[NSUserDefaults standardUserDefaults]setObject:[NSArray arrayWithArray:[filterVC getFilters]] forKey:@"filterNames"];
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
    [self activity:NO];
    nameLabel.text=@"Check Network Connection!!!";
    isRunning=false;
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


#pragma mark - DianPing API

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error {
    [self activity:NO];
    nameLabel.text=@"Check Network Connection!!!";
    isRunning=false;
	NSLog(@"%@", error);
}

- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result {
    resultDic = result;
	NSLog(@"%@", result[@"businesses"]);
    [self addToBusinesses];
    isRunning=false;
    [self didFinishFetch];
}


@end
