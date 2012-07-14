//
//  ARAAppDelegate.m
//  ARBrowser-Arrows
//
//  Created by Samuel Williams on 25/03/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARAAppDelegate.h"

@implementation ARAAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
	[_window release];
	[_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	self.viewController = [UINavigationController new];
	
	ARARouteSelectionViewController * routeSelectionViewController = [[ARARouteSelectionViewController alloc] init];
	routeSelectionViewController.delegate = self;
	routeSelectionViewController.navigationItem.title = @"Routes";
	
	[self.viewController pushViewController:routeSelectionViewController animated:NO];
	
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)selectedRouteWithPath:(NSString *)path {
	ARABrowserViewController * browserViewController = [[ARABrowserViewController new] autorelease];
	browserViewController.navigationItem.title = [[path lastPathComponent] stringByDeletingPathExtension];

	ARAPathController * pathController = [[ARAPathController new] autorelease];
	pathController.path = [ARAPath routeWithPath:path];
	
	browserViewController.pathController = pathController;
	
	[self.viewController pushViewController:browserViewController animated:YES];
}

- (void) startRoute:(id)sender {
	ARAPathEditorController * pathEditorController = (ARAPathEditorController*)self.viewController.topViewController;
	
	ARABrowserViewController * browserViewController = [[ARABrowserViewController new] autorelease];
	browserViewController.navigationItem.title = @"Custom Route";
	
	browserViewController.pathController = pathEditorController.pathController;
	
	[self.viewController pushViewController:browserViewController animated:YES];	
}

- (void)selectedCustomRoute {
	ARAPathEditorController * pathEditorController = [[ARAPathEditorController new] autorelease];
	pathEditorController.navigationItem.title = @"Path Editor";
	
	UIBarButtonItem * startRouteButton = [[[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(startRoute:)] autorelease];
	pathEditorController.navigationItem.rightBarButtonItem = startRouteButton;	
	
	ARAPathController * pathController = [[ARAPathController new] autorelease];
	pathController.path = [[ARAPath new] autorelease];
	
	[self.viewController pushViewController:pathEditorController animated:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
