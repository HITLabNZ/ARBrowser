//
//  ARBrowserAppDelegate.h
//  ARBrowser
//
//  Created by Samuel Williams on 5/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARBrowserViewController;

@interface ARBrowserAppDelegate : NSObject <UIApplicationDelegate> {
	//ARBRowserViewController * browserViewController;
	//ARMapViewController * mapViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ARBrowserViewController *viewController;

// setWorldPoints
// worldPoints

// showBrowserView
// showMapView

@end
