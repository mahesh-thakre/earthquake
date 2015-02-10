//
//  ViewController.h
//  EarthquakeMonitor
//
//  Created by macuser on 2/9/15.
//  Copyright (c) 2015 macuser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, MKMapViewDelegate>
- (IBAction)refresh:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

