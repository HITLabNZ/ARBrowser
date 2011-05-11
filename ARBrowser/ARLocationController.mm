//
//  ARLocationController.m
//  ARBrowser
//
//  Created by Samuel Williams on 13/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import "ARLocationController.h"
#import "ARWorldLocation.h"

#define kAccelerometerFrequency     60.0 // Hz
#define kFilteringFactor 0.1

@implementation ARLocationController

- (id)init {
    self = [super init];
    if (self) {
		locationManager = [[CLLocationManager alloc] init];
		[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
		[locationManager setDelegate:self];
		
		[locationManager startUpdatingLocation];
		[locationManager startUpdatingHeading];
		
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
    }
    return self;
}

- (void)dealloc {
    [locationManager setDelegate:nil];
	[locationManager release];
	
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	
    [super dealloc];
}

@synthesize currentLocation, currentHeading;

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	//NSLog(@"Location Updated!");
	
	[currentLocation release];
	currentLocation = [newLocation retain];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	//NSLog(@"Heading Updated!");
	
	[currentHeading release];
	currentHeading = [newHeading retain];
}

@synthesize currentAcceleration;

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
    //Use a basic low-pass filter to only keep the gravity in the accelerometer values
    currentAcceleration.x = acceleration.x * kFilteringFactor + currentAcceleration.x * (1.0 - kFilteringFactor);
    currentAcceleration.y = acceleration.y * kFilteringFactor + currentAcceleration.y * (1.0 - kFilteringFactor);
    currentAcceleration.z = acceleration.z * kFilteringFactor + currentAcceleration.z * (1.0 - kFilteringFactor);
}

- (ARWorldLocation*) worldLocation
{	
	if ([self currentLocation] && [self currentHeading]) {
		ARWorldLocation * result = [[ARWorldLocation new] autorelease];
		
		[result setLocation:[self currentLocation] globalRadius:EARTH_RADIUS];
		[result setHeading:[self currentHeading]];
		
		return result;
	}
	
	return nil;
}

+ sharedInstance
{
	static ARLocationController * _sharedInstance = nil;
	
	if (_sharedInstance == nil) {
		_sharedInstance = [[ARLocationController alloc] init];
	}
	
	return _sharedInstance;
}

@end
