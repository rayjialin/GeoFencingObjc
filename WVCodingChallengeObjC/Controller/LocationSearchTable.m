//
//  LocationSearchTable.m
//  WVCodingChallengeObjC
//
//  Created by ruijia lin on 3/21/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//

#import "LocationSearchTable.h"

@interface LocationSearchTable ()
@end

@implementation LocationSearchTable

- (void)viewDidLoad {
    [super viewDidLoad];
    self.matchingItems = [[NSMutableArray alloc] init];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.matchingItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"cell";
    // Reuse and create cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    MKMapItem *selectedItem = self.matchingItems[indexPath.row];
    cell.textLabel.text = selectedItem.name;
    cell.detailTextLabel.text = selectedItem.placemark.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MKMapItem *selectedItem = self.matchingItems[indexPath.row];
    [self.handleMapSearchDelegate dropPinZoomIn:selectedItem];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    MKMapView *mapView = self.mapView;
    if ([mapView isKindOfClass:[NSNull class]]) {
        // do nothing
    }else {
        NSString *searchBarText = searchController.searchBar.text;
        MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
        request.naturalLanguageQuery = searchBarText;
        request.region = mapView.region;
        MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
        
        [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Search error in searchBar: %@", error);
            }else if (response) {
                [self.matchingItems removeAllObjects];
                for (MKMapItem *mapItem in response.mapItems) {
                    [self.matchingItems addObject:mapItem];
                }
                [self.tableView reloadData];
            }
        }];
    }
}

@end
