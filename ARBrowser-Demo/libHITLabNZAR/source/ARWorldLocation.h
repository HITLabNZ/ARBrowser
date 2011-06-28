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

/// A intrinsic location on the surface of a sphere.
/// Provides functionality to convert between spherical and cartesian coordinates.
@interface ARWorldLocation : NSObject {
	CLLocationCoordinate2D location;
	double altitude;
	
	Vec3 position;
	float rotation;
}

/// The location in latitude/longitude.
@property(readonly) CLLocationCoordinate2D location;

/// The distance from the center of the sphere.
@property(readonly) double altitude;

/// The cartesian location in x,y,z.
@property(readonly) Vec3 position;

/// The rotation from north, i.e. heading direction.
@property(readonly) float rotation;

/// Calculates the position in cartesian coordinates from a given latitude/longitude pair and altitude.
- (void) setCoordinate: (CLLocationCoordinate2D)location altitude: (double)radius;

/// Calculate the relative position of one object to another.
/// This function may fail at the north and south pole due to inherent limitations of spherical coordinates.
/// @returns <tt>x</tt> corresponding to longitude (east, west)
/// @returns <tt>y</tt> corresponding to latitude (north, south)
/// @returns <tt>z</tt> corresponding to altitude (up, down).
- (Vec3) calculateRelativePositionOf: (ARWorldLocation*)other;

/// Helper function to set location from a given CLLocation.
/// @internal
- (void) setLocation: (CLLocation*)location globalRadius:(double)radius;

/// Helper function to set heading from a given CLHeading.
/// @internal
- (void) setHeading: (CLHeading*)heading;

@end
