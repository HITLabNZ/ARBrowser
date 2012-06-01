//  ARALocalArrow.m
//  ARBrowser
//
//  Created by Samuel Williams on 16/4/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARALocalArrow.h"
#import <CoreLocation/CoreLocation.h>

#include <vector>
#include "ARRendering.h"

@implementation ARALocalArrow

@synthesize angleScale = _angleScale, radius = _radius, currentBearing = _currentBearing, pathBearing = _pathBearing;

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

static void generateArrow(Vec3 bottom, Vec3 top, Vec3 up, float angle, std::vector<Vec3> & vertices) {
	Mat44 rotation;
	MatrixRotationZ(rotation, angle*PIf/180.0f);
	
	Vec3 delta = (top - bottom);
	Vec3 direction = delta.normalized();
	float length = delta.length();
	float arrowLength = length / 5.0;
	Vec3 side = direction.cross(up);
	
	const float widthScale = 0.12 * 0.6;
	
	Vec3 arrowHeadBase = top + (direction * -arrowLength);
	Vec3 points[] = {
		top,
		arrowHeadBase + (side * -3.0 * widthScale),
		arrowHeadBase + (side * -1.0 * widthScale),
		arrowHeadBase + (side *  1.0 * widthScale),
		arrowHeadBase + (side *  3.0 * widthScale),
		bottom + (delta * 1.0) + side * -1.0 * widthScale,
		bottom + (delta * 1.0) + side *  1.0 * widthScale,
		bottom + (delta * 0.8) + side * -1.0 * widthScale,
		bottom + (delta * 0.8) + side *  1.0 * widthScale,
		bottom + (delta * 0.6) + side * -1.0 * widthScale,
		bottom + (delta * 0.6) + side *  1.0 * widthScale,
		bottom + (delta * 0.4) + side * -1.0 * widthScale,
		bottom + (delta * 0.4) + side *  1.0 * widthScale,
		bottom + (delta * 0.2) + side * -1.0 * widthScale,
		bottom + (delta * 0.2) + side *  1.0 * widthScale,
		bottom + (side * -1.0 * widthScale),
		bottom + (side *  1.0 * widthScale)
	};
	
	for (std::size_t i = 0; i < 17; i += 1) {
		float factor = (points[i] - bottom).length() / (length / 1.2);
		
		if (factor > 1.0) factor = 1.0;
		
		Vec3 rotated;
		MatrixVec3Multiply(rotated, points[i], rotation);
		
		points[i] = points[i] * (1.0 - factor) + rotated * factor;
	}
	
	// Arrow head
	vertices.push_back(points[1]);
	vertices.push_back(points[2]);
	vertices.push_back(points[0]);
	
	vertices.push_back(points[2]);
	vertices.push_back(points[3]);
	vertices.push_back(points[0]);
	
	vertices.push_back(points[3]);
	vertices.push_back(points[4]);
	vertices.push_back(points[0]);
	
	// Arrow body - could be improved.
	for (std::size_t i = 9; i < 17; i += 2) {
		vertices.push_back(points[i]);
		vertices.push_back(points[i - 1]);
		vertices.push_back(points[i - 2]);
		
		vertices.push_back(points[i + 1]);
		vertices.push_back(points[i]);
		vertices.push_back(points[i - 1]);
	}		
}

static void drawDirectionalMarker() {
	std::vector<Vec3> vertices;
	vertices.push_back(Vec3(-0.9, 0.0, 1.0));
	vertices.push_back(Vec3(-0.75, 0.2, 1.0));
	vertices.push_back(Vec3(-0.75, -0.2, 1.0));
	
	glColor4f(27.0/255.0, 198.0/255.0, 224.0/255.0, 1.0);
	ARBrowser::renderVertices(vertices, GL_TRIANGLES);
	
	vertices.clear();
	vertices.push_back(Vec3(-0.9 - 0.02, 0.0, 0.9));
	vertices.push_back(Vec3(-0.75 + 0.02, 0.2 + 0.06, 0.9));
	vertices.push_back(Vec3(-0.75 + 0.02, -0.2 - 0.06, 0.9));
	glColor4f(1.0, 1.0, 1.0, 1.0);
	ARBrowser::renderVertices(vertices, GL_TRIANGLES);	
}

static float differenceBetweenAngles(float a, float b) {
	float d = (a-b) * ARBrowser::D2R;
	return atan2f(sinf(d), cosf(d)) * ARBrowser::R2D;
}

- (void)draw {
	float offsetBearing = _pathBearing.outgoingBearing - _pathBearing.incomingBearing;
	
	glPushMatrix();
	glRotatef(_pathBearing.incomingBearing, 0, 0, -1);
	
	std::vector<Vec3> vertices;
	
	generateArrow(Vec3(0, 0, 0.5), Vec3(0, _radius, 1.0), Vec3(0, 0, 1), offsetBearing, vertices);
	
	glColor4f(27.0/255.0, 198.0/255.0, 224.0/255.0, 1.0);
	
	ARBrowser::renderVertices(vertices, GL_TRIANGLES);
	glPopMatrix();
	
	float difference = differenceBetweenAngles(_pathBearing.outgoingBearing, _currentBearing);
	if (fabs(difference) > 20.0) {
		// Draw the directional marker:
		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
				
		glLoadIdentity();
		if (difference > 0.0)
			glOrthof(1, -1, -1, 1, -1, 1);
		else
			glOrthof(-1, 1, -1, 1, -1, 1);
		
		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		
		glLoadIdentity();
		
		drawDirectionalMarker();
		
		glPopMatrix();
		
		glMatrixMode(GL_PROJECTION);
		glPopMatrix();
		
		// We leave matrix mode as it was originally:
		glMatrixMode(GL_MODELVIEW);
	}
}

@end
