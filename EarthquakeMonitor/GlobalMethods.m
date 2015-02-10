//
//  GlobalMethods.m
//  EarthquakeMonitor
//
//  Created by macuser on 2/10/15.
//  Copyright (c) 2015 macuser. All rights reserved.
//

#import "GlobalMethods.h"

@implementation GlobalMethods

+(BOOL)checkInternet
{
    NSString *urlString = @"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson";
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) {
        return NO;
    }else{
        return YES;
    }
}
@end
