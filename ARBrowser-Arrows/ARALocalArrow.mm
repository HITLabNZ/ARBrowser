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
	glPushMatrix();
	glRotatef(-_currentBearing, 0, 0, 1);
	
	std::vector<Vec3> vertices;
	
	vertices.push_back(Vec3(0, -_radius, 0));
	vertices.push_back(Vec3(0, 0, 0));
	vertices.push_back(Vec3(0, _radius, 0));
	
	glColor4f(0.8, 0.75, 0.4, 1.0);
	
	ARBrowser::renderVertices(vertices, GL_LINE_STRIP);
	
	glPopMatrix();
}

@end
