//
//  ARVSCaptureView.h
//  ARBrowser
//
//  Created by Samuel Williams on 30/01/12.
//  Copyright (c) 2012 Orion Transfer Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EAGLView.h"
#import "ARVSCaptureViewController.h"

@class ARVideoFrameController, ARVideoBackground, ARVSLocationController;

@interface ARVSCaptureView : EAGLView {
	ARVideoFrameController * videoFrameController;
	ARVideoBackground * videoBackground;
	
	UITextView * velocityTextView;
	
	ARVSLocationController * locationController;
}

@property(nonatomic,retain) ARVideoFrameController * videoFrameController;

@end
