//
//  ARASegment.m
//  ARBrowser
//
//  Created by Samuel Williams on 3/04/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARASegment.h"
#import "ARWorldLocation.h"

@implementation ARASegment

@synthesize steps = _steps;

+ (ARASegment *)segmentFrom:(ARWorldLocation *)from to:(ARWorldLocation *)to {
	// Probably best to use spherical interpolation, but we'll just use linear interpolation for now:
	NSMutableArray * steps = [NSMutableArray array];
	
	Vec3d begin = {from.coordinate.latitude, from.coordinate.longitude, from.altitude};
	Vec3d end = {to.coordinate.latitude, to.coordinate.longitude, to.altitude};
	Vec3d delta = end - begin;
	double length = delta.length();
	
	Vec3d step = delta.normalized();
	CLLocationDirection bearing = 180 - calculateBearingBetween(convertFromDegrees(from.coordinate), convertFromDegrees(to.coordinate));
	
	const double INCREMENT = 0.0001 / 1.5;
	
	for (double offset = INCREMENT; offset < (length - INCREMENT); offset += INCREMENT) {
		Vec3d coordinate = begin + (step * offset);
		NSLog(@"Coordinate: %0.6f = %0.8f, %0.8f", offset, coordinate.x, coordinate.y);
				
		ARWorldLocation * intermediateLocation = [[ARWorldPoint new] autorelease];
		[intermediateLocation setCoordinate:(CLLocationCoordinate2D){coordinate.x, coordinate.y} altitude:coordinate.z];
		[intermediateLocation setBearing:bearing];
		
		[steps addObject:intermediateLocation];
	}
	
	ARASegment * segment = [[ARASegment new] autorelease];
	
	segment.steps = steps;
	
	return segment;
}

- (BOOL) isVisibleFrom:(ARWorldLocation *)location {
	for (ARWorldLocation * step in self.steps) {
		CLLocationDistance distance = calculateDistanceBetween(convertFromDegrees(location.coordinate), convertFromDegrees(step.coordinate), step.altitude);
		
		if (distance < 10.0)
			return YES;
	}
	
	return NO;
}

@end
