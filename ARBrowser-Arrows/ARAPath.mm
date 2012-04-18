//
//  ARAPath.m
//  ARBrowser
//
//  Created by Samuel Williams on 25/03/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARAPath.h"
#import "ARModel.h"
#import "ARASegment.h"

/** Hermite interpolation polynomial function.
 
 Tension: 1 is high, 0 normal, -1 is low
 Bias: 0 is even,
 positive is towards first segment,
 negative towards the other
 */
template <typename InterpolateT, typename AnyT>
inline AnyT hermite_polynomial (const InterpolateT & t, const AnyT & p0, const AnyT & m0, const AnyT & p1, const AnyT & m1) {
	float t3 = t*t*t, t2 = t*t;
	
	float h00 = 2*t3 - 3*t2 + 1;
	float h10 = t3 - 2*t2 + t;
	float h01 = -2*t3 + 3*t2;
	float h11 = t3 - t2;
	
	return p0 * h00 + m0 * h10 + p1 * h01 + m1 * h11;
}

@implementation ARAPath

@synthesize points = _points, segments = _segments;

- initWithPoints:(NSArray *)points {
	self = [super init];
	
	if (self != nil) {
		self.points = points;
		
		[self buildSegmentsFromPoints];
	}
	
	return self;
}

- (void)dealloc {
    self.points = nil;
	
    [super dealloc];
}

- (void)buildSegmentsFromPoints {
	if (self.points.count < 2) {		
		return;
	}
	
	// Build a list of segments. For k points, there will be k-1 segments.	
	NSMutableArray * segments = [[NSMutableArray new] autorelease];
	
	ARWorldPoint * from = [self.points objectAtIndex:0];
	ARWorldPoint * to = [self.points objectAtIndex:1];
	
	for (NSInteger i = 2; i < self.points.count; i += 1) {
		ARWorldPoint * next = [self.points objectAtIndex:i];
		
		[segments addObject:[ARASegment segmentFrom:from to:to]];
				
		// Move along one step
		from = to;
		to = next;
	}
	
	[segments addObject:[ARASegment segmentFrom:from to:to]];
	
	self.segments = segments;
}

- (ARAPathBearing)calculateBearingForSegment:(NSUInteger)index withinDistance:(float)distance fromLocation:(ARWorldLocation *)location {
	ARAPathBearing result;
	
	// Given the current segment, the next segment and the previous segment and a circle of size
	ARASegment * segment = [self.segments objectAtIndex:index];
	
	result.incomingBearing = calculateBearingBetween(convertFromDegrees(location.coordinate), convertFromDegrees(segment.to.coordinate));
	
	result.outgoingBearing = result.incomingBearing;
	
	// Are we at the end?
	if (index + 1 < self.segments.count) {
		ARASegment * nextSegment = [self.segments objectAtIndex:index+1];
		
		float cornerDistance = [nextSegment distanceFrom:location];
		
		if (cornerDistance < distance) {
			// Linear interpolation between current bearing and next bearing, based on distance:
			
			CLLocationDegrees outgoingBearing = calculateBearingBetween(convertFromDegrees(location.coordinate), convertFromDegrees(nextSegment.to.coordinate));
			
			float factor = cornerDistance / distance;
			result.outgoingBearing = outgoingBearing * (1.0 - factor) + result.incomingBearing * factor;
		}
	}
	
	NSLog(@"Calculate bearing for segment %d: %0.2f => %0.2f", index, result.incomingBearing, result.outgoingBearing);
	
	return result;
}

- (NSUInteger) calculateNearestSegmentForLocation:(ARWorldLocation *)location {
	float distance = FLT_MAX;
	NSUInteger index = NSNotFound;
	
	NSUInteger i = 0;
	for (ARASegment * segment in self.segments) {
		float segmentDistance = [segment distanceFrom:location];
		
		if (segmentDistance < distance) {
			distance = segmentDistance;
			index = i;
		}
		
		i += 1;
	}
	
	return index;
}

@end
