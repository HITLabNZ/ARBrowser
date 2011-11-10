//
//  ARLocationControllerBase.h
//  ARBrowser
//
//  Created by Samuel Williams on 20/10/11.
//  Copyright (c) 2011 Orion Transfer Ltd. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@class ARWorldLocation;

const double kSensorSampleFrequency = 60.0; //Hz

@interface ARLocationControllerBase : NSObject<CLLocationManagerDelegate> {
	CLLocationManager * locationManager;
	CLLocation * currentLocation;
	CLHeading * currentHeading;
    
    CMAcceleration northAxis;
	
	CLLocationCoordinate2D smoothedLocation;
	
	NSTimer * updateTimer;
}

/// @internal
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

/// @internal
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;

@property(retain,readonly) CLLocation * currentLocation;
@property(retain,readonly) CLHeading * currentHeading;
@property(assign,readonly) CMAcceleration northAxis;

// These attributes will be improved in dervied classes depending on available sensors.
- (CMAcceleration) currentGravity;

// The rotation around the axis defined by gravity, and +Y pointing North.
- (CLLocationDirection) currentBearing;
- (CMAcceleration) northAxis;

- (ARWorldLocation*) worldLocation;

@end
