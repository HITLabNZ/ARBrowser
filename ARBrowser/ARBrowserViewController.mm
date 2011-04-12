//
//  ARBrowserViewController.m
//  ARBrowser
//
//  Created by Samuel Williams on 5/04/11.
//  Copyright 2011 Orion Transfer Ltd. All rights reserved.
//

#import "ARBrowserViewController.h"
#import "ARBrowserView.h"
#import "ARWorldPoint.h"
#import "ARModel.h"

@implementation ARBrowserViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	ARWorldPoint * coffeeCup = [ARWorldPoint new];
	
	NSString * coffeePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Models/coffee"];
	[coffeeCup setModel:[[ARModel alloc] initWithName:@"model" inDirectory:coffeePath]];
	
	CLLocationCoordinate2D location;
	location.latitude = -43.516215;
	location.longitude = 172.554560;
	[coffeeCup setCoordinate:location altitude:EARTH_RADIUS];
	
	_worldPoints = [[NSArray arrayWithObject:coffeeCup] retain];
	
    [super viewDidLoad];
}


- (void)loadView {
	CGRect frame = CGRectMake(0, 0, 320, 480);
	
	// Initialize the OpenGL view
	ARBrowserView * browserView = [[ARBrowserView alloc] initWithFrame:frame];
	
	[browserView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	
	[browserView setDelegate:self];
	
	[self setView:browserView];	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- worldPoints {
	return _worldPoints;
}

@end
