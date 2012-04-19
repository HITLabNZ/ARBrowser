//
//  ARAAppDelegate.m
//  ARBrowser-Arrows
//
//  Created by Samuel Williams on 25/03/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARAAppDelegate.h"

#import "ARABrowserViewController.h"
#import "ARAPathEditorController.h"

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
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

	ARAPathController * pathController = [[ARAPathController new] autorelease];
	
	UITabBarController * tabBarController = [[UITabBarController new] autorelease];
	
	ARAPathEditorController * pathEditorController = [[ARAPathEditorController new] autorelease];
	pathEditorController.pathController = pathController;
	[tabBarController addChildViewController:pathEditorController];
	
	// This is just testing data, and even with that, this is a pretty crappy way to load it.. but it is fine for now.
#ifdef PREDEFINED_ROUTE_ICUBE_BUILDING
	CLLocationCoordinate2D coordinates[] = {
		{1.291992, 103.775976},
		{1.292271, 103.775470},
		{1.292573, 103.775565},
		{1.292609, 103.775757},
		{1.292408, 103.776214},
		{1.292037, 103.776167},
		{1.291862, 103.776241},
		{1.291751, 103.776231},
		{1.291787, 103.776036},
		{1.292050, 103.775906}
	};
	
	for (unsigned i = 0; i < 10; i += 1) {
		[pathEditorController addPoint:coordinates[i]];
	}
#endif
	
	ARABrowserViewController * browserViewController = [[ARABrowserViewController new] autorelease];
	browserViewController.pathController = pathController;
	[tabBarController addChildViewController:browserViewController];
	
	self.viewController = tabBarController;
	
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
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
