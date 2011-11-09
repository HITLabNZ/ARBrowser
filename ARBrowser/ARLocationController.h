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

extern NSString * const ARLocationChanged;
extern NSString * const ARHeadingChanged;
extern NSString * const ARAccelerationChanged;

@class ARWorldLocation;

/// Provides access to location information via a shared instance.
@interface ARLocationController : NSObject

@property(retain,readonly,nonatomic) CLLocation * currentLocation;
@property(retain,readonly,nonatomic) CLHeading * currentHeading;

/// The device's current gravity downwards vector.
- (CMAcceleration) currentGravity;

/// The devices current rotation from north, e.g. around the downwards vector.
- (CLLocationDirection) currentBearing;

// The local device axis that represents north.
- (CMAcceleration) northAxis;

/// Get the origin of the current device.
- (ARWorldLocation*) worldLocation;

/// Get the shared location controller.
+ sharedInstance;

@end

