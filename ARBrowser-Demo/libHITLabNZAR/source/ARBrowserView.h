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
}

/// The delegate for the ARBrowserView must implement ARBrowserViewDelegate.
@property(assign) id<ARBrowserViewDelegate> delegate;

@end
