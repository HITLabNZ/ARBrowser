//
//  ARLocationControllerBase.m
//  ARBrowser
//
//  Created by Samuel Williams on 20/10/11.
//  Copyright (c) 2011 Samuel Williams. All rights reserved.
//

#import "ARLocationControllerBase.h"
#import "ARWorldLocation.h"
#import "Model.h"

// X is defined as the vector product <b>Y.Z</b> (It is tangential to the ground at the device's current location and roughly points East).
// Y is tangential to the ground at the device's current location and points towards the magnetic North Pole.
// Z points towards the sky and is perpendicular to the ground.
int calculateRotationMatrixFromMagnetometer(CMAcceleration gravity, CMMagneticField magnetometer, float * R) {
    float Ax = gravity.x, Ay = gravity.y, Az = gravity.z;
    float Ex = magnetometer.x, Ey = magnetometer.y, Ez = magnetometer.z;
    
    float Hx = Ey*Az - Ez*Ay, Hy = Ez*Ax - Ex*Az, Hz = Ex*Ay - Ey*Ax;
    
    float normH = sqrt(Hx*Hx + Hy*Hy + Hz*Hz);
    
    if (normH < 0.1) {
        // device is close to free fall (or in space?), or close to
        // magnetic north pole. Typical values are  > 100.
        return 0;
    }
    
    float invH = 1.0f / normH;
    Hx *= invH;
    Hy *= invH;
    Hz *= invH;
    
    float invA = 1.0f / sqrt(Ax*Ax + Ay*Ay + Az*Az);
    Ax *= invA;
    Ay *= invA;
    Az *= invA;
    
    float Mx = Ay*Hz - Az*Hy, My = Az*Hx - Ax*Hz, Mz = Ax*Hy - Ay*Hx;
    
    R[0]  = Hx;    R[1]  = Hy;    R[2]  = Hz;   R[3]  = 0;
    R[4]  = Mx;    R[5]  = My;    R[6]  = Mz;   R[7]  = 0;
    R[8]  = Ax;    R[9]  = Ay;    R[10] = Az;   R[11] = 0;
    R[12] = 0;     R[13] = 0;     R[14] = 0;    R[15] = 1;
    
    return 1;
}

@interface ARLocationControllerBase ()
@property(retain,readwrite) CLLocation * currentLocation;
@property(retain,readwrite) CLHeading * currentHeading;
@end

@implementation ARLocationControllerBase

@synthesize currentHeading, currentLocation, northAxis;

- (id)init {
    self = [super init];
    if (self) {
		locationManager = [[CLLocationManager alloc] init];
		[locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
		[locationManager setDelegate:self];
        
		//NSLog(@"Heading Orientation: %d", [locationManager headingOrientation]);
		// This is the same as the default, but setting it explicitly.
		[locationManager setHeadingOrientation:CLDeviceOrientationPortrait];
		northAxis = (CMAcceleration){0, 1, 0};
		
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/30.0) target:self selector:@selector(update) userInfo:nil repeats:YES];
		
		[locationManager startUpdatingLocation];
		[locationManager startUpdatingHeading];
    }
    return self;
}

- (void)dealloc {
	[updateTimer invalidate];
	updateTimer = nil;
	
    [self setCurrentHeading:nil];
    [self setCurrentLocation:nil];
    
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
    
    [locationManager setDelegate:nil];
	[locationManager release];
    locationManager = nil;
		
    [super dealloc];
}

- (void)update
{
	// This should really use spherical interpolation, but for small distances it doesn't really make any difference..
	const double kFilteringFactor = 0.995;
	
	if (currentLocation) {
		//Use a basic low-pass filter to smooth out changes in GPS data.
		smoothedLocation.latitude = smoothedLocation.latitude * kFilteringFactor + currentLocation.coordinate.latitude * (1.0 - kFilteringFactor);
		smoothedLocation.longitude = smoothedLocation.longitude * kFilteringFactor + currentLocation.coordinate.longitude * (1.0 - kFilteringFactor);
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if (currentLocation == nil) {
		// First update:
		smoothedLocation = [newLocation coordinate];
	}
		
	[self setCurrentLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    [self setCurrentHeading:newHeading];
}

//#define DEBUG_DERENZY

- (ARWorldLocation*) worldLocation
{
	if (currentLocation && currentHeading) {
		ARWorldLocation * result = [[ARWorldLocation new] autorelease];
        
#ifdef DEBUG_DERENZY
		CLLocationCoordinate2D derenzy;
		derenzy.latitude = -43.516215;
		derenzy.longitude = 172.5555;
		
		[result setCoordinate:derenzy altitude:EARTH_RADIUS];
#else
		[result setCoordinate:smoothedLocation altitude:EARTH_RADIUS + currentLocation.altitude];
		//[result setLocation:[self currentLocation] globalRadius:EARTH_RADIUS];
#endif
        //CMAttitude * currentAttitude = motionManager.deviceMotion.attitude;
        //[result setBearing:-[currentAttitude yaw] * ARBrowser::R2D];
        [result setBearing:[self currentBearing]];
		
		return result;
	}
	
	return nil;
}

- (CMAcceleration) currentGravity
{
    CMAcceleration gravity = {0, 0, -1};
    
    return gravity;
}

- (CLLocationDirection) currentBearing
{
    return [currentHeading trueHeading];
}

- (BOOL) calculateGlobalOrientation: (float[16])matrix
{
    CMMagneticField magneticField = {
        self.currentHeading.x * ARBrowser::D2R,
        self.currentHeading.y * ARBrowser::D2R,
        self.currentHeading.z * ARBrowser::D2R
    };
    
    //NSLog(@"Magnetic Field Vector: %0.3f, %0.3f, %0.3f", self.currentHeading.x, self.currentHeading.y, self.currentHeading.z);
    
    return calculateRotationMatrixFromMagnetometer([self currentGravity], magneticField, matrix);
}

@end
