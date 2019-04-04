//
//  UDDataManager.m
//  WVCodingChallengeObjC
//
//  Created by ruijia lin on 3/23/19.
//  Copyright © 2019 ruijia lin. All rights reserved.
//

#import "UDDataManager.h"

@interface UDDataManager ()

+ (void)updateUserDefault:(NSMutableArray *)arrayAnnotations;
@end

#define USER_DEFAULT_KEY @"USER_DEFAULT_KEY";
@implementation UDDataManager


+ (void)archiveAndSave:(WVAnnotation *)annotation {
    NSMutableArray *arrayAnnotations = [NSMutableArray new];
    NSMutableArray *arAnnotations = [UDDataManager unarchiveAndRestoreAll];
    
    if (arAnnotations == nil) {
    }else {
        [arrayAnnotations addObjectsFromArray:arAnnotations];
    }
    
    [arrayAnnotations addObject:annotation];
    [UDDataManager updateUserDefault:arrayAnnotations];
}

+ (NSMutableArray *)unarchiveAndRestoreAll {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_DEFAULT_KEY"];
    //    NSMutableArray *arrayAnnotations = [NSKeyedUnarchiver unarchivedObjectOfClass:WVAnnotation.class fromData:data error:nil];
    NSMutableArray *arrayAnnotations = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return arrayAnnotations;
}

+ (void)removeSingle:(WVAnnotation *)annotation {
    NSMutableArray *arrayAnnotations = [UDDataManager unarchiveAndRestoreAll];
    WVAnnotation *annotationCopy = [WVAnnotation new];
    
    for (WVAnnotation *annotationInArray in arrayAnnotations) {
        if ([annotationInArray.identifier isEqualToString:annotation.identifier]) {
            annotationCopy = annotationInArray;
        }
    }
    
    [arrayAnnotations removeObject:annotationCopy];
    [UDDataManager updateUserDefault:arrayAnnotations];
}

+ (void)removeAll {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER_DEFAULT_KEY"];
}

+ (void)updateUserDefault:(NSMutableArray *)arrayAnnotations {
    //    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:arrayAnnotations requiringSecureCoding:YES error:nil];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:arrayAnnotations];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"USER_DEFAULT_KEY"];
}

// MARK: minimum distance for alert global setting
+ (void)setDistanceForAlert:(int)distanceForAlert {
    [[NSUserDefaults standardUserDefaults] setInteger: (NSInteger) distanceForAlert forKey:@"distanceForAlert"];
}

+ (int)getDistanceForAlert {
    NSInteger distanceForAlert = [[NSUserDefaults standardUserDefaults] integerForKey:@"distanceForAlert"];
    
    if (distanceForAlert == 0) {
        return 10;
    }else {
        return (int) distanceForAlert;
    }
}
@end

