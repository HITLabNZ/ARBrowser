//
//  CompassView.m
//  ARToolKit-oe
//
//  Created by Samuel Williams on 14/02/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import "ARCompassView.h"
#import <QuartzCore/QuartzCore.h>

const double CompassRange = 45.0;
void * HeadingChanged = (void *)"HeadingChanged";
void * LocationChanged = (void *)"LocationChanged";

CLLocationCoordinate2D convertToRadians (CLLocationCoordinate2D loc) {
	loc.latitude = (loc.latitude / 180.0) * M_PI;
	loc.longitude = (loc.longitude / 180.0) * M_PI;
	
	return loc;
}

CLLocationDirection convertToDegrees(CLLocationDirection value)
{
	return (value / M_PI) * 180.0;
}

CLLocationDirection calculateDifference(CLLocationDistance a, CLLocationDirection b)
{
	CLLocationDirection relativeDifference = fmod(fabs(a + 180 - b), 360.0) - 180.0;
	
	return relativeDifference;
}

@implementation ARCompassView

@synthesize locations = _locations, heading = _heading, location = _location;

- (void) _setup {
	[self addObserver:self forKeyPath:@"heading" options:NSKeyValueObservingOptionNew context:HeadingChanged];
	[self addObserver:self forKeyPath:@"location" options:NSKeyValueObservingOptionNew context:HeadingChanged];
	
	_markers = [NSMutableArray new];	
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	
    if (self) {
		[self _setup];
    }
	
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		[self _setup];
	}
	
	return self;
}

- (void)dealloc {
    [_markers release];
	
	[self removeObserver:self forKeyPath:@"heading"];
	[self removeObserver:self forKeyPath:@"location"];
	
	[self setHeading:nil];
	[self setLocation:nil];
	[self setLocations:nil];
	
    [super dealloc];
}

