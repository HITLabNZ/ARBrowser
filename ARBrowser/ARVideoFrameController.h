//
//  ARVideoFrameController.h
//  ARBrowser
//
//  Created by Samuel Williams on 5/04/11.
//  Copyright 2011 Orion Transfer Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

typedef struct {
	int index;
	
	GLenum pixelFormat, internalFormat, dataType;
		
	CGSize size;
	unsigned bytesPerRow;

	unsigned char * data;
} ARVideoFrame;

//http://www.benjaminloulier.com/posts/2-ios4-and-direct-access-to-the-camera
@interface ARVideoFrameController : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate> {
	AVCaptureSession * captureSession;
	ARVideoFrame videoFrame;
}

- init;

- (void) start;
- (void) stop;

- (ARVideoFrame*) videoFrame;

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

@end
