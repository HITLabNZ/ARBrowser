//
//  ARANavigationViewController.m
//  ARBrowser
//
//  Created by Samuel Williams on 13/07/12.
//  Copyright (c) 2012 Orion Transfer Ltd. All rights reserved.
//

#import "ARANavigationViewController.h"

@interface ARANavigationViewController ()

@end

@implementation ARANavigationViewController

@synthesize distanceLabel = _distanceLabel, directionsLabel = _directionsLabel, turnImageView = _turnImageView, miniMapView = _miniMapView;

- (id)init {
	self = [super initWithNibName:@"ARANavigationView" bundle:nil];
	
	if (self) {
		
	}
	
	return self;
}

- (void) setDistance:(CLLocationDistance)distance {
	[_distanceLabel setText:[NSString stringWithFormat:@"%0.0fm", distance]];
}

@end
