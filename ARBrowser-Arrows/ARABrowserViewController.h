//
//  ARABrowserViewController.h
//  ARBrowser-Arrows
//
//  Created by Samuel Williams on 25/03/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "ARBrowserView.h"
#import "ARAPathController.h"
#import "ARALocalArrow.h"
#import "ARANavigationViewController.h"

//#define ARA_DEBUG

@interface ARABrowserViewController : UIViewController <EAGLViewDelegate, ARBrowserViewDelegate, CLLocationManagerDelegate>

@property(nonatomic,retain) ARALocalArrow * localArrow;
@property(nonatomic,retain) ARAPathController * pathController;
@property(nonatomic,retain,readonly) NSArray * worldPoints;

#ifdef ARA_DEBUG
@property(nonatomic,retain) UILabel * segmentIndexLabel;
@property(nonatomic,retain) UILabel * bearingLabel;
#endif

@property(nonatomic,retain) ARANavigationViewController * navigationViewController;

@end
