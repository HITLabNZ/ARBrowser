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
@protocol ARBrowserViewDelegate <EAGLViewDelegate>

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
	
	float distanceScale, minimumDistance, scaleDistance, maximumDistance;
	BOOL displayRadar, displayGrid;
}

/// The delegate for the ARBrowserView must implement ARBrowserViewDelegate.
@property(nonatomic,assign) id<ARBrowserViewDelegate> delegate;

/// Controls the scale of objects positions. This doesn't change the size of objects, just the relative position to the origin. As an example, a scale of 2.0 means that objects are twice as far away, and a scale of 1.0/2.0 means objects are twice as close.
/// This property does NOT change the calculations of minimum and maximum distance properties.
@property(nonatomic,assign) float distanceScale;

/// Controls culling of near objects. Objects closer than this distance are not rendered.
@property(nonatomic,assign) float minimumDistance;

/// Controls the scale of objects size. Objects closer than this distance appear the same size as they do at this distance.
@property(nonatomic,assign) float scaleDistance;

/// Controls culling of distance objects. Objects further away than this are not rendered.
@property(nonatomic,assign) float maximumDistance;

/// Display a small on-screen compass.
@property(assign) BOOL displayRadar;

/// Display a background horizon grid.
@property(assign) BOOL displayGrid;

@end
