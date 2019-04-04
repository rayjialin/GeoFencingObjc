//
//  ViewController.m
//  WVCodingChallengeObjC
//
//  Created by ruijia lin on 3/21/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//

#import "ViewController.h"
#import "WVAnnotation.h"
#import "LocationSearchTable.h"
#import "UDDataManager.h"

@interface ViewController ()

-(void)removeAnnotation:(WVAnnotation *)annotation;
-(void)setupSearchBar;
-(void)handleSettings;
-(void)startMonitoringFor:(WVAnnotation *)annotation;
-(void)stopMonitoringFor:(WVAnnotation *)annotation;
-(void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
-(void)removeCircleOverlayFor:(WVAnnotation *)annotation;
-(void)addCircleOverlayFor:(WVAnnotation *)annotation;
-(void)updateCircleOverlays;
-(void)handleLongPressGesture:(UIGestureRecognizer *)gesture;
-(void)confirmAddLocationWithCompletion:(void (^)(NSString *result))block;
-(CLCircularRegion *)regionWith:(WVAnnotation *)annotation;
@end

#define METERS_PER_MILE 1609.34
@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // set up search bar in navigation bar
    [self setupSearchBar];
    // default distance for alert
    [UDDataManager getDistanceForAlert];
    
    // request location authorization
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager requestAlwaysAuthorization];
    // gesture recognizer
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPress.minimumPressDuration = 1.5;
    [self.mapView addGestureRecognizer:longPress];
    
    // display all annotations saved in userDefault
    NSMutableArray *arrayAnnotations = [UDDataManager unarchiveAndRestoreAll];
    for (WVAnnotation *annotation in arrayAnnotations) {
        [self.mapView addAnnotation:annotation];
        [self addCircleOverlayFor:annotation];
        [self startMonitoringFor:annotation];
    }
}

- (void)setupSearchBar {
    // Setup Search Table
    LocationSearchTable *locationSearchTable = [LocationSearchTable new];
    self.resultSearchController = [[UISearchController alloc] initWithSearchResultsController:locationSearchTable];
    self.resultSearchController.searchResultsUpdater = locationSearchTable;
    
    // Setup Search Bar
    UISearchBar *searchBar = self.resultSearchController.searchBar;
    [searchBar sizeToFit];
    searchBar.placeholder = @"Type in an address";
    self.navigationItem.titleView = searchBar;
    
    // Setup Bar Button Item
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(handleSettings)];
    [self.navigationItem setRightBarButtonItem:editButton animated:YES];
    //    [self.navigationController.navigationItem setRightBarButtonItem:editButton animated:YES];
    
    [self.resultSearchController setHidesNavigationBarDuringPresentation:NO];
    [self.resultSearchController setDimsBackgroundDuringPresentation:YES];
    [self setDefinesPresentationContext:YES];
    
    locationSearchTable.mapView = self.mapView;
    locationSearchTable.handleMapSearchDelegate = self;
}

- (void)handleLongPressGesture:(UIGestureRecognizer *)gesture {
    CGPoint touchAt = [gesture locationInView:self.mapView];
    CLLocationCoordinate2D touchAtCoordinate = [self.mapView convertPoint:touchAt toCoordinateFromView:self.mapView];
    
    [self confirmAddLocationWithCompletion:^(NSString *result) {
        WVAnnotation *annotation = [[WVAnnotation alloc] initWithTitle:result subtitle:@"pinned loncation" coordinate:touchAtCoordinate];
        [UDDataManager archiveAndSave:annotation];
        [self.mapView addAnnotation:annotation];
        [self addCircleOverlayFor:annotation];
        [self startMonitoringFor:annotation];
    }];
}

// MARK: completion block to handle gesture recognizer
- (void)confirmAddLocationWithCompletion:(void (^)(NSString *))block {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Name" message:@"Create a name for this location" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter name here";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *textField = alert.textFields[0].text;
        block(textField);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

// MARK: right navigation bar button item to edit minimum disance for alert
- (void)handleSettings {
    // default minimum distance for alert to 10 miles
    [UDDataManager setDistanceForAlert:10];
    
    UIViewController *vc = [UIViewController new];
    vc.preferredContentSize = CGSizeMake(self.view.frame.size.width / 2, self.view.frame.size.height / 4);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 2, self.view.frame.size.height / 4)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    [vc.view addSubview:pickerView];
    
    UIAlertController *editRadiusAlert = [UIAlertController alertControllerWithTitle:@"Minimum Distance for Alert" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [editRadiusAlert setValue:vc forKey:@"contentViewController"];
    
    [editRadiusAlert addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self updateCircleOverlays];
    }]];
    [editRadiusAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL]];
    [self presentViewController:editRadiusAlert animated:YES completion:NULL];
}

