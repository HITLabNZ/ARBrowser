//
//  ARAPathEditorController.h
//  ARBrowser
//
//  Created by Samuel Williams on 2/04/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "ARAPathController.h"

@interface ARAPathEditorController : UIViewController {
	NSMutableArray * _points;
	CLLocationManager * _locationManager;
}

@property(nonatomic,retain) ARAPathController * pathController;
@property(nonatomic,retain) NSMutableArray * points;

- (void) addPoint:(CLLocationCoordinate2D)coordinate;

- (void) setVisibleLocation:(CLLocation*)location;

@end
