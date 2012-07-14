//
//  ARAAppDelegate.h
//  ARBrowser-Arrows
//
//  Created by Samuel Williams on 25/03/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARABrowserViewController.h"
#import "ARAPathEditorController.h"
#import "ARARouteSelectionViewController.h"

@interface ARAAppDelegate : UIResponder <UIApplicationDelegate, ARARouteSelectionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController * viewController;

@end
