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

@interface ARLocationController : NSObject<CLLocationManagerDelegate,UIAccelerometerDelegate> {
	CLLocationManager * locationManager;

	CLLocation * currentLocation;
	CLHeading * currentHeading;
	
	CMAcceleration currentAcceleration;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;

@property(readonly, nonatomic) CLLocation * currentLocation;
@property(readonly, nonatomic) CLHeading * currentHeading;
@property(readonly, nonatomic) CMAcceleration currentAcceleration;

- (ARWorldLocation*) worldLocation;

+ sharedInstance;

@end

