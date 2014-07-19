//
//  MapViewController.h
//  Where2Eat
//
//  Created by Tengyu Cai on 2014-07-18.
//
//

#import "CommonViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapViewController : CommonViewController <MKMapViewDelegate>

@property (nonatomic,strong) NSString *address;

@end
