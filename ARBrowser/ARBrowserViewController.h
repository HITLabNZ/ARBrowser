//
//  ARBrowserViewController.h
//  ARBrowser
//
//  Created by Samuel Williams on 5/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARBrowserView.h"

@interface ARBrowserViewController : UIViewController <EAGLViewDelegate, ARBrowserViewDelegate> {
	NSArray * _worldPoints;
}



@end
