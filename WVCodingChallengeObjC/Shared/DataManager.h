//
//  DataManager.h
//  WVCodingChallengeObjC
//
//  Created by ruijia lin on 3/22/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface DataManager: NSObject

@property (nonatomic, retain) NSMutableArray *favLocations;
@property (nonatomic, assign) int timer;

+ (id)sharedManager;

@end
