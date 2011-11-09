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

/*
 
 AVCaptureDevice* camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
 if (camera == nil) {
 return;
 }
 
 captureSession = [[AVCaptureSession alloc] init];
 AVCaptureDeviceInput *newVideoInput = [[[AVCaptureDeviceInput alloc] initWithDevice:camera error:nil] autorelease];
 [captureSession addInput:newVideoInput];
 
 captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
 captureLayer.frame = captureView.bounds;
 [captureLayer setOrientation:AVCaptureVideoOrientationPortrait];
 [captureLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
 [captureView.layer addSublayer:captureLayer];
 
 // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 [captureSession startRunning];
 });
 }
 
 - (void)stopCameraPreview
 {	
 [captureSession stopRunning];
 [captureLayer removeFromSuperlayer];
 [captureSession release];
 [captureLayer release];
 captureSession = nil;
 captureLayer = nil;

 
 */

@implementation ARVideoFrameController

- init
{
	if ((self = [super init])) {
		videoFrame.data = NULL;
		videoFrame.index = 0;

		AVCaptureDevice * captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		
		if (captureDevice == nil) {
			NSLog(@"Couldn't acquire AVCaptureDevice!");
			
			[self release];
			return nil;
		}
			
		NSError * error = nil;
		AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
		
		if (error) {
			NSLog(@"Couldn't create AVCaptureDeviceInput: %@", error);
			
			[self release];
			return nil;
		}
		
		// Setup the video output
		AVCaptureVideoDataOutput * captureOutput = [[AVCaptureVideoDataOutput alloc] init];		
		captureOutput.alwaysDiscardsLateVideoFrames = YES;
		
		// Setup the dispatch queue
		[captureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
		
		// Set the frame rate of the camera capture
		NSUInteger framesPerSecond = 60;
		CMTime secondsPerFrame = CMTimeMake(1, framesPerSecond);
		
		if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
			// iOS4 
			captureOutput.minFrameDuration = secondsPerFrame;
		} else {
			// iOS5 changes
			AVCaptureConnection *captureConnection = [captureOutput connectionWithMediaType:AVMediaTypeVideo];
			
			if ([captureConnection isVideoMinFrameDurationSupported])
				captureConnection.videoMinFrameDuration = secondsPerFrame;
			
			if ([captureConnection isVideoMaxFrameDurationSupported])
				captureConnection.videoMaxFrameDuration = secondsPerFrame;
		}
		
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
	
	[self stop];
	
	for (id input in captureSession.inputs) {
		[captureSession removeInput:input];
	}
	
	for (id output in captureSession.outputs) {
		[output setSampleBufferDelegate:nil queue:nil];
		[captureSession removeOutput:output];
	}	
	
	[captureSession release];
	
	[super dealloc];
}

- (void) start {
	[captureSession startRunning];
	first = YES;
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
	
	if (first) {
		first = NO;
		
		NSLog(@"Image data dimensions = (%ld, %ld)", width, height);
	}
	
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