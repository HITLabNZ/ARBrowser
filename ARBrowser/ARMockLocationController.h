//
//  ARMockLocationController.h
//  ARBrowser
//
//  Created by Samuel Williams on 19/4/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARLocationController.h"

/// Provides an interface that can be used to simulate location related timelines.
@interface ARMockLocationController : ARLocationController

@property(retain,readwrite,nonatomic) CLLocation * currentLocation;
@property(retain,readwrite,nonatomic) CLHeading * currentHeading;

/// The device's current gravity downwards vector.
@property(assign,readwrite,nonatomic) CMAcceleration currentGravity;

/// The devices current rotation from north, e.g. around the downwards vector.
@property(assign,readwrite,nonatomic) CLLocationDirection currentBearing;

@end
