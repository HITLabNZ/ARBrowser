//
//  ARBrowserAppDelegate.h
//  ARBrowser
//
//  Created by Samuel Williams on 5/04/11.
//  Copyright 2011 Orion Transfer Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARBrowserViewController;

@interface ARBrowserAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet ARBrowserViewController *viewController;

@end
