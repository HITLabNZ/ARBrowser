//
//  ARABrowserViewController.m
//  ARBrowser-Arrows
//
//  Created by Samuel Williams on 25/03/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARABrowserViewController.h"
#import "ARASegment.h"
#import "ARLocationController.h"

@interface ARABrowserViewController ()

@end

@implementation ARABrowserViewController

@synthesize pathController = _pathController, localArrow = _localArrow;

#ifdef ARA_DEBUG
@synthesize segmentIndexLabel = _segmentIndexLabel, bearingLabel = _bearingLabel;
#endif

@synthesize navigationViewController = _navigationViewController;
@dynamic worldPoints;

- (void)loadView {
	// Standard view size for iOS UIWindow, minus 50 for tab bar at bottom.
	CGRect frame = CGRectMake(0, 0, 320, 480 - 50.0);
	
	// Initialize the OpenGL view
	ARBrowserView * browserView = [[ARBrowserView alloc] initWithFrame:frame];
	
	// Print out FPS information.
	[browserView setDebug:NO];
	
	// Turn on the grid.
	[browserView setDisplayGrid:NO];
	
	[browserView setDisplayRadar:NO];
	
	[browserView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	
	[browserView setDelegate:self];
	
	// Change the minimum and maximum distance of objects.
	[browserView setMinimumDistance:1.0];
	
	// Icons will never get bigger past this point until the minimumDistance where they are culled.
	[browserView setNearDistance:3.0];
	
	// Icons will never get smaller past this point until the maximumDistance where they are culled.
	[browserView setFarDistance:80.0];
	
	[browserView setMaximumDistance:400.0];
	
#ifdef ARA_DEBUG
	self.segmentIndexLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 180, 20)];
	self.segmentIndexLabel.backgroundColor = [UIColor whiteColor];
	self.segmentIndexLabel.font = [UIFont systemFontOfSize:9.0];
	[browserView addSubview:self.segmentIndexLabel];
	
	self.bearingLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15+30, 180, 20)];
	self.bearingLabel.backgroundColor = [UIColor whiteColor];
	self.bearingLabel.font = [UIFont systemFontOfSize:9.0];
	[browserView addSubview:self.bearingLabel];
	
	//self.pathController.debugLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15+60, 180, 20)];
	//self.pathController.debugLabel.backgroundColor = [UIColor whiteColor];
	//self.pathController.debugLabel.font = [UIFont systemFontOfSize:9.0];
	//[browserView addSubview:self.pathController.debugLabel];
#endif
	
	self.navigationViewController = [[ARANavigationViewController alloc] init];
	
	CGRect navigationViewFrame = self.navigationViewController.view.frame;
	navigationViewFrame.origin.y = frame.size.height - navigationViewFrame.size.height;
	self.navigationViewController.view.frame = navigationViewFrame;
	[browserView addSubview:self.navigationViewController.view];
		
	[self setView:browserView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	if (!self.localArrow) {
		self.localArrow = [[ARALocalArrow alloc] init];
		self.localArrow.radius = 3.0;
		self.localArrow.angleScale = 0.75;
	}
	
	if (self.pathController) {
		self.navigationViewController.miniMapView.pathController = self.pathController;
	}
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
	ARLocationController * locationController = view.locationController;
	ARWorldLocation * worldLocation = locationController.worldLocation;
	
	// Update the mini-map location:
	self.navigationViewController.miniMapView.location = worldLocation;
	
	// Update the current segment if necessary:
	if ([self.pathController updateLocation:worldLocation]) {
		// Segment was updated:
		ARWorldPoint * segmentTurn = (ARWorldPoint *)self.pathController.currentSegment.to;
		NSDictionary * turnMetadata = [segmentTurn metadata];
		
		[self.navigationViewController.directionsLabel setText:[turnMetadata objectForKey:@"directions"]];
		[self.navigationViewController.turnImageView setImage:[UIImage imageNamed:[turnMetadata objectForKey:@"icon"]]];
		
		[self.navigationViewController.miniMapView setNeedsDisplay];
	}
	
	ARASegmentDisposition disposition = [self.pathController.currentSegment dispositionRelativeTo:worldLocation];
	
#ifdef ARA_DEBUG
	self.segmentIndexLabel.text = [NSString stringWithFormat:@"Segment %d:%d (turning = %d, ratio = %0.3f)", self.pathController.currentSegmentIndex, disposition, self.pathController.turning, self.pathController.turningRatio];
#endif
	
	if (self.pathController.currentSegmentIndex != NSNotFound) {
		ARAPathBearing pathBearing = [self.pathController currentBearing];
		
		self.localArrow.pathBearing = pathBearing;
		self.localArrow.currentBearing = worldLocation.rotation;

#ifdef ARA_DEBUG
		NSString * percentageThroughCorner = @"-";
		
		if (pathBearing.distanceFromMidpoint < self.pathController.turningRadius) {
			percentageThroughCorner = [NSString stringWithFormat:@"%0.1f%%", (pathBearing.distanceFromMidpoint / self.pathController.turningRadius) * 100.0];
		}
	
		self.bearingLabel.text = [NSString stringWithFormat:@"%0.2f => %0.2f : %0.2f; (%0.1f, %@)", pathBearing.incomingBearing, pathBearing.outgoingBearing, worldLocation.rotation, pathBearing.distanceFromMidpoint, percentageThroughCorner];
#endif
				
		if (self.pathController.turning) {
			self.navigationViewController.distanceLabel.text = @"Turning";
			self.navigationViewController.turnImageView.overlayColor = [UIColor redColor];
		} else {
			[self.navigationViewController setDistance:pathBearing.distanceFromMidpoint];
			self.navigationViewController.turnImageView.overlayColor = nil;
		}
	}
	
	// Don't draw the arrow unless the bearing has been computed accurately:
	if (locationController.currentHeading) {
		[self.localArrow drawForBrowserView:view];
	}
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
