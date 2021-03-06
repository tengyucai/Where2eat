//
//  MapViewController.m
//  Where2Eat
//
//  Created by Tengyu Cai on 2014-07-18.
//
//

#import "MapViewController.h"
#import "LocationManager.h"

@interface MapViewController ()

@end

@implementation MapViewController {
    MKMapView *mapView;
    UILabel *locationLabel;
    CLPlacemark* placemark;
}

-(void)loadView{
    [super loadView];
    
    mapView = [[MKMapView alloc]init];
    mapView.frame = self.view.bounds;
    mapView.delegate = self;
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:mapView];
    
    locationLabel = [UILabel new];
    locationLabel.frame = (CGRect){0, 0, SVB.size.width, 50};
    locationLabel.backgroundColor = RGBA(150, 150, 150, 0.5);
    locationLabel.textColor = [UIColor whiteColor];
    locationLabel.textAlignment = NSTextAlignmentCenter;
    locationLabel.numberOfLines = 0;
    locationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    locationLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAppleMaps:)];
    [locationLabel addGestureRecognizer:gr];
    [mapView addSubview:locationLabel];
    
    [self updateMap];
    
}

-(void)updateMap
{
    CLGeocoder *gecoder = [[CLGeocoder alloc]init];
    [gecoder geocodeAddressString:_address completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (placemarks.count>0) {
            placemark = placemarks[0];
            
            MKPointAnnotation *annotation = [MKPointAnnotation new];
            annotation.coordinate = placemark.location.coordinate;
            annotation.title = _address;
            MKPointAnnotation *myLocation = [MKPointAnnotation new];
            myLocation.coordinate = [LM currentLocation].coordinate;
            myLocation.title = @"My location";
            [mapView removeAnnotations:[mapView annotations]];
            [mapView addAnnotation:annotation];
            //[mapView addAnnotation:myLocation];
            [mapView setShowsUserLocation:YES];
            mapView.region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(0.02, 0.02));
            //mapView.exclusiveTouch=NO;
        }
        
    }];
    locationLabel.text = _address;
}

-(void)setAddress:(NSString *)address
{
    _address = address;
    [self updateMap];
}

#pragma mark - MapView delegate

-(MKAnnotationView*)mapView:(MKMapView *)_mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if (annotation==mapView.userLocation)
        return nil;
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:@"xxx"];
    if (!pin) {
        pin=[[MKPinAnnotationView alloc]
         initWithAnnotation:annotation reuseIdentifier:@"xxx"];
    }
    //pin.annotation = annotation;
    pin.animatesDrop = YES;
    pin.pinColor = MKPinAnnotationColorPurple;
    pin.canShowCallout= YES;

    
    return pin;
}

#pragma mark - Gestures

-(void)openAppleMaps:(UIGestureRecognizer*)gr{
    MKPlacemark *tmpPlacemark = [[MKPlacemark alloc] initWithCoordinate:placemark.location.coordinate addressDictionary:nil];
    MKMapItem *item=[[MKMapItem alloc]initWithPlacemark:tmpPlacemark];
    item.name=_address;
    [item openInMapsWithLaunchOptions:nil];
}

@end
