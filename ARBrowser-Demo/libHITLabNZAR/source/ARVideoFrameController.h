//
//  ARVideoFrameController.h
//  ARBrowser
//
//  Created by Samuel Williams on 5/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

// The number of buffers to allocate
enum {
	ARVideoFrameBuffers = 2
};

/// The image data from the video camera.
typedef struct {
	/// The frame number
	int index;
	
	/// Details for implementing the OpenGL video background.
	GLenum pixelFormat, internalFormat, dataType;
	
	/// The size of the video frame in pixels.
	CGSize size;
	
	/// The number of bytes per row.
	unsigned bytesPerRow;
	
	/// The actual image data.
	unsigned char * data;
} ARVideoFrame;

/// Provides simplea access to iPhone video camera in the form of ARVideoFrame data. This can then be provided to ARVideoBackground for rendering.
@interface ARVideoFrameController : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate> {
	AVCaptureSession * captureSession;
	ARVideoFrame videoFrames[ARVideoFrameBuffers];
    
	NSUInteger index;
}

- init;

/// Start capturing video frames.
- (void) start;

/// Stop capturing video frames.
- (void) stop;

/// Grab the latest video frame from the camera.
/// This video frame is buffered internally, so, the same pointer is returned every time.
/// The ARVideoFrame::index frame counter will be incremented when the frame has changed.
- (ARVideoFrame*) videoFrame;

/// @internal
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

@end
