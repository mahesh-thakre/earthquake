//
//  DetailViewController.h
//  EarthquakeMonitor
//
//  Created by macuser on 2/9/15.
//  Copyright (c) 2015 macuser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Info.h"

@interface DetailViewController : UIViewController

- (IBAction)close:(id)sender;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *place;
@property (weak, nonatomic) IBOutlet UILabel *timestamp;
@property (weak, nonatomic) IBOutlet UILabel *depth;
@property (strong, nonatomic) Info *infoItem;
@end
