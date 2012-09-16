//
//  ARAMiniMapView.m
//  ARBrowser
//
//  Created by Samuel Williams on 14/07/12.
//  Copyright (c) 2012 Orion Transfer Ltd. All rights reserved.
//

#import "ARAMiniMapView.h"

#include "ARRendering.h"

@implementation ARAMiniMapView

@synthesize pathController = _pathController, location = _location;

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
	ARAPath * path = nil;
	
	if (_pathController == nil) return;
	path = _pathController.path;
		
	// Ensure that we have an array of segments for drawing:
	if (path == nil || path.segments.count == 0) return;
	
	ARAPathBounds bounds = ARAPathBoundsWithAspectRatio(path.bounds, self.bounds.size);
	
	UIBezierPath * bezierPath = [UIBezierPath bezierPath];
	[bezierPath setLineWidth:2.0];
	
	ARASegment * firstSegment = [path.segments objectAtIndex:0];
	
	CGRect displayBounds = CGRectInset(self.bounds, 2.0, 2.0);
	
	CGPoint start = ARAPathBoundsScaleCoordinate(bounds, firstSegment.from.coordinate, displayBounds, NO);
	[bezierPath moveToPoint:start];
	
	NSInteger count = 0;
	for (ARASegment * segment in path.segments) {		
		CGPoint point = ARAPathBoundsScaleCoordinate(bounds, segment.to.coordinate, displayBounds, NO);
		[bezierPath addLineToPoint:point];
		
		if (count == _pathController.currentSegmentIndex) {
			[[UIColor colorWithRed:204.0 / 255.0 green:201.0 / 255.0 blue:51.0 / 255.0 alpha:1.0] setStroke];
			
			[bezierPath stroke];
			
			[bezierPath removeAllPoints];
			[bezierPath moveToPoint:point];
		}
		
		count += 1;
	}
		
	[[UIColor blackColor] setStroke];
	[bezierPath stroke];
	
	if (_location) {
		if (self.markerImage) {
			CGSize markerSize = self.markerImage.size;

			CGPoint locationPoint = ARAPathBoundsScaleCoordinate(bounds, _location.coordinate, displayBounds, YES);

			CGContextRef c = UIGraphicsGetCurrentContext();
			CGContextSaveGState(c);

			CGContextTranslateCTM(c, locationPoint.x, locationPoint.y);
			CGContextRotateCTM(c, _location.rotation * ARBrowser::D2R);

			
			[self.markerImage drawAtPoint:(CGPoint){-markerSize.width / 2.0, -markerSize.height / 2.0}];
			
			CGContextRestoreGState(c);
		} else {
			CGPoint locationPoint = ARAPathBoundsScaleCoordinate(bounds, _location.coordinate, displayBounds, YES);
			
			// Render positional marker:
			UIBezierPath * marker = [UIBezierPath bezierPathWithArcCenter:locationPoint radius:2.5 startAngle:0.0 endAngle:360.0 clockwise:YES];
			
			[[UIColor blueColor] setFill];
			[marker fill];

			[marker removeAllPoints];
			
			// Render directional marker:
			[marker setLineWidth:1.5];
			[marker moveToPoint:locationPoint];
			
			CGPoint direction = _location.normalizedDirection;
			[marker addLineToPoint:(CGPoint){locationPoint.x + direction.x * 10.0, locationPoint.y + direction.y * 10.0}];
			
			[[UIColor blueColor] setStroke];
			[marker stroke];
		}
	}
}

@end
