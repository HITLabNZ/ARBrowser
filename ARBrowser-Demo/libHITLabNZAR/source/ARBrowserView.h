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

struct ARBrowserInternalState;

@protocol ARBrowserViewDelegate <NSObject>

// Return a list of world points, e.g. instances of ARWorldPoint objects.
- (NSArray*)worldPoints;

@end

@interface ARBrowserView : EAGLView {
	ARVideoFrameController * videoFrameController;
    ARVideoBackground * videoBackground;
	
	struct ARBrowserInternalState * state;	
}

@end
