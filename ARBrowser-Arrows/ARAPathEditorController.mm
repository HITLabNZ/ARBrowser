//
//  ARAPathEditorController.m
//  ARBrowser
//
//  Created by Samuel Williams on 2/04/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARAPathEditorController.h"
#import "ARWorldPoint.h"

#import <AudioToolbox/AudioToolbox.h>

@implementation ARAPathEditorController

@synthesize pathController;
@synthesize points = _points;

- (id)init {
	self = [super init];
	
	if (self != nil) {
		self.points = [NSMutableArray array];
	}
	
	return self;
}

- (void)dealloc {
	self.points = nil;
	
	[super dealloc];
}

- (void) addPoint:(CLLocationCoordinate2D)coordinate {
	NSLog(@"Adding coordinate @ %0.6f, %0.6f", coordinate.latitude, coordinate.longitude);
	
	ARWorldPoint * point = [[ARWorldPoint new] autorelease];

	// This altitude calculation isn't entirely correct, because if we are on a mountain the error could be large.
	[point setCoordinate:coordinate altitude:EARTH_RADIUS];
	
	point.model = self.pathController.markerModel;
	
	[_points addObject:point];
	[(MKMapView*)self.view addAnnotation:point];
	
	self.pathController.path = [[[ARAPath alloc] initWithPoints:self.points] autorelease];
	
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
		 
- (void)handleDropPinGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
	
    CGPoint touchPoint = [gestureRecognizer locationInView:self.view];   
    CLLocationCoordinate2D coordinate = [(MKMapView*)self.view convertPoint:touchPoint toCoordinateFromView:self.view];	
	
	[self addPoint:coordinate];
}

- (void)loadView {
	MKMapView * mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];

	[mapView setShowsUserLocation:YES];
	[mapView setMapType:MKMapTypeHybrid];
	
	UILongPressGestureRecognizer * dropPinGesture = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDropPinGesture:)] autorelease];
	dropPinGesture.minimumPressDuration = 1.0; //user needs to press for 2 seconds
	[mapView addGestureRecognizer:dropPinGesture];
		
	self.view = mapView;
}

- (void) setVisibleLocation:(CLLocation*)location {
	MKCoordinateRegion region;
	region.center = [location coordinate];
	
	// This defines the size of the region around the center
	region.span.latitudeDelta = 0.002;
	region.span.longitudeDelta = 0.002;
	
	[(MKMapView*)self.view setRegion:region animated:YES];
}

@end
