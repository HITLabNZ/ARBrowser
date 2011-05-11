//
//  ARWorldLocation.h
//  ARBrowser
//
//  Created by Samuel Williams on 6/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

#import "Vector.h"
#import "Matrix.h"

const double EARTH_RADIUS = 6378.1 * 1000.0;

@interface ARWorldLocation : NSObject {
	Vec3 position;
	float rotation;
}

@property(assign) Vec3 position;
@property(assign) float rotation;

- (void) setCoordinate: (CLLocationCoordinate2D)location altitude: (double)radius;

- (void) setLocation: (CLLocation*)location globalRadius:(double)radius;
- (void) setHeading: (CLHeading*)heading;

@end
