//
//  ARBrowserViewController.h
//  ARBrowser
//
//  Created by Samuel Williams on 5/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EAGLView.h"

@interface ARBrowserViewController : UIViewController <EAGLViewDelegate> {
	NSArray * _worldPoints;
}



@end
