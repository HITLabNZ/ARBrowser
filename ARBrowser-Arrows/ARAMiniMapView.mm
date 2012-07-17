//
//  ARAMiniMapView.m
//  ARBrowser
//
//  Created by Samuel Williams on 14/07/12.
//  Copyright (c) 2012 Orion Transfer Ltd. All rights reserved.
//

#import "ARAMiniMapView.h"

@implementation ARAMiniMapView

@synthesize pathController = _pathController, location = _location;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.opaque = NO;
    }
    return self;
}

- (void)setLocation:(ARWorldLocation *)location {
	if (location != _location) {
		[self willChangeValueForKey:@"location"];
		
		[_location autorelease];
		_location = [location retain];
		
		[self setNeedsDisplay];
		
		[self didChangeValueForKey:@"location"];
	}
}

- (void)drawRect:(CGRect)rect
{
	UIBezierPath * bezierPath = [UIBezierPath bezierPath];
	
	ARAPath * path = nil;
	
	if (_pathController == nil) return;
	path = _pathController.path;
		
	// Ensure that we have an array of segments for drawing:
	if (path == nil || path.segments.count == 0) return;
	
	ARAPathBounds bounds = ARAPathBoundsWithAspectRatio(path.bounds, self.bounds.size);
	
	ARASegment * firstSegment = [path.segments objectAtIndex:0];
	
	CGRect displayBounds = CGRectInset(self.bounds, 2.0, 2.0);
	
	CGPoint start = ARAPathBoundsScaleCoordinate(bounds, firstSegment.from.coordinate, displayBounds, NO);
	[bezierPath moveToPoint:start];
	
	for (ARASegment * segment in path.segments) {
		CGPoint point = ARAPathBoundsScaleCoordinate(bounds, segment.from.coordinate, displayBounds, NO);
		
		[bezierPath addLineToPoint:point];
	}
	
	ARASegment * lastSegment = path.segments.lastObject;
	CGPoint end = ARAPathBoundsScaleCoordinate(bounds, lastSegment.to.coordinate, displayBounds, NO);
	[bezierPath addLineToPoint:end];
	
	[[UIColor blackColor] setStroke];
	[bezierPath stroke];
	
	if (_location) {
		CGPoint locationPoint = ARAPathBoundsScaleCoordinate(bounds, _location.coordinate, displayBounds, YES);
		
		UIBezierPath * marker = [UIBezierPath bezierPathWithArcCenter:locationPoint radius:2.0 startAngle:0.0 endAngle:360.0 clockwise:YES];
		
		[[UIColor blueColor] setFill];
		[marker fill];
	}
}

@end