- (CLLocationDirection) bearingOfLocation: (CLLocation *)marker
{
	// We need to calculate the angle between <_location -> north pole>, and <_location -> marker>
	ARLocationCoordinate f = convertFromDegrees([_location coordinate]);
	ARLocationCoordinate t = convertFromDegrees([marker coordinate]);
	
	return calculateBearingBetween(f, t);
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == HeadingChanged || context == LocationChanged) {
		[self setNeedsDisplay];
		
		[_markers removeAllObjects];
		
		ARWorldLocation * origin = [ARWorldLocation fromLocation:_location];
		
		for (ARWorldLocation * object in _locations) {
			CLLocationDistance distance = [object sphericalDistanceFrom:origin];
			
			// Ignore objects further than 10km
			if (distance > (10.0 * 1000.0)) continue;
			
			CLLocationDirection direction = calculateBearingBetween(convertFromDegrees(origin.coordinate), convertFromDegrees(object.coordinate));
						
			[_markers addObject:[NSNumber numberWithDouble:direction]];
		}		
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{	
	UIFont * font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);

	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(context, rect);
	
	CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
	
	// This is for drawing the translated compass ticks
	CGContextSaveGState(context);
	
	CGFloat s = self.bounds.size.width / (CompassRange * 2.0);
	
	CLLocationDirection heading = [_heading trueHeading];
	//heading = fmod(heading - 90, 360.0);
	//CGContextScaleCTM(context, scale, 1.0);
	CGContextTranslateCTM(context, (-heading + CompassRange) * s, 0);

	UIBezierPath * minorTicks = [[UIBezierPath new] autorelease];
	UIBezierPath * majorTicks = [[UIBezierPath new] autorelease];
	
	[minorTicks setLineWidth:2.0];
	[majorTicks setLineWidth:4.0];
	
	CGFloat min = -CompassRange, max = 360.0 + CompassRange, d;
	for (d = min; d <= max; d += 9) {		
		if (fmodf(d, 90.0) == 0.0) {
			[majorTicks moveToPoint:CGPointMake(d*s, 0)];
			[majorTicks addLineToPoint:CGPointMake(d*s, 50)];
		} else {
			[minorTicks moveToPoint:CGPointMake(d*s, 0)];
			[minorTicks addLineToPoint:CGPointMake(d*s, 25.0)];
		}
		
		if (fmodf(d, 45.0) == 0.0) {
			NSString * degrees = nil;
			CGFloat offset = 0;
			
			int f = d;
			if (f < 0) f += 360;
			if (f >= 360) f -= 360;
			
			if ((int)f == 0) {
				degrees = @"N";
			} else if ((int)f == 90) {
				degrees = @"E";
			} else if ((int)f == 180) {
				degrees = @"S";
			} else if ((int)f == 270) {
				degrees = @"W";
			} else {
				degrees = [NSString stringWithFormat:@"%0.0f˚", d];
				// We want the number to be centered under the pin, we need to offset
				// to account for the degree symbol.
				offset = 5;
			}
			
			CGRect textFrame = CGRectMake((d*s) - 20, 55, 40 + offset, 20);
			[degrees drawInRect:textFrame withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
		}
	}
	
	[[UIColor blackColor] setStroke];
	[majorTicks stroke];
	[minorTicks stroke];
	
	UIBezierPath * markers = [[UIBezierPath new] autorelease];
	[markers setLineWidth:6.0];
	
	BOOL drawLeftArrow = NO, drawRightArrow = NO;
	
	for (NSNumber * number in _markers) {
		CLLocationDirection markerHeading = [number doubleValue];
		
		if (markerHeading < CompassRange) {
			CLLocationDirection offsetDirection = markerHeading + 360.0;
			[markers moveToPoint:CGPointMake(offsetDirection * s, 0)];
			[markers addLineToPoint:CGPointMake(offsetDirection * s, 30)];
		}
		
		if (markerHeading > (360.0 - CompassRange)) {
			CLLocationDirection offsetDirection = markerHeading - 360.0;
			[markers moveToPoint:CGPointMake(offsetDirection * s, 0)];
			[markers addLineToPoint:CGPointMake(offsetDirection * s, 30)];
		}
		
		[markers moveToPoint:CGPointMake(markerHeading * s, 0)];
		[markers addLineToPoint:CGPointMake(markerHeading * s, 30)];
		
		CLLocationDirection headingDiff = calculateDifference([_heading trueHeading], markerHeading);
		if (headingDiff < -CompassRange) {
			drawRightArrow = YES;
		} else if (headingDiff > CompassRange) {
			drawLeftArrow = YES;
		}
	}
	
	[[[UIColor blueColor] colorWithAlphaComponent:0.6] setStroke];
	[markers stroke];
	
	CGContextRestoreGState(context);
	
	UIBezierPath * arrows = [[UIBezierPath new] autorelease];
	[arrows setLineWidth:2.0];
	[arrows setLineCapStyle:kCGLineCapRound];
	
	// Top of arrow
	CGFloat t = self.bounds.size.height * (4.0 / 5.0);
	// Bottom of arrow
	CGFloat b = self.bounds.size.height * (1.0 / 5.0);
	// Center of arrow
	CGFloat c = (t+b) / 2.0;
	// Right hand side
	CGFloat r = self.bounds.size.width - 5;
	// Left hand side
	CGFloat l = 5;
	// Width of the arrow
	CGFloat w = 25;
	
	if (drawLeftArrow) {
		[arrows moveToPoint:CGPointMake(l, c)];
		[arrows addLineToPoint:CGPointMake(l + w, t)];
		[arrows addLineToPoint:CGPointMake(l + w, b)];
		[arrows addLineToPoint:CGPointMake(l, c)];
	}
	
	if (drawRightArrow) {
		[arrows moveToPoint:CGPointMake(r, c)];
		[arrows addLineToPoint:CGPointMake(r - w, t)];
		[arrows addLineToPoint:CGPointMake(r - w, b)];
		[arrows addLineToPoint:CGPointMake(r, c)];
	}
	
	[[[UIColor blueColor] colorWithAlphaComponent:0.6] setFill];
	[arrows fill];
	
	[[[UIColor blackColor] colorWithAlphaComponent:0.8] setStroke];
	[arrows stroke];
	
	CGContextRestoreGState(context);
}

@end
