//
//  ARFirstViewController.h
//  ARBrowser-VideoStream
//
//  Created by Samuel Williams on 22/12/11.
//  Copyright (c) 2011 Samuel Williams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "ARVideoFrameController.h"
#import "ARVSGraphView.h"

@class ARVSLogger;

double length(CMAcceleration vector);

typedef CMAcceleration ARVSVelocity;

@interface ARVSCaptureViewController : UIViewController <ARVideoFrameControllerDelegate> {
	ARVSLogger * _logger;
	
	NSUInteger _frameOffset;
	
	NSOperationQueue * _motionQueue;
	CMMotionManager * _motionManager;
	
	NSTimeInterval _previousTime;
	ARVSVelocity _currentVelocity;
	
	UITextView * _velocityTextView;
	ARVSGraphView * _graphView;
}

@property(retain) ARVSLogger * logger;
@property(retain) UITextView * velocityTextView;

@end
