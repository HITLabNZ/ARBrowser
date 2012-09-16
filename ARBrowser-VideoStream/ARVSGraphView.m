//
//  ARVSGraph.m
//  ARBrowser
//
//  Created by Samuel Williams on 9/02/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARVSGraphView.h"

@implementation ARVSGraphView

static NSUInteger indexOfPointInSequence(NSUInteger sequence, NSUInteger point, NSUInteger count) {
	return (sequence * count) + point;
}

@synthesize scale = _scale;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		_scale = 100.0;
		
		_sequences = 0;
		
		[self setSequenceCount:1];
		[self setColor:[UIColor redColor] ofSequence:0];
		
		[self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

-(void)dealloc {
	[self setSequenceCount:0];

	[super dealloc];
}

- (void)setSequenceCount:(NSUInteger)count {
	if (count != _sequences) {
		// Free any colours that were used:
		if (_sequences) {
			NSUInteger i = 0;
			for (; i < _sequences; i += 1)
				[_colors[i] release];
			
			free(_colors);
		}
		
		// This array is invariably foobar:
		if (_points) {
			free(_points);
		}
		
		// Allocate new data structures if required:
		if (count) {
			_colors = calloc(count, sizeof(UIColor*));
			[self setPointCount:_count];
		}
	}
	
	_sequences = count;
}

- (void)setColor:(UIColor *)color ofSequence:(NSUInteger)sequence {
	NSAssert(sequence < _sequences, @"Invalid sequence number specified");
	
	[_colors[sequence] autorelease];
	_colors[sequence] = [color retain];
}

- (void)setPointCount:(NSUInteger)count {
	if (_points) {
		free(_points);
	}
	
	if (count) {
		_points = (CGFloat *)calloc(count * _sequences, sizeof(CGFloat));
	} else {
		_points = NULL;
	}
	
	_count = count;
	_current = 0;
}

- (void)addPoints:(CGFloat*)points {
	if (_count == 0)
		return;
	
	_current = (_current + 1) % _count;
	
	NSUInteger s = 0;
	for (; s < _sequences; s += 1) {
		_points[indexOfPointInSequence(s, _current, _count)] = points[s];
	}
	
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	if (_count == 0)
		return;
	
	CGRect bounds = self.bounds;
	CGPoint origin = {
		bounds.origin.x,
		bounds.origin.y + bounds.size.height / 2.0
	};
	
	CGFloat scale = bounds.size.width / _count;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Clear the background:
	CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.0f);
	CGContextFillRect(context, self.bounds);
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, origin.x, origin.y);
	CGContextAddLineToPoint(context, origin.x + bounds.size.width, origin.y);
	CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
	CGContextStrokePath(context);
	
	NSUInteger s = 0;
	for (; s < _sequences; s += 1) {
		// Draw the graph line:
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, origin.x, origin.y);
		
		NSUInteger i = 0;
		for (; i < _count; i += 1) {
			CGFloat point = _points[indexOfPointInSequence(s, i, _count)];
			CGContextAddLineToPoint(context, origin.x + (scale * i), origin.y + (point * _scale));
		}
		
		CGContextSetLineWidth(context, 1);
		
		if (_colors[s])
			CGContextSetStrokeColorWithColor(context, [_colors[s] CGColor]);
		else
			CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] CGColor]);
		
		CGContextStrokePath(context);
	}
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, bounds.origin.x + (_current * scale), bounds.origin.y);
	CGContextAddLineToPoint(context, bounds.origin.x + (_current * scale), bounds.origin.y + bounds.size.height);
	CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextStrokePath(context);
}

@end
