//
//  ARAPathController.m
//  ARBrowser
//
//  Created by Samuel Williams on 2/04/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARAPathController.h"
#import "ARASegment.h"

@implementation ARAPathController

@synthesize stepModel = _stepModel, markerModel = _markerModel;
@synthesize path = _path;

- init {
	self = [super init];
	
	if (self) {
		NSString * modelPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Models"];
		
		self.stepModel = [ARModel objectModelWithName:@"arrow0" inDirectory:modelPath];
		self.markerModel = [ARModel objectModelWithName:@"marker" inDirectory:modelPath];
	}
	
	return self;
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

@end
