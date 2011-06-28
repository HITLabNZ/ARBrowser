//
//  ARBrowserViewController.m
//  ARBrowser
//
//  Created by Samuel Williams on 5/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
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
	NSMutableArray * worldPoints = [[NSMutableArray new] retain];
	CLLocationCoordinate2D location;

	// Coffee cup model
	NSString * coffeePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Models/coffee"];
	id<ARRenderable> coffeeCupModel = [ARModel objectModelWithName:@"model" inDirectory:coffeePath];
	
	// 2 Derenzy Pl
	ARWorldPoint * derenzy = [ARWorldPoint new];
	location.latitude = -43.516215;
	location.longitude = 172.554560;
	[derenzy setCoordinate:location altitude:EARTH_RADIUS];
	[derenzy setModel:coffeeCupModel];
	
	// This name is used for debugging output.
	[derenzy.metadata setObject:@"2 Derenzy Pl" forKey:@"name"];
	
	// This information is printed out below.
	[derenzy.metadata setObject:@"2 Derenzy Pl" forKey:@"address"];
	[derenzy.metadata setObject:@"Samuel Williams" forKey:@"developer"];
	[worldPoints addObject:derenzy];
		
	// HitLab NZ
	ARWorldPoint * hitlab = [ARWorldPoint new];
	location.latitude = -43.522190;
	location.longitude = 172.583020;
	[hitlab setCoordinate:location altitude:EARTH_RADIUS];
	[hitlab setModel:coffeeCupModel];
	[hitlab.metadata setObject:@"HITLabNZ" forKey:@"name"];
	[hitlab.metadata setObject:@"University of Canterbury" forKey:@"address"];
	[hitlab.metadata setObject:@"Mark Billinghurst" forKey:@"developer"];
	[worldPoints addObject:hitlab];
	
	// HitLab NZ
	ARWorldPoint * cuteCenter = [ARWorldPoint new];
	location.latitude = 1.29231;
	location.longitude = 103.775769;
	[cuteCenter setCoordinate:location altitude:EARTH_RADIUS];
	[cuteCenter setModel:coffeeCupModel];
	[cuteCenter.metadata setObject:@"Cute Center" forKey:@"name"];
	[cuteCenter.metadata setObject:@"Singapore" forKey:@"address"];
	[cuteCenter.metadata setObject:@"Wang Yuan" forKey:@"developer"];
	[worldPoints addObject:cuteCenter];
	
	_worldPoints = worldPoints;
	
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

- (void) update: (EAGLView*) view {
	// Additional OpenGL Rendering here.
}

- (void) browserView: (ARBrowserView*)view didSelect:(ARWorldPoint*)point {
	NSLog(@"Browser view did select: %@", point);
	
	NSString * developer = [point.metadata objectForKey:@"developer"];
	NSString * address = [point.metadata objectForKey:@"address"];
	
	NSLog(@"Developer %@ at %@", developer, address);
}

@end
