//
//  LocationSearchTable.h
//  WVCodingChallengeObjC
//
//  Created by ruijia lin on 3/21/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN
@interface LocationSearchTable : UITableViewController <UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource>

//@property (nonatomic) MKMapItem * _Nonnull matchingItem;
@property (nonatomic, weak, nullable) id <HandleMapSearch> handleMapSearchDelegate;
@property (nonatomic, weak, nullable) MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *matchingItems;

@end

NS_ASSUME_NONNULL_END
