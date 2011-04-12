//
//  ARBrowserView.h
//  ARBrowser
//
//  Created by Samuel Williams on 9/04/11.
//  Copyright 2011 Orion Transfer Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EAGLView.h"
#import "ARVideoFrameController.h"
#import "ARVideoBackground.h"

struct ARBrowserInternalState;

@interface ARBrowserView : EAGLView {
	ARVideoFrameController * videoFrameController;
    ARVideoBackground * videoBackground;
	
	struct ARBrowserInternalState * state;	
}

@end
