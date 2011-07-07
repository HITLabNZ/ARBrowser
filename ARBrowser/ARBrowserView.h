//
//  ARBrowserView.h
//  ARBrowser
//
//  Created by Samuel Williams on 9/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EAGLView.h"
#import "ARVideoFrameController.h"
#import "ARVideoBackground.h"

@class ARBrowserView, ARWorldPoint;

/// The main data source/delegate for ARBrowserView
@protocol ARBrowserViewDelegate <NSObject>

/// Return a list of world points, e.g. instances of ARWorldPoint objects.
- (NSArray*)worldPoints;

/// Called when an object is selected on screen by the user.
- (void) browserView: (ARBrowserView*)view didSelect:(ARWorldPoint*)point;
@end

/// @internal
struct ARBrowserViewState;

/// The main augmented reality view, which combines the ARVideoBackground with the ARLocationController.
@interface ARBrowserView : EAGLView {
	ARVideoFrameController * videoFrameController;
	ARVideoBackground * videoBackground;
	
	/// @internal
	struct ARBrowserViewState * state;
	
	float distanceScale;
	BOOL displayRadar;
}

/// The delegate for the ARBrowserView must implement ARBrowserViewDelegate.
@property(assign) id<ARBrowserViewDelegate> delegate;

/// Controls the scale of objects positions. This doesn't change the size of objects, just the relative position to the origin. As an example, a scale of 2.0 means that objects are twice as far away, and a scale of 1.0/2.0 means objects are twice as close.
@property(assign) float distanceScale;

/// Display a small on-screen compass.
@property(assign) BOOL displayRadar;

@end
