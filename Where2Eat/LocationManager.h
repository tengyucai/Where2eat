//
//  LocationManager.h
//  Where2Eat
//
//  Created by Tengyu Cai on 2014-07-17.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define LM [LocationManager sharedInstance]

@interface LocationManager : NSObject

+(LocationManager *) sharedInstance;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

- (void)startUpdatingLocation;

@end
