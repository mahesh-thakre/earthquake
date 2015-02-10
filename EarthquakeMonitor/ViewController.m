//
//  ViewController.m
//  EarthquakeMonitor
//
//  Created by macuser on 2/9/15.
//  Copyright (c) 2015 macuser. All rights reserved.
//

#import "ViewController.h"
#import "CustomCell.h"
#import "Info.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "GlobalMethods.h"
#import "ZSPinAnnotation.h"
#import "ZSAnnotation.h"

@interface ViewController ()

@end


@implementation ViewController
{
    NSFetchRequest *request;
    BOOL internetON;
}

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // register custom cell as the default cell for the tableview
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Cell"];
    
    //Get managedobject context from Appdelegate
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    self.managedObjectContext = delegate.managedObjectContext;
    
    internetON = [GlobalMethods checkInternet]; //parameter to check if internet connection is ON
    
    if (internetON) { //Delete core data objects and reload with latest data only if internet is ON
        [self clearCache];
        [self getEarthquakeInfo];
    }
    
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]){ //Refresh fetchedresultscontroller
        NSLog(@"Could not refresh table:%@",error);
    }
    
    self.mapView.delegate=self;
    NSArray *annotationsArray = [self getPinAnnotationsArray];
    
    // Center map
    self.mapView.visibleMapRect = [self makeMapRectWithAnnotations:annotationsArray];
    
    // Add to map
    [self.mapView addAnnotations:annotationsArray];
    
    
    //Add refresh control object to tableview
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshWithControl:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Methods to get earthquake info

// Method to get earthquake info from usgs website using JSON API

-(void)getEarthquakeInfo
{
    NSString *urlString = @"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson";
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error = nil;
    
    //Parse JSON output from website
    NSDictionary *results = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&error]: nil;

    NSMutableArray *magnitudes = [results valueForKeyPath:@"features.properties.mag"];
    NSMutableArray *places = [results valueForKeyPath:@"features.properties.place"];
    NSMutableArray *times = [results valueForKeyPath:@"features.properties.time"];
    NSMutableArray *coordinates = [results valueForKeyPath:@"features.geometry.coordinates"];

    //Load earthquake information data into core data
    for (int i=0; i<[magnitudes count]; i++) {
    Info *infoItem = [[Info alloc]initWithEntity:[NSEntityDescription entityForName:@"Info" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];        
        infoItem.place=places[i];
        infoItem.magnitude = magnitudes[i];
        infoItem.time = times[i];
        infoItem.longitude=[coordinates objectAtIndex:i][0];
        infoItem.latitude=[coordinates objectAtIndex:i][1];
        infoItem.depth=[coordinates objectAtIndex:i][2];

        NSError *error = nil;
        
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Could not save items:%@",error);
        }
    }

}

#pragma mark TableView Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell *cell = (CustomCell *)[self.tableView dequeueReusableCellWithIdentifier:@"Cell"]; //Use custom cell for tableview
    Info *infoItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.place.text=infoItem.place;
    cell.magnitude.text=[infoItem.magnitude stringValue];
    cell.backgroundColor=[self getColor:[infoItem.magnitude floatValue]]; //Color cell based on magnitude of earthquake
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> secInfo = [[self.fetchedResultsController sections]objectAtIndex:section];
    return [secInfo numberOfObjects];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showDetails" sender:self]; //segue when user clicks on cell
}


#pragma mark FetchedResultsController methods

//Initialize fetched results controller

-(NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    request = [[NSFetchRequest alloc]init];
    [request setEntity:[NSEntityDescription entityForName:@"Info" inManagedObjectContext:self.managedObjectContext]];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc]initWithKey:@"magnitude" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor1]];

    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate=self;
    return _fetchedResultsController;
    
}

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade ];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
    }
}


#pragma mark Methods related to MapKit

//Determine bounds of map based on annotations

- (MKMapRect)makeMapRectWithAnnotations:(NSArray *)annotations {
    
    MKMapRect flyTo = MKMapRectNull;
    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
        }
    }
    
    return flyTo;
    
}

//Mapview delegate method

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation {
    
    // Don't mess with user location
    if(![annotation isKindOfClass:[ZSAnnotation class]])
        return nil;
    
    ZSAnnotation *a = (ZSAnnotation *)annotation;
    static NSString *defaultPinID = @"StandardIdentifier";
    
    // Create the ZSPinAnnotation object and reuse it
    ZSPinAnnotation *pinView = (ZSPinAnnotation *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    if (pinView == nil){
        pinView = [[ZSPinAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    }
    
    // Set the type of pin to draw and the color
    pinView.annotationType = ZSPinAnnotationTypeTagStroke;
    pinView.annotationColor = a.color;
    pinView.canShowCallout = YES;
    
    return pinView;
    
}

#pragma mark Miscellaneous methods

//Method to clear core data objects when preforming refresh

-(void)clearCache
{
    request = [[NSFetchRequest alloc]init];
    [request setEntity:[NSEntityDescription entityForName:@"Info" inManagedObjectContext:self.managedObjectContext]];
    NSError *error = nil;
    
    NSArray *infoItems = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    for (Info *item in infoItems) {
        [self.managedObjectContext deleteObject:item];
    }
    
    [self.managedObjectContext save:&error];
}

//Method to set tableview cell color based on magnitude of earthquake

-(UIColor *)getColor:(CGFloat)magnitude
{
    
    UIColor *color = [UIColor colorWithRed:(CGFloat)(magnitude/10) green:(CGFloat)((10-magnitude)/10) blue:0 alpha:1.0 ];
    return color;
}

// Method to refresh core data with latest earthquake information

- (IBAction)refresh:(id)sender {
    internetON = [GlobalMethods checkInternet]; //parameter to check if internet connection is ON
    if (internetON) {
        [self clearCache];
        [self getEarthquakeInfo];
        
        //clear all annotations and add based on new data
        [self.mapView removeAnnotations:self.mapView.annotations];
        NSArray *annotationsArray = [self getPinAnnotationsArray];
        
        // Center map
        self.mapView.visibleMapRect = [self makeMapRectWithAnnotations:annotationsArray];
        
        // Add to map
        [self.mapView addAnnotations:annotationsArray];

    }
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]){
        NSLog(@"Could not refresh table:%@",error);
    }
    
}

// Method to refresh core data when user uses refreshcontrol

-(void)refreshWithControl:(UIRefreshControl *)refreshControl
{
    internetON = [GlobalMethods checkInternet]; //parameter to check if internet connection is ON
    if (internetON) {
        [self refresh:self];
    }
    
    [refreshControl endRefreshing];
    
}

//Method called before segue to detail view controller. Method passes on earthquake info object based on cell clicked by user to detail view controller

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetails"]) {
        DetailViewController *dvc = (DetailViewController *)[segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Info *infoItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        dvc.infoItem = infoItem;
    }
}

// Method to generate an array of annotations based on data refresh

-(NSMutableArray *)getPinAnnotationsArray
{
    NSMutableArray *annotationArray = [[NSMutableArray alloc] init];
    NSArray *fetchedObjects = [self.fetchedResultsController fetchedObjects];
    
    // Create some annotations
    for (Info *infoItem in fetchedObjects) {
        ZSAnnotation *annotation = nil;
        
        annotation = [[ZSAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake([infoItem.latitude floatValue], [infoItem.longitude floatValue]);
        annotation.color = [self getColor:[infoItem.magnitude floatValue]];
        annotation.title = infoItem.place;
        annotation.type = ZSPinAnnotationTypeTag;
        [annotationArray addObject:annotation];
        
    }
    return annotationArray;
}


@end
