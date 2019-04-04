//
//  ViewController.h
//  WVCodingChallengeObjC
//
//  Created by ruijia lin on 3/21/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/Mapkit.h>

@protocol HandleMapSearch <NSObject>
- (void) dropPinZoomIn:(MKMapItem *)mapItem;
@end

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, HandleMapSearch, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) UISearchController *resultSearchController;
//@property (nonatomic, assign) int minimumDistanceForAlert;

@end

