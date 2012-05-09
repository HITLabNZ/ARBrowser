//
//  ARAPathController.m
//  ARBrowser
//
//  Created by Samuel Williams on 2/04/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARAPathController.h"
#import "ARASegment.h"

const float ARA_RECALIBRATION_DISTANCE = 50.0;

@implementation ARAPathController

@synthesize stepModel = _stepModel, markerModel = _markerModel;
@synthesize path = _path, currentSegmentIndex = _currentSegmentIndex;
@synthesize turning = _turning;

- init {
	self = [super init];
	
	if (self) {
		NSString * modelPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Models"];
		
		self.stepModel = [ARModel objectModelWithName:@"arrow0" inDirectory:modelPath];
		self.markerModel = [ARModel objectModelWithName:@"marker" inDirectory:modelPath];
		
		self.currentSegmentIndex = NSNotFound;
		self.turning = NO;
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

- (BOOL)updateSegmentIndexFromLocation:(ARWorldLocation *)location withCornerRadius:(float)distance {
	// As an aside - perhaps taking the device orientation into account could be used here to more accurately select segments which are equally likely.
	
	// If we don't have a fix on any particular segment, find the closest one:
	if (self.currentSegmentIndex == NSNotFound) {
		self.currentSegmentIndex = [self.path calculateNearestSegmentForLocation:location];
		self.turning = NO;
		
		NSLog(@"Initial segment initialized to %d", self.currentSegmentIndex);
		
		return YES;
	}
	
	// Lets consider the current segment, and check if the user has exited yet:
	ARASegment * currentSegment = [self.path.segments objectAtIndex:self.currentSegmentIndex];
	
	float distanceFromCurrentSegment = [currentSegment distanceFrom:location];
	
	// Check if we need to recalibrate (20m is arbitrary):
	if (distanceFromCurrentSegment > ARA_RECALIBRATION_DISTANCE) {
		self.currentSegmentIndex = [self.path calculateNearestSegmentForLocation:location];
		self.turning = NO;
		
		NSLog(@"Recalibrating segment to %d", self.currentSegmentIndex);
		
		return YES;
	}
	
	//ARASegmentDisposition disposition = [currentSegment dispositionRelativeTo:location];
	
	// We may be in the next segment, if it exists:
	if (self.currentSegmentIndex + 1 < self.path.segments.count) {
		float distanceFromCorner = [currentSegment distanceFrom:location];
		
		if (distanceFromCorner < distance) {
			// If we are within the set radius from the corner, we are now turning.
			self.turning = YES;
		} else {
			ARASegment * nextSegment = [self.path.segments objectAtIndex:self.currentSegmentIndex + 1];
			ARASegmentDisposition nextSegmentDisposition = [nextSegment dispositionRelativeTo:location];
			
			if (self.turning && nextSegmentDisposition > ARASegmentAhead) {
				// We have completed the turn, move to next segment:
				self.currentSegmentIndex = self.currentSegmentIndex + 1;
				self.turning = NO;
				
				NSLog(@"Updating segment to %d", self.currentSegmentIndex);
				
				return YES;
			}
		}
	}
	
	return NO;
}

@end
