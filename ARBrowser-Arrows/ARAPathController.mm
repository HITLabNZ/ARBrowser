//
//  ARAPathController.m
//  ARBrowser
//
//  Created by Samuel Williams on 2/04/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARAPathController.h"
#import "ARASegment.h"
#import "ARRendering.h"

const float ARA_RECALIBRATION_DISTANCE = 60.0;

@interface ARAPathController ()
@property(nonatomic,readwrite,retain) ARWorldLocation * currentLocation;
@property(nonatomic,readwrite,assign) NSUInteger currentSegmentIndex;
@property(nonatomic,readwrite,assign) BOOL turning;
@end

struct ARASegmentRatio {
	CLLocationDistance current, next, total;
	CLLocationDistance midpoint;
};

ARASegmentRatio calculateRatios(ARWorldLocation * from, ARWorldLocation * step, ARWorldLocation * to) {
	ARASegmentRatio ratio;
	
	ratio.current = [step distanceFrom:from];
	ratio.next = [to distanceFrom:step];
	ratio.total = ratio.current + ratio.next;
	
	ratio.midpoint = ratio.current / ratio.total;
	
	return ratio;
}

@implementation ARAPathController

@synthesize stepModel = _stepModel, markerModel = _markerModel;
@synthesize path = _path, currentSegmentIndex = _currentSegmentIndex, currentLocation = _currentLocation;
@synthesize turningRadius = _turningRadius, turning = _turning, turningRatio = _turningRatio;

- init {
	self = [super init];
	
	if (self) {
		NSString * modelPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Models"];
		
		self.stepModel = [ARModel objectModelWithName:@"arrow0" inDirectory:modelPath];
		self.markerModel = [ARModel objectModelWithName:@"marker" inDirectory:modelPath];
		
		self.currentSegmentIndex = NSNotFound;
		self.turning = NO;
		
		// The distance from the corner before bending arrow is shown:
		self.turningRadius = 40.0;
	}
	
	return self;
}

- (ARASegment *)currentSegment {
	if (self.currentSegmentIndex != NSNotFound) {
		return [self.path.segments objectAtIndex:self.currentSegmentIndex];
	} else {
		return nil;
	}
}

- (NSArray *)visiblePoints {
	NSMutableArray * allSteps = [[self.path.points mutableCopy] autorelease];
	
	for (ARASegment * segment in self.path.segments) {
		[allSteps addObjectsFromArray:segment.steps];
	}
	
	return allSteps;
}

- (NSArray*)visiblePointsFromLocation:(ARWorldLocation *)origin withinDistance:(float)distance {	
	NSMutableArray * points = [[NSMutableArray new] autorelease];
	
	//NSLog(@"visiblePoints:\n%@\n\n%@", self.path.points, self.path.segments);
	
	for (NSUInteger i = 0; i < self.path.segments.count; i += 1) {
		// The point is the actual marker which separates the segments:
		ARWorldPoint * point = [self.path.points objectAtIndex:i+1];
		
		// The segment contains all intermediate points:
		ARASegment * segment = [self.path.segments objectAtIndex:i];
		
		// Get the distance from the origin to this segment:
		float offsetDistance = [segment distanceFrom:origin];
		
		if (offsetDistance < distance) {
			// For the first segment (i == 0), we should add the first marker too. For other segments, just the last marker is added.
			if (i == 0) {
				[points addObject:[self.path.points objectAtIndex:0]];
			}
			
			[points addObject:point];
			[points addObjectsFromArray:segment.steps];
		}
	}
	
	return points;
}

- (void)setPath:(ARAPath *)path {
	[self willChangeValueForKey:@"path"];
	
	[_path autorelease];
	_path = [path retain];
	
	for (ARWorldPoint * point in self.path.points) {
		point.model = self.markerModel;
	}
	
	for (ARASegment * segment in self.path.segments) {
		for (ARWorldPoint * location in segment.steps) {
			location.model = self.stepModel;
		}
	}
	
	[self didChangeValueForKey:@"path"];
}

