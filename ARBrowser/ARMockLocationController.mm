//
//  ARMockLocationController.m
//  ARBrowser
//
//  Created by Samuel Williams on 19/4/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARMockLocationController.h"
#import "ARWorldLocation.h"

@implementation ARMockLocationController

@synthesize currentLocation = _currentLocation, currentHeading = _currentHeading, currentGravity = _currentGravity, currentBearing = _currentBearing;

- (ARWorldLocation*) worldLocation {
	if (self.currentLocation && self.currentHeading) {
		ARWorldLocation * result = [[ARWorldLocation new] autorelease];
        
		[result setCoordinate:self.currentLocation.coordinate altitude:EARTH_RADIUS + self.currentLocation.altitude];
		
        [result setBearing:self.currentHeading.trueHeading];
		
		return result;
	}
	
	return nil;
}

@end
