//
//  AppDelegate.m
//  WVCodingChallengeObjC
//
//  Created by ruijia lin on 3/21/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//

#import "AppDelegate.h"
#import "UDDataManager.h"
#import "WVAnnotation.h"

@interface AppDelegate ()

@property (nonatomic, retain) NSTimer *regionDetectionTimer;
@property (nonatomic, retain) NSMutableArray *annotationList;

- (void)registerNotification;
- (void)handleNotificationFor;
- (void)handleITimerInvalidate;
//- (void)sortByDistance;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // initialize location list
    self.annotationList = [[NSMutableArray alloc] init];
    
    // get location authorization
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager requestAlwaysAuthorization];
    
    // Register for local notification
    [self registerNotification];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllPendingNotificationRequests];
    [center removeAllDeliveredNotifications];
}

- (void)registerNotification {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionSound + UNAuthorizationOptionAlert + UNAuthorizationOptionBadge + UNAuthorizationOptionCarPlay;
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"%@", error.description);
        }
        if (granted) {
            NSLog(@"yeaahhh~");
        }
    }];
}

// MARK: handle notification when user enters the favorite location
- (void)handleNotificationFor {
    // return in case no annotation is captured
    if ([self.annotationList count] == 0) {
        // invalidate timer and clear array
        [self handleITimerInvalidate];
        return;
    }
    
    // calculate distance between user location and each favorite location
    CLLocation *userLocation = [self.locationManager location];
    NSMutableString *title = [NSMutableString stringWithString:@"👇 You are near 👇"];

    // create NSDictionary to store annotation and calculated distance
    NSMutableDictionary *annotationWithDistance = [NSMutableDictionary new];
    for (WVAnnotation *annotation in self.annotationList) {
            CLLocation *annotationLocation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
        
        CLLocationDistance distance = [userLocation distanceFromLocation:annotationLocation];
        NSNumber *distanceInMile = [NSNumber numberWithDouble:(distance / 1609.34)];
        [annotationWithDistance setValue:distanceInMile forKey:annotation.identifier];
    }
    
    NSArray *sortedArray = [annotationWithDistance keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
//    for (NSString *identifier in sortedArray) {
//        for (id key in annotationWithDistance) {
//            if ([identifier isEqualToString:key]) {
//            id value = [annotationWithDistance objectForKey:key];
//                [title appendFormat:@"\r %@ miles", value];
//            }
//        }
//    }
    
    // display location name in ascending order
    for (NSString *identifier in sortedArray) {
        for (WVAnnotation *annotation in self.annotationList) {
            if ([identifier isEqualToString:annotation.identifier]) {
                [title appendFormat:@"\r%@ ", annotation.title];
            }
        }
    }

    // Show an alert if application is active
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }else {
        // Otherwise present a local notification
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.body = [NSString stringWithFormat:@"You are near %@", title];
        content.sound = UNNotificationSound.defaultSound;
        NSInteger badgeNumber = UIApplication.sharedApplication.applicationIconBadgeNumber + (NSInteger)1;
        content.badge = [NSNumber numberWithInteger:badgeNumber];
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        NSString *requestIdentifier = @"locationChange";
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
        [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Notification request with error: %@", error);
            }
        }];
    }
    
    // invalidate timer and clear array
    [self handleITimerInvalidate];
}

// MARK: delegate method to detect if user enters the region
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSMutableArray *arrayAnnotations = [UDDataManager unarchiveAndRestoreAll];
    // add location into location array
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        for (WVAnnotation *annotation in arrayAnnotations) {
            if ([annotation.identifier isEqualToString:region.identifier]) {
                [self.annotationList addObject:annotation];
            }
        }
    }
    
    // start timer ***
    // if timer gets start without entering any region, handleNotificationFor func
    // will clear the timer
    // or at the end of handleNotificationFor func, simply clear the timer
    if (self.regionDetectionTimer == nil) {
    self.regionDetectionTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0
                                                  target: self
                                                selector:@selector(handleNotificationFor)
                                                userInfo: nil repeats:NO];
    }

}

- (void)handleITimerInvalidate {
    [self.annotationList removeAllObjects];
    [self.regionDetectionTimer invalidate];
    self.regionDetectionTimer = nil;
}

@end
