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

@synthesize location, altitude, position, rotation;

- (void) setCoordinate: (CLLocationCoordinate2D)_location altitude: (double)_altitude
{
	// Retain original coordinates
	location = _location;
	altitude = _altitude;

	// longitude (-180 -> 180)
	float phi = (180 - location.longitude) * D2R;

	// latitude (-90 -> 90)
	float theta = (90 - location.latitude) * D2R;

	// Calculate coordinates spherical -> rectangular
	// Y axis points north
	position.x = altitude * sin(theta) * sin(phi);
	position.y = altitude * sin(theta) * cos(phi);
	position.z = altitude * cos(theta);
}

// Calculates the distance between two Vec2(latitude,longitude) points, on a sphere of the given radius.
double distanceBetween(const CLLocationCoordinate2D & a, const CLLocationCoordinate2D & b, double radius) {
	CLLocationCoordinate2D d;
	d.latitude = (b.latitude - a.latitude) * D2R;
	d.longitude = (b.longitude - a.longitude) * D2R;
	
	double sx = sin(d.latitude/2.0), sy = sin(d.longitude/2.0);
	double t = sx*sx + cos(a.latitude*D2R) * cos(b.latitude*D2R) * sy*sy;
	double c = 2.0 * atan2(sqrt(t), sqrt(1.0-t));
	
	return abs(radius * c);
}

- (Vec3) calculateRelativePositionOf: (ARWorldLocation*)other
{	
	CLLocationCoordinate2D horizontal = {location.latitude, other->location.longitude};
	CLLocationCoordinate2D vertical = {other->location.latitude, location.longitude};
		
	Vec3 r;
	// We calculate x by varying longitude (east <-> west)
	r.x = distanceBetween(location, horizontal, altitude);
	
	// We calculate y by varying latitude (north <-> south)
	r.y = distanceBetween(location, vertical, altitude);
	
	// If longitude is less than origin, inverse x coordinate.
	if (other->location.longitude < location.longitude)
		r.x *= -1;
	
	// If latitude is less than origin, inverse y coordinate
	if (other->location.latitude < location.latitude)
		r.y *= -1;
	
	r.z = 0;
	
	return r;
}

- (void) setLocation:(CLLocation*)_location globalRadius:(double)radius
{
	[self setCoordinate:[_location coordinate] altitude:radius + [_location altitude]];
}

- (void) setHeading: (CLHeading*)heading
{
	rotation = [heading trueHeading];
}

@end
