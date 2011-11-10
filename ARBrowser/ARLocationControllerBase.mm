//
//  ARLocationControllerBase.m
//  ARBrowser
//
//  Created by Samuel Williams on 20/10/11.
//  Copyright (c) 2011 Orion Transfer Ltd. All rights reserved.
//

#import "ARLocationControllerBase.h"
#import "ARWorldLocation.h"
#import "Model.h"


@interface ARLocationControllerBase ()
@property(retain,readwrite,nonatomic) CLLocation * currentLocation;
@property(retain,readwrite,nonatomic) CLHeading * currentHeading;
@end

@implementation ARLocationControllerBase

@synthesize currentHeading, currentLocation;

- (id)init {
    self = [super init];
    if (self) {
		locationManager = [[CLLocationManager alloc] init];
		[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
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

@end
