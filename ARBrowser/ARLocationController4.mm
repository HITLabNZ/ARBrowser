//
//  ARLocationController4.m
//  ARBrowser
//
//  Created by Samuel Williams on 20/10/11.
//  Copyright (c) 2011 Orion Transfer Ltd. All rights reserved.
//

#import "ARLocationController4.h"

#import "ARLocationController.h"
#import "ARWorldLocation.h"
#include "Model.h"
#include <math.h>

@interface ARLocationController4 ()
@property(retain,readwrite,nonatomic) CMDeviceMotion * currentMotion;
@end

#define HYBRID_SENSORS

@implementation ARLocationController4

@synthesize currentMotion = _currentMotion;

static CLLocationDirection calculateBearingChange(CMDeviceMotion * previousMotion, CMDeviceMotion * currentMotion)
{
    NSTimeInterval dt = [currentMotion timestamp] - [previousMotion timestamp];
    CMRotationRate rotationRate = [currentMotion rotationRate];
    CMAcceleration currentGravity = [currentMotion gravity];
    
    // This method isn't technically correct but it is accurate enough for most use-cases and very fast.
    return ((currentGravity.x * rotationRate.x) + (currentGravity.y * rotationRate.y) + (currentGravity.z * rotationRate.z)) * dt * ARBrowser::R2D;
}

double interpolateAnglesRadians(double a, double b, double blend) {
    double ix = sin(a), iy = cos(a);
    double jx = sin(b), jy = cos(b);
    
    return atan2(ix-(ix-jx)*blend, iy-(iy-jy)*blend);
}

double interpolateAnglesDegrees(double a, double b, double blend) {
    return interpolateAnglesRadians(a * ARBrowser::D2R, b * ARBrowser::D2R, blend) * ARBrowser::R2D;
}

- (id)init {
    self = [super init];
    if (self) {
        motionManager = [[CMMotionManager alloc] init];
        
        // Tell CoreMotion to show the compass calibration HUD when required to provide true north-referenced attitude
        motionManager.showsDeviceMovementDisplay = YES;
        motionManager.deviceMotionUpdateInterval = 1.0 / kSensorSampleFrequency;
        
        // New in iOS 5.0: Attitude that is referenced to true north
        //[motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
        
        _currentBearing = -360.0;
        
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            if (!currentHeading)
                return;
            
            CMDeviceMotion * oldMotion = _currentMotion;
            
            // Initialize the bearing
            if (_currentBearing == -360.0 && currentHeading) {
                _currentBearing = [currentHeading trueHeading];
                _smoothedBearing = _currentBearing;
            }
            
            if (currentHeading && oldMotion) {
                
#ifndef HYBRID_SENSORS
                _currentBearing = [currentHeading trueHeading];
#else
                CLLocationDirection bearingChange = calculateBearingChange(_currentMotion, motion);
                
                //NSLog(@"bearingChange: %0.3f", bearingChange);
                
                CLLocationDirection updatedBearing = interpolateAnglesDegrees(_currentBearing + bearingChange, [currentHeading trueHeading], 0.05);
                
                _currentBearing = updatedBearing;
                //NSLog(@"Current: %0.3f, True: %0.3f, Change: %0.3f, Rotation: %0.3f", _currentBearing, [currentHeading trueHeading], bearingChange, _currentBearing + bearingChange);
                
                /*
                _smoothedBearing =
                    (0.5 * _smoothedBearing) +
                    (0.5 * _currentBearing);
                 */
#endif
            }
            
            [self setCurrentMotion:motion];
        }];        
        
    }
    return self;
}

- (void)dealloc {
    [self setCurrentMotion:nil];
    
    [motionManager stopDeviceMotionUpdates];
    [motionManager release];
	
    [super dealloc];
}

- (CLLocationDirection) currentBearing
{
    return _currentBearing;
}

- (CMAcceleration) currentGravity
{    
    CMAcceleration gravity = {0, 0, -1};
    
    if (!motionManager.deviceMotion) {
        return gravity;
    }
    
    gravity = motionManager.deviceMotion.gravity;
    
    // Normalize
    double factor = 1.0 / sqrt(gravity.x * gravity.x + gravity.y * gravity.y + gravity.z * gravity.z);
    gravity.x *= factor;
    gravity.y *= factor;
    gravity.z *= factor;
    
    return gravity;
}

@end
