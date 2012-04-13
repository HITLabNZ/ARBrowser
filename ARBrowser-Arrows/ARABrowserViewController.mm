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

@synthesize pathController;
@dynamic worldPoints;

- (void)loadView {
	// Standard view size for iOS UIWindow
	CGRect frame = CGRectMake(0, 0, 320, 480);
	
	// Initialize the OpenGL view
	ARBrowserView * browserView = [[ARBrowserView alloc] initWithFrame:frame];
	
	// Print out FPS information.
	[browserView setDebug:YES];
	
	// Turn on the grid.
	[browserView setDisplayGrid:YES];
	
	[browserView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	
	[browserView setDelegate:self];
	
	// Change the minimum and maximum distance of objects.
	[browserView setMinimumDistance:1.0];
	
	// Icons will never get bigger past this point until the minimumDistance where they are culled.
	[browserView setNearDistance:3.0];
	
	// Icons will never get smaller past this point until the maximumDistance where they are culled.
	[browserView setFarDistance:25.0];
	
	[browserView setMaximumDistance:400.0];
	
	[self setView:browserView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	if (!_locationManager) {
		_locationManager = [CLLocationManager new];
		_locationManager.delegate = self;
		
		[_locationManager startUpdatingLocation];
		[_locationManager startUpdatingHeading];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	//_compassView.location = newLocation;
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

- (NSArray*)worldPointsFromLocation:(ARWorldLocation *)origin {
	if (self.pathController) {
		return [self.pathController visiblePointsFromLocation:origin];
	} else {
		return [NSArray array];
	}
}

@end
