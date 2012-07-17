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

static Vec3 interpolate(float t, Vec3 a, Vec3 b) {
	return ((1.0 - t) * a) + (t * b);
}

static Vec3 point_at_time(const std::vector<Vec3> points, float time) {
	if (time <= 0.0) return points[0];
	if (time >= 1.0) return points[points.size() - 1];
	
	float offset = time * (points.size() - 1);
	std::size_t index = (std::size_t)offset;
	
	return interpolate(offset - index, points.at(index), points.at(index+1));
}

/// Cubic interpolate between four values
template <typename InterpolateT, typename AnyT>
inline AnyT cubic_interpolate (const InterpolateT & t, const AnyT & a, const AnyT & b, const AnyT & c, const AnyT & d)
{
	AnyT p = (d - c) - (a - b);
	AnyT q = (a - b) - p;
	AnyT r = c - a;
	AnyT s = b;
	
	return p*(t*t*t) + q*(t*t) + r * t + s;
}

/** Hermite interpolation polynomial function.
 
 Tension: 1 is high, 0 normal, -1 is low
 Bias: 0 is even,
 positive is towards first segment,
 negative towards the other
 */
template <typename InterpolateT, typename AnyT>
inline AnyT hermite_polynomial (const InterpolateT & t, const AnyT & p0, const AnyT & m0, const AnyT & p1, const AnyT & m1)
{
	InterpolateT t3 = t*t*t, t2 = t*t;
	
	InterpolateT h00 = 2*t3 - 3*t2 + 1;
	InterpolateT h10 = t3 - 2*t2 + t;
	InterpolateT h01 = -2*t3 + 3*t2;
	InterpolateT h11 = t3 - t2;
	
	return p0 * h00 + m0 * h10 + p1 * h01 + m1 * h11;
}

static void drawArrow(Vec3 bottom, Vec3 top, Vec3 up, float angle, float border = 0.0) {
	std::vector<Vec3> arrow;
	
	const float width = 0.1;
	
	Vec3 delta = (top - bottom);
	// Move the whole line segment forward proportionally:
	// bottom += (delta * 0.1);
	// top += (delta * 0.1);
	
	Vec3 offset = delta / 2.0;
	Vec3 middle = bottom + offset;
	Vec3 offsetRotated;
	
	// Rotation Matrix
	Mat44 rotation;
	MatrixRotationZ(rotation, angle * ARBrowser::D2R);
	MatrixVec3Multiply(offsetRotated, offset, rotation);
		
	// Now we have three points for the arrow:
	arrow.push_back(bottom);
	arrow.push_back(middle);
	arrow.push_back(middle + offsetRotated);
	
	std::vector<Vec3> vertices;
	vertices.push_back(bottom);
	
	Vec3 a = point_at_time(arrow, 0.0);
	Vec3 b = point_at_time(arrow, 0.333);
	Vec3 c = point_at_time(arrow, 0.666);
	Vec3 d = point_at_time(arrow, 1.0);
	
	//vertices.push_back(arrow[0]);
	Vec3 p1 = arrow[0], direction, side;
	
	// ...we need to construct a nice curved shape, along with the arrow head:
	for (float time = 0; time <= 1.0; time += 0.2) {
		//Vec3 p = cubic_interpolate(time, a, b, c, d);
		Vec3 p2 = hermite_polynomial(time, b, b-a, c, d-c);
		
		Vec3 delta = (p2 - p1).normalize();
		
		// Calculate the sideways vector
		direction = delta.cross(up);
		side = direction * (width + border);
		
		vertices.push_back(p1 + side);
		vertices.push_back(p1 - side);
		
		p1 = p2;
	}
	
	// Last segment
	vertices.push_back(arrow[2] + side);
	vertices.push_back(arrow[2] - side);
	
	ARBrowser::renderVertices(vertices, GL_TRIANGLE_STRIP);
	
	vertices.clear();
	
	// ...now draw arrow head:
	Vec3 forward = (arrow[2] - arrow[1]).normalize();
	vertices.push_back(arrow[2] + forward * (0.5 + border * 2.0));
	vertices.push_back(arrow[2] + (direction * (width * 3.5 + border * 1.5)) - (forward * (0.2 + border)));
	vertices.push_back(arrow[2] - (forward * (0.1 + border)));
	vertices.push_back(arrow[2] - (direction * (width * 3.5 + border * 1.5)) - (forward * (0.2 + border)));
	
	ARBrowser::renderVertices(vertices, GL_TRIANGLE_FAN);
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

- (void)drawDirectionalMarker {
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

- (void)draw3D {
	float offsetBearing = _pathBearing.outgoingBearing - _pathBearing.incomingBearing;
	
	glPushMatrix();
	glRotatef(_pathBearing.incomingBearing, 0, 0, -1);
	
	glColor4f(27.0/255.0, 198.0/255.0, 224.0/255.0, 1.0);
	drawArrow(Vec3(0, 0, 0.5), Vec3(0, _radius, 0.5), Vec3(0, 0, 1), offsetBearing);
	
	glPopMatrix();
	
	[self drawDirectionalMarker];
}

- (void)draw2DInBrowserView:(ARBrowserView*)browserView {
	float offsetBearing = _pathBearing.outgoingBearing - _pathBearing.incomingBearing;
	
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	
	CGSize viewSize = [browserView bounds].size;
	
	MATRIX orthoProjection;
	MatrixOrthoRH(orthoProjection, viewSize.width / 100.0, viewSize.height / 100.0, -1, 1, false);
	glMultMatrixf(orthoProjection.f);
	
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	
	// Move whole arrow visualisation down:
	glTranslatef(0.0, -1, 0.0);
	glRotatef(45.0, 1.0, 0.0, 0.0);
	
	float currentBearing = -[browserView.locationController currentBearing];
	glRotatef(_pathBearing.incomingBearing + currentBearing, 0, 0, -1);
	glTranslatef(0.0, -_radius / 2.0, 0.0);
	
	glDisable(GL_DEPTH_TEST);
	
	glColor4f(0.0, 0.0, 0.0, 1.0);
	drawArrow(Vec3(0, 0, 0.4), Vec3(0, _radius, 0.4), Vec3(0, 0, 1), offsetBearing, 0.1);
	
	glColor4f(1.0, 1.0, 1.0, 1.0);
	drawArrow(Vec3(0, 0, 0.4), Vec3(0, _radius, 0.4), Vec3(0, 0, 1), offsetBearing);
	
	glEnable(GL_DEPTH_TEST);
	
	glPopMatrix();
	
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	
	glMatrixMode(GL_MODELVIEW);
}

- (void)drawForBrowserView:(ARBrowserView*)browserView {
	[self draw2DInBrowserView:browserView];
}

@end
