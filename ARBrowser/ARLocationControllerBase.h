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
}

/// @internal
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

/// @internal
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;

@property(retain,readonly,nonatomic) CLLocation * currentLocation;
@property(retain,readonly,nonatomic) CLHeading * currentHeading;

// These attributes will be improved in dervied classes depending on available sensors.
- (CMAcceleration) currentGravity;
- (CLLocationDirection) currentBearing;

- (ARWorldLocation*) worldLocation;

@end
