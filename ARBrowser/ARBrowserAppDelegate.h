//
//  ARBrowserAppDelegate.h
//  ARBrowser
//
//  Created by Samuel Williams on 5/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARBrowserViewController;

/// The main application delegate which initialises the window and manages the associated view controller.
@interface ARBrowserAppDelegate : NSObject <UIApplicationDelegate> {
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ARBrowserViewController *viewController;

@end