// MARK: geofencing region
- (CLCircularRegion *)regionWith:(WVAnnotation *)annotation {
    int distanceForAlert = [UDDataManager getDistanceForAlert];
    CLLocationDistance distanceInMeter = distanceForAlert * METERS_PER_MILE * 1.0;
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:annotation.coordinate radius:distanceInMeter identifier:annotation.identifier];
    [region setNotifyOnEntry:YES];
    return region;
}

// MARK: start monitoring
- (void)startMonitoringFor:(WVAnnotation *)annotation {
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            
            CLCircularRegion *fencedRegion = [self regionWith:annotation];
            [self.locationManager startMonitoringForRegion:fencedRegion];
        }else {
            NSString *message = @"Your location is saved but will only be activated once you grant permission to access the device location.";
            [self showAlertWithTitle:@"Warning" message:message];
        }
    }else {
        [self showAlertWithTitle:@"Error" message:@"Location monitoring is not supported on this device!"];
    }
}

// MARK: stop monitoring
- (void)stopMonitoringFor:(WVAnnotation *)annotation {
    for (CLCircularRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
    }
}

// MARK: show alert
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:NULL];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:NULL];
}

// MARK: remove annotations
- (void)removeAnnotation:(id)annotation {
    [self.mapView removeAnnotation:annotation];
}

// MARK: remove overlay
- (void)removeCircleOverlayFor:(WVAnnotation *)annotation {
    for (MKCircle *overlay in self.mapView.overlays) {
        CLLocationCoordinate2D coordinate = overlay.coordinate;
        if (coordinate.latitude == annotation.coordinate.latitude &&
            coordinate.longitude == annotation.coordinate.longitude) {
            [self.mapView removeOverlay:overlay];
        }
    }
}

// MARK: add overlay
- (void)addCircleOverlayFor:(WVAnnotation *)annotation {
    int distanceForAlert = [UDDataManager getDistanceForAlert];
    CLLocationCoordinate2D coordinate = annotation.coordinate;
    CLLocationDistance distanceInMeter = distanceForAlert * METERS_PER_MILE * 1.0;
    [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:coordinate radius:distanceInMeter]];
}

// MARK: update overlay
- (void)updateCircleOverlays {
    int distanceForAlert = [UDDataManager getDistanceForAlert];
    NSMutableArray *newOverlays = [[NSMutableArray alloc] init];
    CLLocationDistance distanceInMeter = distanceForAlert * METERS_PER_MILE * 1.0;
    
    for (MKCircle *overlay in self.mapView.overlays) {
        MKCircle *ol = [MKCircle circleWithCenterCoordinate:overlay.coordinate radius:distanceInMeter];
        [newOverlays addObject:ol];
    }
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView addOverlays:newOverlays];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *reuseId = @"favLocationId";
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    // create pin annotation with callout button to delete annotation
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
    [annotationView setCanShowCallout:YES];
    UIButton *removeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [removeButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [annotationView setLeftCalloutAccessoryView:removeButton];
    return annotationView;
}

// MARK: handle callout button action
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    WVAnnotation *annotation = view.annotation;
    [UDDataManager removeSingle:annotation];
    [self removeAnnotation:annotation];
    [self removeCircleOverlayFor:annotation];
    [self stopMonitoringFor:annotation];
}

// MARK: render overlay to show circular green overlay
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        circleRenderer.lineWidth = 1.0;
        circleRenderer.strokeColor = UIColor.greenColor;
        circleRenderer.fillColor = [UIColor.greenColor colorWithAlphaComponent:0.4];
        return circleRenderer;
    }
    return [[MKOverlayRenderer alloc] initWithOverlay:overlay];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager requestLocation];
    }
    [self.mapView setShowsUserLocation:YES];
}

// MARK: trigger when user's location changes
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations firstObject];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, span);
    [self.mapView setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location Manager failed with the following error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Monitoring failed for region with identifier: %@", error);
}

// delegate to pass annotation from location search table to viewController
- (void)dropPinZoomIn:(MKMapItem *)mapItem {
    WVAnnotation *annotation = [[WVAnnotation alloc] initWithTitle:mapItem.placemark.name subtitle:mapItem.placemark.title coordinate:mapItem.placemark.coordinate];
    [UDDataManager archiveAndSave:annotation];
    [self.mapView addAnnotation:annotation];
    [self addCircleOverlayFor:annotation];
    [self startMonitoringFor:annotation];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 10;
}

// MARK: display distance from 10 - 100 miles in picker view
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    int r = (int)row;
    int minimumDistance = (r + 1) * 10;
    NSString *rowName = [NSString stringWithFormat:@"%d miles", minimumDistance];
    return rowName;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    int r = (int)row;
    int minimumDistance = (r + 1) * 10;
    
    [UDDataManager setDistanceForAlert:minimumDistance];
}

@end
