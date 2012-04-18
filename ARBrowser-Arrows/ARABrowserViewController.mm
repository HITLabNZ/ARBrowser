//
//  ARABrowserViewController.m
//  ARBrowser-Arrows
//
//  Created by Samuel Williams on 25/03/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARABrowserViewController.h"
#import "ARASegment.h"

@interface ARABrowserViewController ()

@end

@implementation ARABrowserViewController

@synthesize pathController = _pathController, localArrow = _localArrow;
@dynamic worldPoints;

- (void)loadView {
	// Standard view size for iOS UIWindow
	CGRect frame = CGRectMake(0, 0, 320, 480);
	
	// Initialize the OpenGL view
	ARBrowserView * browserView = [[ARBrowserView alloc] initWithFrame:frame];
	
	// Print out FPS information.
	[browserView setDebug:YES];
	
	// Turn on the grid.
	[browserView setDisplayGrid:NO];
	
	[browserView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	
	[browserView setDelegate:self];
	
	// Change the minimum and maximum distance of objects.
	[browserView setMinimumDistance:1.0];
	
	// Icons will never get bigger past this point until the minimumDistance where they are culled.
	[browserView setNearDistance:3.0];
	
	// Icons will never get smaller past this point until the maximumDistance where they are culled.
	[browserView setFarDistance:80.0];
	
	[browserView setMaximumDistance:400.0];
	
	[self setView:browserView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	if (!_locationManager) {
		_locationManager = [CLLocationManager new];
		_locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
		_locationManager.delegate = self;
		
		[_locationManager startUpdatingLocation];
		[_locationManager startUpdatingHeading];
	}
	
	if (!self.localArrow) {
		self.localArrow = [[ARALocalArrow alloc] init];
		self.localArrow.radius = 6.0;
		self.localArrow.angleScale = 0.75;
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	//_compassView.location = newLocation;
	ARWorldLocation * worldLocation = [[ARWorldLocation new] autorelease];
	[worldLocation setCoordinate:newLocation.coordinate altitude:EARTH_RADIUS];
	
	self.pathController.currentSegmentIndex = [self.pathController.path calculateNearestSegmentForLocation:worldLocation];
	
	if (self.pathController.currentSegmentIndex != NSNotFound) {
		NSLog(@"Current segment index: %d", self.pathController.currentSegmentIndex);
		
		ARAPathBearing pathBearing = [self.pathController.path calculateBearingForSegment:self.pathController.currentSegmentIndex withinDistance:25.0 fromLocation:worldLocation];
		self.localArrow.currentBearing = pathBearing.incomingBearing;
		self.localArrow.destinationBearing = pathBearing.outgoingBearing;
	}
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	//_compassView.heading = newHeading;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"ARBrowserViewController: Resuming Rendering.");
	
	ARBrowserView * browserView = (ARBrowserView*)[self view];
	
	[browserView startRendering];
	
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"ARBrowserViewController: Pausing Rendering.");
	
	ARBrowserView * browserView = (ARBrowserView*)[self view];
	
	[browserView stopRendering];
	
	[super viewWillDisappear:animated];
}

- (void) update: (EAGLView*) view {
	// Additional OpenGL Rendering here.
}

- (void)renderInLocalCoordinatesForBrowserView:(ARBrowserView *)view {
	[self.localArrow draw];
}

- (void) browserView: (ARBrowserView*)view didSelect:(ARWorldPoint*)point {
	NSLog(@"Browser view did select: %@", point);
	
	//NSString * developer = [point.metadata objectForKey:@"developer"];
	//NSString * address = [point.metadata objectForKey:@"address"];
	
	//NSLog(@"Developer %@ at %@", developer, address);
}

- (float) browserView: (ARBrowserView*)view scaleFactorFor:(ARWorldPoint*)point atDistance:(float)distance {
	return 1.0;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}

- (NSArray *)worldPoints {
	if (!self.pathController) {
		return [NSArray array];
	} else {
		return self.pathController.visiblePoints;
	}
}

- (NSArray*)worldPointsFromLocation:(ARWorldLocation *)origin withinDistance:(float)distance {
	if (self.pathController) {
		return [self.pathController visiblePointsFromLocation:origin withinDistance:distance];
	} else {
		return [NSArray array];
	}
}

@end
