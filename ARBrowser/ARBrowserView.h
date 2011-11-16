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
	
	float minimumDistance, maximumDistance;
	
	/// Objects closer than near distance will be scaled down in size,
	/// and vise versa for far distance.
	float nearDistance, farDistance;
	
	BOOL displayRadar, displayGrid;
}

/// The delegate for the ARBrowserView must implement ARBrowserViewDelegate.
@property(nonatomic,assign) id<ARBrowserViewDelegate> delegate;

/// Controls culling of near objects. Objects closer than this distance are not rendered.
@property(nonatomic,assign) float minimumDistance;

/// Controls culling of distance objects. Objects further away than this are not rendered.
@property(nonatomic,assign) float maximumDistance;

/// Objects closer than this appear the same size.
@property(nonatomic,assign) float nearDistance;

/// Objects further away than this size appear the same size.
@property(nonatomic,assign) float farDistance;

/// Display a small on-screen compass.
@property(assign) BOOL displayRadar;

/// Display a background horizon grid.
@property(assign) BOOL displayGrid;

@end
