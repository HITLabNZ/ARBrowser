//
//  ARBrowserViewController.m
//  ARBrowser
//
//  Created by Samuel Williams on 5/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import "ARBrowserViewController.h"
#import "ARWorldPoint.h"

@implementation ARBrowserViewController

@synthesize worldPoints = _worldPoints;

- (void)dealloc {
    [self setWorldPoints:nil];
	
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView {
	// -20 for top status bar
	CGRect frame = CGRectMake(0, 0, 320, 480);
	
	// Initialize the OpenGL view
	ARBrowserView * browserView = [[ARBrowserView alloc] initWithFrame:frame];
	
	[browserView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	
	[browserView setDelegate:self];
	
	[self setView:browserView];	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
	
	NSString * developer = [point.metadata objectForKey:@"developer"];
	NSString * address = [point.metadata objectForKey:@"address"];
	
	NSLog(@"Developer %@ at %@", developer, address);
}

@end
