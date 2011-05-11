//
//  ARWorldLocation.m
//  ARBrowser
//
//  Created by Samuel Williams on 6/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import "ARWorldLocation.h"

const double D2R = (M_PI / 180.0);

@implementation ARWorldLocation

@synthesize position, rotation;

- (void) setCoordinate: (CLLocationCoordinate2D)location altitude: (double)radius
{
	// longitude (-180 -> 180)
	float phi = (location.longitude + 180) * D2R;
	
	// latitude (-90 -> 90)
	float theta = (location.latitude + 90) * D2R;
	
	// Calculate coordinates spherical -> rectangular
	// Y axis points north
	position.x = radius * sin(theta) * sin(phi);
	position.y = radius * sin(theta) * cos(phi);
	
	// This isn't quite correct, so we set it to zero =)
	//position.z = radius * cos(theta);
	position.z = 0;
}

- (void) setLocation: (CLLocation*)location globalRadius:(double)radius
{
	[self setCoordinate:[location coordinate] altitude:radius + [location altitude]];
}

- (void) setHeading: (CLHeading*)heading
{
	rotation = [heading trueHeading];
}

@end
