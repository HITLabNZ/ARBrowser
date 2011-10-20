//
//  ARLocationControllerBase.m
//  ARBrowser
//
//  Created by Samuel Williams on 20/10/11.
//  Copyright (c) 2011 Orion Transfer Ltd. All rights reserved.
//

#import "ARLocationControllerBase.h"
#import "ARWorldLocation.h"

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
		
		[locationManager startUpdatingLocation];
		[locationManager startUpdatingHeading];
    }
    return self;
}

- (void)dealloc {
    [self setCurrentHeading:nil];
    [self setCurrentLocation:nil];
    
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
    
    [locationManager setDelegate:nil];
	[locationManager release];
    locationManager = nil;
		
    [super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
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
		[result setLocation:[self currentLocation] globalRadius:EARTH_RADIUS];
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
