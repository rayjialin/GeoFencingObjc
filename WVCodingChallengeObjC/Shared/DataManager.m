//
//  DataManager.m
//  WVCodingChallengeObjC
//
//  Created by ruijia lin on 3/22/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//

#import "DataManager.h"

@interface DataManager ()

@end

#define USER_DEFAULT_KEY @"USER_DEFAULT_KEY";
@implementation DataManager

@synthesize favLocations;
@synthesize timer;

#pragma mark Singleton Methods
+ (id)sharedManager {
    static DataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        favLocations = [[NSMutableArray alloc] init];
    }
    return self;
}

@end

