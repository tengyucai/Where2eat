//
//  MapViewController.m
//  Where2Eat
//
//  Created by Tengyu Cai on 2014-07-18.
//
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController {
    MKMapView *mapView;
    UILabel *locationLabel;
}

-(void)loadView{
    [super loadView];
    
    mapView = [[MKMapView alloc]init];
    mapView.frame = self.view.bounds;
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:mapView];
    
    locationLabel = [UILabel new];
    locationLabel.frame = (CGRect){0, 0, SVB.size.width, 50};
    locationLabel.backgroundColor = RGBA(150, 150, 150, 0.5);
    locationLabel.textColor = [UIColor whiteColor];
    locationLabel.textAlignment = NSTextAlignmentCenter;
    locationLabel.numberOfLines = 0;
    locationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [mapView addSubview:locationLabel];
    
    [self updateMap];
    
}

-(void)updateMap
{
    CLGeocoder *gecoder = [[CLGeocoder alloc]init];
    [gecoder geocodeAddressString:_address completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (placemarks.count>0) {
            CLPlacemark *placemark = placemarks[0];
            
            MKPointAnnotation *annotation = [MKPointAnnotation new];
            annotation.coordinate = placemark.location.coordinate;
            [mapView removeAnnotations:[mapView annotations]];
            [mapView addAnnotation:annotation];
            
            mapView.region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(0.01, 0.01));
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
    
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:@"xxx"];
    if (!pin) {
        pin = [MKPinAnnotationView new];
    }
    
    pin.annotation = annotation;
    
    return pin;
}

@end
