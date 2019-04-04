//
//  WVAnnotation.m
//  WVCodingChallengeObjC
//
//  Created by ruijia lin on 3/21/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "WVAnnotation.h"


@interface WVAnnotation ()
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

@implementation WVAnnotation

@synthesize title;
@synthesize subtitle;
@synthesize coordinate;
@synthesize identifier;

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        self.title = title;
        self.subtitle = subtitle;
        self.coordinate = coordinate;
        self.identifier = [NSUUID.UUID UUIDString];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.title = [decoder decodeObjectForKey:@"title"];
        self.subtitle = [decoder decodeObjectForKey:@"subtitle"];
        CLLocationDegrees latitude = [decoder decodeDoubleForKey:@"latitude"];
        CLLocationDegrees longitude = [decoder decodeDoubleForKey:@"longitude"];
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        self.identifier = [decoder decodeObjectForKey:@"identifier"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:title forKey:@"title"];
    [encoder encodeObject:subtitle forKey:@"subtitle"];
//    [encoder encodeObject:[NSValue valueWithMKCoordinate:coordinate] forKey:@"coordinate"];
    [encoder encodeDouble:coordinate.latitude forKey:@"latitude"];
    [encoder encodeDouble:coordinate.longitude forKey:@"longitude"];
    [encoder encodeObject:identifier forKey:@"identifier"];
}

@end
