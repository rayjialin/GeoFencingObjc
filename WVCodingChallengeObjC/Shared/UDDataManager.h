//
//  UDDataManager.h
//  WVCodingChallengeObjC
//
//  Created by ruijia lin on 3/23/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WVAnnotation.h"

@interface UDDataManager: NSObject

+ (void)archiveAndSave:(WVAnnotation *)annotation;
+ (void)removeSingle:(WVAnnotation *)annotation;
+ (void)removeAll;
+ (NSMutableArray *)unarchiveAndRestoreAll;
+ (void)setDistanceForAlert:(int)distanceForAlert;
+ (int)getDistanceForAlert;

@end
