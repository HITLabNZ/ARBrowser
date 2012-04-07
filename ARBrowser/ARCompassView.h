//
//  CompassView.h
//  ARToolKit-oe
//
//  Created by Samuel Williams on 14/02/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "ARWorldLocation.h"

@interface ARCompassView : UIView {
    NSArray * _locations;
	NSMutableArray * _markers;
	
	CLLocation * _location;
	CLHeading * _heading;
}

@property(readwrite,retain) NSArray * locations;

@property(readwrite,retain) CLHeading * heading;
@property(readwrite,retain) CLLocation * location;

@end
