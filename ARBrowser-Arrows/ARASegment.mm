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

@synthesize steps = _steps, from = _from, to = _to;

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
	
	segment.from = from;
	segment.to = to;
	segment.steps = steps;
	
	return segment;
}

static float minimum_distance(Vec3 v, Vec3 w, Vec3 p) {
	// Return minimum distance between line segment vw and point p
	
	// i.e. |w-v|^2 -  avoid a sqrt
	const float l2 = (w - v).lenSqr();
	
	if (l2 == 0.0) return (v - p).length();   // v == w case
	
	// Consider the line extending the segment, parameterized as v + t (w - v).
	// We find projection of point p onto the line. 
	// It falls where t = [(p-v) . (w-v)] / |w-v|^2
	const float t = (p - v).dot(w - v) / l2;
	
	if (t < 0.0) return (v - p).length();       // Beyond the 'v' end of the segment
	else if (t > 1.0) return (w - p).length();  // Beyond the 'w' end of the segment
	
	const Vec3 projection = v + t * (w - v);  // Projection falls on the segment
	return (projection - p).length();
}

- (float) distanceFrom:(ARWorldLocation *)location {
	return minimum_distance(self.from.position, self.to.position, location.position);	
}

@end