- (BOOL)updateLocation:(ARWorldLocation *)location {
	// Do a quick check to avoid useless calculations:
	if (location == self.currentLocation) return NO;
	
	// As an aside - perhaps taking the device orientation into account could be used here to more accurately select segments which are equally likely.
	self.currentLocation = location;
	
	// If we don't have a fix on any particular segment, find the closest one:
	if (self.currentSegmentIndex == NSNotFound) {
		self.currentSegmentIndex = [self.path calculateNearestSegmentForLocation:location];
		self.turning = NO;
		
		if (self.currentSegmentIndex == NSNotFound) return NO;
		
		NSLog(@"Initial segment initialized to %d", self.currentSegmentIndex);
		
		return YES;
	}
	
	// Lets consider the current segment, and check if the user has exited yet:
	ARASegment * currentSegment = [self.path.segments objectAtIndex:self.currentSegmentIndex];
		
	float distanceFromCurrentSegment = [currentSegment distanceFrom:location];
	
	// Check if we need to recalibrate:
	if (distanceFromCurrentSegment > ARA_RECALIBRATION_DISTANCE) {
		self.currentSegmentIndex = [self.path calculateNearestSegmentForLocation:location];
		
		self.turning = NO;
		
		NSLog(@"Recalibrating segment to %d", self.currentSegmentIndex);
		
		// We might want to avoid returning YES, if the segment index didn't change.
		return YES;
	}
	
	//ARASegmentDisposition disposition = [currentSegment dispositionRelativeTo:location];
	
	// We may be in the next segment, if it exists:
	if (self.currentSegmentIndex + 1 < self.path.segments.count) {
		ARASegment * nextSegment = [self.path.segments objectAtIndex:self.currentSegmentIndex + 1];
		float distanceFromCorner = [location distanceFrom:currentSegment.to];
		
		//ARASegmentRatio segmentRatio = calculateRatios(currentSegment.from, currentSegment.to, nextSegment.to);
		//ARASegmentRatio locationRatio = calculateRatios(currentSegment.from, self.currentLocation, nextSegment.to);
		
		//ARASegmentDisposition currentDisposition = [currentSegment snapLocation:self.currentLocation];
		
		if (distanceFromCorner < _turningRadius) {
			// If we are within the set radius from the corner, we are now turning.
			self.turning = YES;
			
			_turningRatio = distanceFromCorner / _turningRadius;
			
			float distanceToNextSegment = [nextSegment distanceFrom:location];
			
			if (distanceToNextSegment > distanceFromCurrentSegment) {
				// We are closer to the current segment
				_turningRatio = -_turningRatio;
			}
		} else {
			ARASegmentDisposition nextSegmentDisposition = [nextSegment dispositionRelativeTo:location];
			
			if (self.turning && nextSegmentDisposition > ARASegmentAhead) {
				// We have completed the turn, move to next segment:
				self.currentSegmentIndex = self.currentSegmentIndex + 1;
				self.turning = NO;
				self.turningRatio = 1.0;
				
				NSLog(@"Updating segment to %d", self.currentSegmentIndex);
				
				return YES;
			}
		}
	}
	
	return NO;
}

static double interpolateBearing(double a, double b, double blend) {
	a *= ARBrowser::D2R;
	b *= ARBrowser::D2R;
	
    double ix = sin(a), iy = cos(a);
    double jx = sin(b), jy = cos(b);
    
    return atan2(ix-(ix-jx)*blend, iy-(iy-jy)*blend) * ARBrowser::R2D;
}

- (ARAPathBearing) currentBearing {
	ARAPathBearing bearing = [self.path calculateBearingForSegment:self.currentSegmentIndex withinDistance:_turningRadius fromLocation:self.currentLocation];
	
	if (self.turning) {
		// From -1 to 0, we adjust bearing.out
		
		if (self.turningRatio < 0.0)
			bearing.outgoingBearing = interpolateBearing(bearing.incomingBearing, bearing.outgoingBearing, self.turningRatio + 1.0);
		else
			bearing.incomingBearing = interpolateBearing(bearing.incomingBearing, bearing.outgoingBearing, self.turningRatio);
		
		// You can control the behaviour of the bearing calculation, e.g. whether the arrow responds to user bearing or not.
		
		// As we ease in and ease out of the turn we should adjust the incoming bearing based on the users current rotation:
		float r = 1.0 - (_turningRatio*_turningRatio);
				
		bearing.incomingBearing = interpolateBearing(bearing.incomingBearing, _currentLocation.rotation, r);
	}
	
	return bearing;
}

@end
