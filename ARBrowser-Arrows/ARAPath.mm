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

static ARAPathBounds ARAPathBoundsFromCoordinate(CLLocationCoordinate2D coordinate) {
	return (ARAPathBounds){coordinate, coordinate};
}

// This function won't correctly calculate the bounding box for longitudinal values that go between -180 and +180.
static ARAPathBounds ARAPathBoundsIncludingCoordinate(ARAPathBounds bounds, CLLocationCoordinate2D coordinate) {
	if (coordinate.latitude < bounds.minimum.latitude) {
		bounds.minimum.latitude = coordinate.latitude;
	} else if (coordinate.latitude > bounds.maximum.latitude) {
		bounds.maximum.latitude = coordinate.latitude;
	}
	
	if (coordinate.longitude < bounds.minimum.longitude) {
		bounds.minimum.longitude = coordinate.longitude;
	} else if (coordinate.longitude > bounds.maximum.longitude) {
		bounds.maximum.longitude = coordinate.longitude;
	}
	
	return bounds;
}

CGPoint ARAPathBoundsScaleCoordinate(ARAPathBounds mapBounds, CLLocationCoordinate2D coordinate, CGRect displayBounds, BOOL clip) {
	// Computes a coordinate between 0...1 relative to the size of the bounds:
	CLLocationCoordinate2D relativeCoordinate = {
		(coordinate.latitude - mapBounds.minimum.latitude) / (mapBounds.maximum.latitude - mapBounds.minimum.latitude),
		(coordinate.longitude - mapBounds.minimum.longitude) / (mapBounds.maximum.longitude - mapBounds.minimum.longitude)
	};
	
	if (clip) {
		if (relativeCoordinate.latitude < 0.0)
			relativeCoordinate.latitude = 0.0;
		else if (relativeCoordinate.latitude > 1.0)
			relativeCoordinate.latitude = 1.0;
		
		if (relativeCoordinate.longitude < 0.0)
			relativeCoordinate.longitude = 0.0;
		else if (relativeCoordinate.longitude > 1.0)
			relativeCoordinate.longitude = 1.0;
	}
	
	CGPoint transformedPoint = {
		(relativeCoordinate.longitude * displayBounds.size.width) + displayBounds.origin.x,
		((1.0 - relativeCoordinate.latitude) * displayBounds.size.height) + displayBounds.origin.y
	};
	
	return transformedPoint;
}

ARAPathBounds ARAPathBoundsWithAspectRatio(ARAPathBounds bounds, CGSize size) {
	double width = bounds.maximum.longitude - bounds.minimum.longitude;
	double height = bounds.maximum.latitude - bounds.minimum.latitude;
	
	double desiredAspectRatio = width / height;
	double aspectRatio = size.width / size.height;
	
	if (desiredAspectRatio < aspectRatio) {
		double requiredWidth = height * aspectRatio;
		double difference = requiredWidth - width;
		
		bounds.maximum.longitude += (difference / 2.0);
		bounds.minimum.longitude -= (difference / 2.0);
	} else {
		double requiredHeight = width * (1.0 / aspectRatio);
		double difference = requiredHeight - height;
		
		bounds.maximum.latitude += (difference / 2.0);
		bounds.minimum.latitude -= (difference / 2.0);
	}
	
	return bounds;
}

@implementation ARAPath

@synthesize points = _points, segments = _segments, bounds = _bounds;

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
	
	ARAPathBounds bounds = ARAPathBoundsFromCoordinate(from.coordinate);
	
	// We have this loop to go over all points except for the last one, which is handled explicitly:
	for (NSInteger i = 2; i < self.points.count; i += 1) {
		ARWorldPoint * next = [self.points objectAtIndex:i];
		
		[segments addObject:[[ARASegment alloc] initFrom:from to:to]];
		
		// Expand the bounds if necessary:
		bounds = ARAPathBoundsIncludingCoordinate(bounds, to.coordinate);
						
		// Move along one step
		from = to;
		to = next;
	}
	
	// Last point -> segment:
	[segments addObject:[[ARASegment alloc] initFrom:from to:to]];
	bounds = ARAPathBoundsIncludingCoordinate(bounds, to.coordinate);
	
	self.segments = segments;
	_bounds = bounds;
}

- (ARAPathBearing)calculateBearingForSegment:(NSUInteger)index withinDistance:(float)distance fromLocation:(ARWorldLocation *)location {
	ARAPathBearing result;
	
	// Given the current segment, the next segment and the previous segment and a circle of size
	ARASegment * segment = [self.segments objectAtIndex:index];
	
	// This is an absolute distance, if the segment is to small, this may lead to unpredictable behaviour. A potential improvement is to use not only a fixed distance (as a maximum) but also a percentage distance (as a minimum).
	result.distanceFromMidpoint = (location.position - segment.to.position).length();
	
	if (result.distanceFromMidpoint < distance) {
		// We are either at the destination, or we are at a corner:
		
		// Are we (not) at the end? – e.g. is there a corner?
		if (index + 1 < self.segments.count) {
			ARASegment * nextSegment = [self.segments objectAtIndex:index+1];
				
			result.incomingBearing = calculateBearingBetween(convertFromDegrees(segment.from.coordinate), convertFromDegrees(location.coordinate));
			result.outgoingBearing = calculateBearingBetween(convertFromDegrees(location.coordinate), convertFromDegrees(nextSegment.to.coordinate));
		} else {
			result.incomingBearing = calculateBearingBetween(convertFromDegrees(segment.from.coordinate), convertFromDegrees(segment.to.coordinate));
			result.outgoingBearing = result.incomingBearing;
		}
	} else {
		// This is the bearing from the position to the current segment exit:
		result.incomingBearing = calculateBearingBetween(convertFromDegrees(location.coordinate), convertFromDegrees(segment.to.coordinate));
		result.outgoingBearing = result.incomingBearing;
	}
		
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

+ (ARAPath *) routeWithPath:(NSString *)path {	
	NSDictionary * route = [NSDictionary dictionaryWithContentsOfFile:path];
	NSMutableArray * points = [NSMutableArray array];
	
	for (NSDictionary * point in [route objectForKey:@"points"]) {
		ARWorldPoint * worldPoint = [[ARWorldPoint alloc] init];
		
		CLLocationCoordinate2D coordinate = {
			[[point objectForKey:@"latitude"] doubleValue],
			[[point objectForKey:@"longitude"] doubleValue]
		};
		
		[worldPoint setCoordinate:coordinate altitude:[[point objectForKey:@"altitude"] doubleValue]];
		[worldPoint setMetadata:[[point objectForKey:@"metadata"] mutableCopy]];
		
		[points addObject:worldPoint];
	}
	
	return [[ARAPath alloc] initWithPoints:points];
}

@end
