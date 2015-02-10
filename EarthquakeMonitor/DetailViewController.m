//
//  DetailViewController.m
//  EarthquakeMonitor
//
//  Created by macuser on 2/9/15.
//  Copyright (c) 2015 macuser. All rights reserved.
//

#import "DetailViewController.h"
#import "GlobalMethods.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

{
    #define METERS_PER_MILE 1609.344 //Conversion of mile to meters
}


-(void)viewWillAppear:(BOOL)animated
{

    //Define coordinates for pin on mapview
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [self.infoItem.latitude doubleValue];
    zoomLocation.longitude= [self.infoItem.longitude doubleValue];
    
    // 2
    if ([GlobalMethods checkInternet]) { //Only if internet connection exists access mapview
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 50*METERS_PER_MILE, 50*METERS_PER_MILE);
        [_mapView setRegion:viewRegion animated:YES];
        MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
        point.coordinate=zoomLocation;
        point.title=self.infoItem.place;
        
        [_mapView addAnnotation:point];
        [_mapView selectAnnotation:point animated:YES];
    }
    
    //Update detail labels with values passed from tableview in master view controller
    self.place.text=self.infoItem.place;
    self.timestamp.text=[self getEarthquakeTimestamp];
    self.depth.text=[self.infoItem.depth stringValue];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Miscellaneous methods

//Method to close view controller when user clicks the dismiss button

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Method to get information about timestamp for earthquake using epoch time calculations

-(NSString *)getEarthquakeTimestamp
{
    NSDate *epochDate = [[NSDate alloc]initWithTimeIntervalSince1970:[self.infoItem.time integerValue]/1000
                         ];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"MM/dd/yyyy HH:mm zzz"];
    return [df stringFromDate:epochDate];
    
}

#pragma mark MapView related method

//Mapview delegate method

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"redpin"];
    newAnnotation.pinColor = MKPinAnnotationColorRed;
    newAnnotation.animatesDrop = YES;
    newAnnotation.canShowCallout = YES;
    return newAnnotation;
}

@end
