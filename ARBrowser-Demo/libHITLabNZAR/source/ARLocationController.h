//
//  ARLocationController.h
//  ARBrowser
//
//  Created by Samuel Williams on 13/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <UIKit/UIAccelerometer.h>

@class ARWorldLocation;

/// Provides access to location information via a shared instance.
@interface ARLocationController : NSObject<CLLocationManagerDelegate,UIAccelerometerDelegate> {
	CLLocationManager * locationManager;

	CLLocation * currentLocation;
	CLHeading * currentHeading;
	
	CMAcceleration currentAcceleration;
}

/// @internal
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

/// @internal
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;

@property(readonly, nonatomic) CLLocation * currentLocation;
@property(readonly, nonatomic) CLHeading * currentHeading;
@property(readonly, nonatomic) CMAcceleration currentAcceleration;

/// Get the origin of the current device.
- (ARWorldLocation*) worldLocation;

/// Get the shared location controller.
+ sharedInstance;

@end

