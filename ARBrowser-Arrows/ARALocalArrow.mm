//  ARALocalArrow.m
//  ARBrowser
//
//  Created by Samuel Williams on 16/4/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARALocalArrow.h"
#import <CoreLocation/CoreLocation.h>

#include <vector>
#include "Model.h"

@implementation ARALocalArrow

@synthesize angleScale = _angleScale, radius = _radius, currentBearing = _currentBearing, destinationBearing = _destinationBearing;

static float scale_factor(CLLocationDegrees a, CLLocationDegrees b) {
	CLLocationDegrees offset = b - a;
	
	if (offset < -90) {
		return 1.0 - ((offset + 90) / -90);
	} else if (offset > 90) {
		return 1.0 - ((offset - 90) / 90);
	} else {
		return 1.0;
	}
}

static Vec3 point_on_circle(CLLocationDegrees degrees, Vec3 origin, float radius) {
	float x = sinf(degrees * ARBrowser::D2R), y = cosf(degrees * ARBrowser::D2R);
	
	return origin + Vec3(x * radius, y * radius, 0.0);
}

- (void)draw {
	std::vector<Vec3> vertices;
	
	Vec3 origin(_radius * _angleScale, 0.0, 0.0);
	Vec3 offset(_radius, 0.0, 0.0);
	
	float scale = scale_factor(_currentBearing, _destinationBearing);
	
	Vec3 point = point_on_circle((_destinationBearing - _currentBearing) * scale, origin, _radius);
	
	vertices.push_back(Vec3(0, 0, 0));
	vertices.push_back(origin);
	vertices.push_back(point);
	
	ARBrowser::renderVertices(vertices);
}

@end
