//
//  ARFirstViewController.m
//  ARBrowser-VideoStream
//
//  Created by Samuel Williams on 22/12/11.
//  Copyright (c) 2011 Orion Transfer Ltd. All rights reserved.
//

#import "ARVSCaptureViewController.h"
#import "ARVSCaptureView.h"
#import "ARVSLogger.h"

double length(CMAcceleration vector) {
	return sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
}

@implementation ARVSCaptureViewController

@synthesize logger = _logger, velocityTextView = _velocityTextView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [self setLogger:nil];
	
	[_motionManager release];
	[_motionQueue release];
	
    [super dealloc];
}

#pragma mark - Logging callbacks

- (void)videoFrameController:(ARVideoFrameController *)controller didCaptureFrame:(CGImageRef)buffer atTime:(CMTime)time {	
	if (self.logger) {
		NSLog(@"Saving frame %d", _frameOffset);
		
		[self.logger logWithFormat:@"Frame Captured, %d, %0.4f", _frameOffset, CMTimeGetSeconds(time)]; 
		[self.logger logImage:buffer withFormat:@"%d", _frameOffset];
		
		_frameOffset += 1;
	}
}

#pragma mark - View lifecycle

- (void)loadView {	
	// Standard view size for iOS UIWindow
	CGRect frame = CGRectMake(0, 0, 320, 480);
	
	// Initialize the OpenGL view
	ARVSCaptureView * captureView = [[ARVSCaptureView alloc] initWithFrame:frame];
	[captureView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	
	[captureView.videoFrameController setDelegate:self];
	
	// A switch to control logging:
	UISwitch * toggleLogging = [[UISwitch alloc] initWithFrame:CGRectMake(10, 10, 100, 40)];
	[toggleLogging setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin];
	[toggleLogging addTarget:self action:@selector(toggleLogging:) forControlEvents:UIControlEventValueChanged];
	[captureView addSubview:toggleLogging];
	[toggleLogging release];
	
	self.velocityTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, frame.size.height - 60, frame.size.width - 20, 30)];
	[self.velocityTextView setEditable:NO];
	[self.velocityTextView setText:@"-"];
	[captureView addSubview:self.velocityTextView];

	_graphView = [[ARVSGraphView alloc] initWithFrame:CGRectMake(10, 50, frame.size.width - 20, 80)];
	[_graphView setSequenceCount:3];
	
	[_graphView setColor:[UIColor redColor] ofSequence:0];
	[_graphView setColor:[UIColor greenColor] ofSequence:1];
	[_graphView setColor:[UIColor blueColor] ofSequence:2];
	
	[_graphView setPointCount:(frame.size.width - 20) / 3];
	_graphView.scale = 100.0;
	
	[captureView addSubview:_graphView];
	
	[self setView:captureView];
}

- (void)toggleLogging:(UISwitch*)sender {
	if ([sender isOn]) {
		_frameOffset = 0;
		[self setLogger:[ARVSLogger loggerForDocumentName:@"VideoStream"]];
	} else {
		[self.logger close];
		[self setLogger:nil];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"ARBrowserViewController: Resuming Rendering.");
	
	ARVSCaptureView * captureView = (ARVSCaptureView*)[self view];
	
	[captureView startRendering];
	
	[super viewDidAppear:animated];
	
	if (!_motionQueue) {
		_motionQueue = [[NSOperationQueue mainQueue] retain];
		//_motionQueue = [[NSOperationQueue alloc] init];
	}
	
	if (!_motionManager) {
		_motionManager = [[CMMotionManager alloc] init];
		
		NSTimeInterval rate = 1.0 / 10.0;
		
		[_motionManager setAccelerometerUpdateInterval:rate];
		[_motionManager setDeviceMotionUpdateInterval:rate];
		_previousTime = -1;
		
		[self.logger logWithFormat:@"Motion Rate, %0.4f", rate];
	}
	
	[_motionManager startAccelerometerUpdatesToQueue:_motionQueue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
		CMAcceleration acceleration = accelerometerData.acceleration;
		
		CGFloat points[3] = {acceleration.x, acceleration.y, acceleration.z};
		//CGFloat points[3] = {rotation.x, rotation.y, rotation.z};
		[_graphView addPoints:points];
	}];
	
	[_motionManager startDeviceMotionUpdatesToQueue:_motionQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {		
		CMAcceleration acceleration = motion.userAcceleration;
		CMAcceleration gravity = motion.gravity;
		CMRotationRate rotation = motion.rotationRate;
				
		[self.logger logWithFormat:@"Gyroscope, %0.4f, %0.6f, %0.6f, %0.6f", motion.timestamp, rotation.x, rotation.y, rotation.z];
		[self.logger logWithFormat:@"Accelerometer, %0.4f, %0.6f, %0.6f, %0.6f", motion.timestamp, acceleration.x, acceleration.y, acceleration.z];
		[self.logger logWithFormat:@"Gravity, %0.4f, %0.6f, %0.6f, %0.6f", motion.timestamp, gravity.x, gravity.y, gravity.z];
		
		if (_previousTime == -1) {
			_previousTime = motion.timestamp;
			return;
		}
		
		NSTimeInterval delta = motion.timestamp - _previousTime;
		ARVSVelocity velocity = _currentVelocity;
		
		if (length(acceleration) > 0.1) {
			velocity.x += acceleration.x * delta;
			velocity.y += acceleration.y * delta;
			velocity.z += acceleration.z * delta;	
		}
		
		_currentVelocity = velocity;
		
		[self.logger logWithFormat:@"Velocity, %0.4f, %0.6f, %0.6f, %0.6f, %0.6f", motion.timestamp, delta, velocity.x, velocity.y, velocity.z];
		
		double speed = length(velocity);
		NSString * velocityString = [NSString stringWithFormat:@"%0.3f m/s: %0.3f, %0.3f, %0.3f\n(%0.3f, %0.3f, %0.3f)", speed, velocity.x, velocity.y, velocity.z, acceleration.x, acceleration.y, acceleration.z];
		[self.velocityTextView performSelector:@selector(setText:) onThread:[NSThread mainThread] withObject:velocityString waitUntilDone:NO];
	}];
}

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"ARBrowserViewController: Pausing Rendering.");
	
	ARVSCaptureView * captureView = (ARVSCaptureView*)[self view];
	
	[captureView stopRendering];
	
	[_motionManager stopDeviceMotionUpdates];
	[_motionManager stopAccelerometerUpdates];
	
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
