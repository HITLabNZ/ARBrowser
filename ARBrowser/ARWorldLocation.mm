//
//  ARWorldLocation.m
//  ARBrowser
//
//  Created by Samuel Williams on 6/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import "ARWorldLocation.h"

#import "Model.h"

// Convenience
const double D2R = ARBrowser::D2R;

#pragma mark -
#pragma mark Geodetic utilities definition

// WGS 84 semi-major axis constant in meters
const double WGS84_A = 6378137.0;
// WGS 84 eccentricity
const double WGS84_E = 8.1819190842622e-2;

// Converts latitude, longitude to ECEF coordinate system
void convertLocationToECEF(double lat, double lon, double alt, double *x, double *y, double *z)
{       
	double clat = cos(lat * D2R);
	double slat = sin(lat * D2R);
	double clon = cos(lon * D2R);
	double slon = sin(lon * D2R);
	
	double N = WGS84_A / sqrt(1.0 - WGS84_E * WGS84_E * slat * slat);
	
	*x = (N + alt) * clat * clon;
	*y = (N + alt) * clat * slon;
	*z = (N * (1.0 - WGS84_E * WGS84_E) + alt) * slat;
}

// Coverts ECEF to ENU coordinates centered at given lat, lon
void convertECEFtoENU(double lat, double lon, double x, double y, double z, double xr, double yr, double zr, double *e, double *n, double *u)
{
	double clat = cos(lat * D2R);
	double slat = sin(lat * D2R);
	double clon = cos(lon * D2R);
	double slon = sin(lon * D2R);
	double dx = x - xr;
	double dy = y - yr;
	double dz = z - zr;
	
	*e = -slon*dx  + clon*dy;
	*n = -slat*clon*dx - slat*slon*dy + clat*dz;
	*u = clat*clon*dx + clat*slon*dy + slat*dz;
}

@implementation ARWorldLocation

@synthesize location, altitude, position, rotation;

- (void) setCoordinate: (CLLocationCoordinate2D)_location altitude: (double)_altitude
{
	// Retain original coordinates
	location = _location;
	altitude = _altitude;
    
    double x, y, z;
    convertLocationToECEF(location.latitude, location.longitude, altitude, &x, &y, &z);

    position = Vec3(x, y, z);
}

// Calculates the distance between two Vec2(latitude,longitude) points, on a sphere of the given radius.
double distanceBetween(const CLLocationCoordinate2D & a, const CLLocationCoordinate2D & b, double radius) {
	CLLocationCoordinate2D d;
	d.latitude = (b.latitude - a.latitude) * D2R;
	d.longitude = (b.longitude - a.longitude) * D2R;
	
	double sx = sin(d.latitude/2.0), sy = sin(d.longitude/2.0);
	double t = sx*sx + cos(a.latitude*D2R) * cos(b.latitude*D2R) * sy*sy;
	double c = 2.0 * atan2(sqrt(t), sqrt(1.0-t));
	
	double distance = fabs(radius * c);
	
	return distance;
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
		r.x *= -1.0;
	
	// If latitude is less than origin, inverse y coordinate
	if (other->location.latitude < location.latitude)
		r.y *= -1.0;
	
	r.z = 0;
	
	return r;
}

- (void) setLocation:(CLLocation*)_location globalRadius:(double)radius
{
	[self setCoordinate:[_location coordinate] altitude:radius + [_location altitude]];
}

- (void) setBearing: (float)bearing
{
	rotation = bearing;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<ARWorldPoint: %0.5f %0.5f>", location.latitude, location.longitude];
}

@end
