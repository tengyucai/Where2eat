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

@interface MasterViewController ()

@end

@implementation MasterViewController {
    UILabel *nameLabel;
    NSMutableData *_responseData;
    NSDictionary *dic;
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
    
    [self fetch];
    
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

-(void)didFinishFetch
{
    NSLog(@"%@", dic);
    nameLabel.text= [NSString stringWithFormat:@"%@",dic[@"businesses"][0][@"name"]];//    [dic objectForKey:@"total"];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


#pragma mark - Yelp API

- (void)fetch {
    
    // OAuthConsumer doesn't handle pluses in URL, only percent escapes
    // OK: http://api.yelp.com/v2/search?term=restaurants&location=new%20york
    // FAIL: http://api.yelp.com/v2/search?term=restaurants&location=new+york
    
    // OAuthConsumer has been patched to properly URL escape the consumer and token secrets
    
    NSURL *URL = [NSURL URLWithString:@"http://api.yelp.com/v2/search?term=restaurant&category_filter=chinese&ll=43.472199,-80.542064&radius_filter=1000&limit=20&mode=1"];
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
    dic = [NSJSONSerialization JSONObjectWithData:_responseData options:nil error:NULL];
    [self didFinishFetch];
}


@end
