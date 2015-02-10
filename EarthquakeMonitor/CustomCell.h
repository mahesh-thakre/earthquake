//
//  CustomCell.h
//  EarthquakeMonitor
//
//  Created by macuser on 2/9/15.
//  Copyright (c) 2015 macuser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *place;
@property (weak, nonatomic) IBOutlet UILabel *magnitude;

@end
