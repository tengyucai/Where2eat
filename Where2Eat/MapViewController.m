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
}

-(void)loadView{
    [super loadView];
    
    mapView = [[MKMapView alloc]init];
    mapView.frame = self.view.bounds;
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:mapView];
    
    CLGeocoder *gecoder = [[CLGeocoder alloc]init];
    [gecoder geocodeAddressString:_address completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (placemarks.count>0) {
            CLPlacemark *placemark = placemarks[0];
            
            MKPointAnnotation *annotation = [MKPointAnnotation new];
            annotation.coordinate = placemark.location.coordinate;
            [mapView addAnnotation:annotation];
            
            mapView.region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(0.01, 0.01));
        }
        
    }];
    
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
