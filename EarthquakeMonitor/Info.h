//
//  Info.h
//  EarthquakeMonitor
//
//  Created by macuser on 2/9/15.
//  Copyright (c) 2015 macuser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Info : NSManagedObject

@property (nonatomic, retain) NSString * place;
@property (nonatomic, retain) NSNumber * magnitude;
@property (nonatomic, retain) NSNumber * depth;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;

@end
