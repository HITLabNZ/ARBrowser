//
//  ARANavigationViewController.h
//  ARBrowser
//
//  Created by Samuel Williams on 13/07/12.
//  Copyright (c) 2012 Orion Transfer Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#include "ARAMiniMapView.h"

@interface ARANavigationViewController : UIViewController

@property(nonatomic,retain) IBOutlet UILabel * directionsLabel;
@property(nonatomic,retain) IBOutlet UILabel * distanceLabel;
@property(nonatomic,retain) IBOutlet UIImageView * turnImageView;
@property(nonatomic,retain) IBOutlet ARAMiniMapView * miniMapView;

- (void) setDistance:(CLLocationDistance)distance;

@end
