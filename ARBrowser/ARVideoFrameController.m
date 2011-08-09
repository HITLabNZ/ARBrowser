//
//  ARVideoFrameController.m
//  ARBrowser
//
//  Created by Samuel Williams on 5/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import "ARVideoFrameController.h"

// Some implementation was based on the implementation from
// http://www.benjaminloulier.com/posts/2-ios4-and-direct-access-to-the-camera

@implementation ARVideoFrameController

- init
{
	if ((self = [super init])) {
		videoFrame.data = NULL;
		videoFrame.index = 0;

		AVCaptureDevice * captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		NSError * error = NULL;
		AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
		
		if (error) {
			NSLog(@"Error: %@", error);
			
			[self release];
			return nil;
		}
		
		// Setup the video output
		AVCaptureVideoDataOutput * captureOutput = [[AVCaptureVideoDataOutput alloc] init];		
		captureOutput.alwaysDiscardsLateVideoFrames = YES;
		
		// Setup the dispatch queue
		[captureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
		
		// Set the frame rate of the camera capture
		[captureOutput setMinFrameDuration:CMTimeMake(1, 30)];
		
		// Set the video capture mode
		[captureOutput setVideoSettings:[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],
			kCVPixelBufferPixelFormatTypeKey,
			nil
		]];
		
		videoFrame.internalFormat = GL_RGBA;
		videoFrame.pixelFormat = GL_BGRA;
		videoFrame.dataType = GL_UNSIGNED_BYTE;
		
		captureSession = [[AVCaptureSession alloc] init];
		
		if ([captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
			[captureSession setSessionPreset:AVCaptureSessionPreset640x480];
		}
		
		[captureSession addInput:captureInput];
		[captureSession addOutput:captureOutput];
		
		NSLog(@"Capture Session Initialised");
	}
	
	return self;
}

- (void) dealloc {
	NSLog(@"Capture Session Deallocated");
	
	[captureSession release];
	
	[super dealloc];
}

- (void) release {
	if ([self retainCount] == 1) {
		[captureSession stopRunning];
		
		// Hack as recommended by Apple.
		dispatch_after(
			dispatch_time(0, 500000000),
			dispatch_get_main_queue(),
			^{
				[super release];
			}
		);
	} else {
		[super release];
	}
}

- (void) start {
	[captureSession startRunning];
}

- (void) stop {
	[captureSession stopRunning];
}

- (ARVideoFrame*) videoFrame {
	return &videoFrame;
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection 
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	// Acquire the image buffer data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 

    // Get information about the image
    uint8_t * baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
	
	size_t count = bytesPerRow * height;
	
	if (videoFrame.data == NULL) {
		videoFrame.data = (unsigned char*)malloc(count);
		
		videoFrame.size.width = width;
		videoFrame.size.height = height;
		videoFrame.bytesPerRow = bytesPerRow;
	}
	
	memcpy(videoFrame.data, baseAddress, bytesPerRow * height);
	videoFrame.index++;
    
	// We unlock the pixel buffer
	CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

	[pool drain];
}

@end