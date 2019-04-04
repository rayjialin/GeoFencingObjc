//
//  WVAnnotation.h
//  WVCodingChallengeObjC
//
//  Created by ruijia lin on 3/21/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapkit/MapKit.h>

@interface WVAnnotation : NSObject <MKAnnotation, NSCoding>

@property (nonatomic, copy) NSString *identifier;

- (id)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle coordinate:(CLLocationCoordinate2D)coordinate;

@end

