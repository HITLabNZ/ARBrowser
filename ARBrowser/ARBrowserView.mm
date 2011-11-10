//
//  ARBrowserView.m
//  ARBrowser
//
//  Created by Samuel Williams on 9/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import "ARBrowserView.h"
#import "ARLocationController.h"

#import "Model.h"
#import "ARWorldPoint.h"
#import "ARModel.h"

/// @internal
struct ARBrowserViewState {
	Mat44 projectionMatrix, viewMatrix;
	
	ARBrowser::VerticesT grid;
	
	ARBrowser::IntersectionResult intersectionResult;
};

static Vec2 positionInView (UIView * view, UITouch * touch)
{
	CGPoint locationInView = [touch locationInView:view];
	CGRect bounds = [view bounds];
	
	return Vec2(locationInView.x, bounds.size.height - locationInView.y);
}

@implementation ARBrowserView

@synthesize delegate, distanceScale, minimumDistance, scaleDistance, maximumDistance, displayRadar, displayGrid;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame pixelFormat:GL_RGB565_OES depthFormat:GL_DEPTH_COMPONENT16_OES preserveBackbuffer:YES];
	
	if (self) {
		videoFrameController = [[ARVideoFrameController alloc] init];
		videoBackground = [[ARVideoBackground alloc] init];
		[videoFrameController start];
		
		// Initialise the location controller
		[ARLocationController sharedInstance];
		
		state = new ARBrowserViewState;
		ARBrowser::generateGrid(state->grid);
		
		distanceScale = 1.0;
		minimumDistance = 2.0;
		scaleDistance = 10.0;
		maximumDistance = 500.0;
		displayRadar = YES;
	}
	
	return self;
}

- (void)touchesBegan: (NSSet *)touches withEvent: (UIEvent *)event
{
	for (UITouch * touch in touches) {
		Vec2 now = positionInView(self, touch);
		ARBrowser::IntersectionResult result;
		
		ARWorldLocation * origin = [[ARLocationController sharedInstance] worldLocation];
		NSArray * worldPoints = [[self delegate] worldPoints];
		std::vector<ARBrowser::BoundingSphere> spheres;
		
		for (ARWorldPoint * worldPoint in worldPoints) {
			ARBoundingSphere boundingSphere = [[worldPoint model] boundingSphere];
			ARBrowser::BoundingSphere sphere(boundingSphere.center, boundingSphere.radius);
			
			// We don't support this yet, but it was supported in the old API.
			// sphere.transform([worldPoint transformation]);
			
			// We need to calculate collision detection in the same coordinate system as drawn on screen.
			Vec3 offset = [origin calculateRelativePositionOf:worldPoint] * distanceScale;
			
			// Calculate actual (non-scaled) distance.
			float distance = offset.length() * (1.0/distanceScale);
			
			if (distance < minimumDistance || distance > maximumDistance) {
				continue;
			}
			
			// Scale the object down if it is closer than the minimum distance.
			if (distance <= scaleDistance) {
				float scale = distance/scaleDistance;
				sphere.radius *= scale;
			}
			
			sphere.center += offset;
			
			spheres.push_back(sphere);
		}
		
		Vec3 worldOrigin(0, 0, 0);
		
		// viewport: (X, Y, Width, Height)
		CGRect bounds = [self bounds];
		float viewport[4] = {bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height};
		
		if (ARBrowser::findIntersection(state->projectionMatrix, state->viewMatrix, viewport, worldOrigin, now, spheres, result)) {
			ARWorldPoint * selected = [worldPoints objectAtIndex:result.index];
			[self.delegate browserView:self didSelect:selected];
		}
	}
}

- (void) drawRadar {
	ARLocationController * locationController = [ARLocationController sharedInstance];
	ARWorldLocation * origin = [locationController worldLocation];
	CMAcceleration gravity = [locationController currentGravity];
	//NSLog(@"Bearing: %0.3f", origin.rotation);
	
	NSArray * worldPoints = [self.delegate worldPoints];
	
	ARBrowser::VerticesT radarPoints, radarEdgePoints;
	
	for (ARWorldPoint * point in worldPoints) {
		Vec3 delta = [origin calculateRelativePositionOf:point];
		
		if (delta.length() == 0) {
			radarPoints.push_back(delta);
		} else {
			// Normalize the distance of the point
			//const float LF = 10.0;
			//float length = log10f((delta.length() / LF) + 1) * LF;
			float length = sqrt(delta.length() / maximumDistance);
			
			// Normalize the vector so we can scale its length appropriately.
			delta.normalize();
			
			if (length <= 1.0) {
				delta *= (length * (ARBrowser::RadarDiameter / 2.0));
				radarPoints.push_back(delta);
			} else {
				delta *= (ARBrowser::RadarDiameter / 2.0);
				radarEdgePoints.push_back(delta);
			}
		}
	}
	
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	
	CGSize radarSize = CGSizeMake(40, 40);
	CGSize viewSize = [self bounds].size;
	
	MATRIX orthoProjection;
	MatrixOrthoRH(orthoProjection, viewSize.width, viewSize.height, -1, 1, false);
	glMultMatrixf(orthoProjection.f);
	
	//float minDimension = std::min(viewSize.width, viewSize.height);
	//float scale = minDimension / ARBrowser::RadarDiameter;
	float minDimension = viewSize.width / 3.0;
	float scale = minDimension / ARBrowser::RadarDiameter;
	
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	
	// This isn't quite right due to scaling, but it is sufficient at this time.
	glTranslatef(-minDimension, (viewSize.height / 2.0) - (radarSize.height / 2.0 * scale), 0);
	
	// Make it slightly smaller so the edges aren't touching the bounding box.
	scale *= 0.9;
	glScalef(scale, scale, 1);
	
	// Draw a line that always points north no matter device orientation.
	/*
	 if (_debug) {
	 //MATRIX m;
	 //[locationController calculateGlobalOrientation:m.f];
	 
	 ARBrowser::VerticesT northLine;
	 northLine.push_back(Vec3(0, 0, 0));
	 
	 //Vec3 northPoint;
	 //MatrixVec3Multiply(northPoint, Vec3(0, 40, 0), m);
	 NSLog(@"Magnetic Field Vector: %0.3f, %0.3f, %0.3f", locationController.currentHeading.x, locationController.currentHeading.y, locationController.currentHeading.z);
	 Vec3 magnetometer(locationController.currentHeading.x, locationController.currentHeading.y, locationController.currentHeading.z);
	 //magnetometer.z = 0;
	 magnetometer.normalize();
	 
	 northLine.push_back(magnetometer * 40);
	 
	 glColor4f(1.0, 0.0, 0.0, 1.0);
	 ARBrowser::renderVertices(northLine);
	 }
	 */
	
	// Calculate the forward angle:
	float forwardAngle = 0.0;
	BOOL flat = NO;
	
	Vec3 rotationAxis;
	{
		Vec3 up(0, 0, +1);
		Vec3 g(-gravity.x, -gravity.y, -gravity.z);
		g.normalize();
		
		float sz = acos(up.dot(g));
		
		// We only do this if there is sufficient rotation of the device around the vertical axis.
		if (sz > 0.1) {
			// Simplified version of the line/plane intersection test, since the plane and line are from the origin.
			Vec3 at = g + (up * -(up.dot(g)));
			at.normalize();
			
			ARBrowser::VerticesT rotation;
			rotation.push_back(Vec3(0, 0, 0));
			rotation.push_back(Vec3(at.x * 40, at.y * 40, 0));
			ARBrowser::renderVertices(rotation);
			
			Vec3 north(0, 1, 0);
			
			rotationAxis = at.cross(north);
			forwardAngle = acos(at.dot(north));
		} else {
			flat = YES;
		}
	}
	
	if (!flat) {
		glRotatef(-forwardAngle * ARBrowser::R2D, rotationAxis.x, rotationAxis.y, rotationAxis.z);		
	} else {
		// We do this to avoid strange behaviour around the vertical axis:
		glRotatef([origin rotation], 0, 0, 1);
	}
	
	ARBrowser::renderRadar(radarPoints, radarEdgePoints, scale / 2.0);
	
	//if (_debug) {
	//	NSLog(@"Rotation: %0.3f", [origin rotation]);
	//}
	
	if (forwardAngle != 0.0) {
		/*
		 // Calculate the rotation around gravity and project that back onto the plane:
		 Vec3 _f(gravity.x, gravity.y, gravity.z);
		 _f.normalize();
		 
		 Vec3 f(_f.x, _f.y, _f.z);
		 Vec3 down(0, 0, -1);
		 float sz = acos(down.dot(f));
		 //
		 Vec3 s = down.cross(f);
		 
		 MATRIX gravityRotation, headingRotation, orientationTransform;
		 MatrixRotationAxis(gravityRotation, sz, s.x, s.y, s.z);
		 
		 MatrixRotationAxis(headingRotation, [origin rotation] * ARBrowser::D2R, 0, 0, 1);
		 MatrixMultiply(orientationTransform, headingRotation, gravityRotation);
		 */

	if (!flat) {		
		Mat44 inverseViewMatrix;
		MatrixInverse(inverseViewMatrix, state->viewMatrix);
		
		// This matrix now contains the transform where +Y maps to North
		// The North axis of the phone is mapped to global North axis.
		Vec3 north(0, 1, 0); //, deviceNorth;
		//MatrixVec3Multiply(deviceNorth, north, state->viewMatrix);
		//NSLog(@"  Device north: %0.3f, %0.3f, %0.3f", deviceNorth.x, deviceNorth.y, deviceNorth.z);
		
		Vec3 forward(0, 0, -1), deviceForward;
		// We calculate the forward vector in global space where (0, 1, 0) is north, (0, 0, -1) is down, (1, 0, 0) is approximately east.
		MatrixVec3Multiply(deviceForward, forward, inverseViewMatrix);
		//NSLog(@"Device forward: %0.3f, %0.3f, %0.3f", deviceForward.x, deviceForward.y, deviceForward.z);
		
		deviceForward.z = 0;
		deviceForward.normalize();
		
		float bearing = acos(deviceForward.dot(north));
		Vec3 r = deviceForward.cross(north).normalize();
		
		//NSLog(@"Bearing: %0.3f", bearing);
		glRotatef(-bearing * ARBrowser::R2D, r.x, r.y, r.z);
		ARBrowser::renderRadarFieldOfView();
	}
	
	glPopMatrix();
	
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
}

- (void) update {
	if (videoFrameController) {
		ARVideoFrame * videoFrame = [videoFrameController videoFrame];
		
		if (videoFrame && videoFrame->data) {
			[videoBackground update:videoFrame];
		}
		
		[videoBackground draw];
	} else {
		glClear(GL_COLOR_BUFFER_BIT);
	}
	
	glEnable(GL_DEPTH_TEST);
	glClear(GL_DEPTH_BUFFER_BIT);
	
	ARLocationController * locationController = [ARLocationController sharedInstance];
	CMAcceleration gravity = [locationController currentGravity];
	
	// Calculate the camera paremeters
	{
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		
		// This moves the camera back slightly and improves the perspective for debugging purposes.
		//glTranslatef(0.0, 0.0, -2.0);
		
		// F defines the negative normal for the plain
		// x -> latitude (horizontal, red marker points east)
		// y -> longitude (vertical, green marker points north)
		// z -> altitude (altitude, blue marker points up)
		Vec3 _f(gravity.x, gravity.y, gravity.z);
		_f.normalize();
		
		Vec3 f(_f.x, _f.y, _f.z);
		Vec3 down(0, 0, -1);
		
		//NSLog(@"f: %0.4f, %0.4f, %0.4f, Length: %0.4f", _f.x, _f.y, _f.z, _f.length());
		
		float sz = acos(down.dot(f));
		
		//NSLog(@"Angle: %0.5f", sz);
		
		if (sz > 0.01) {
			Vec3 s = down.cross(f);
			
			//NSLog(@"d x f: %0.4f, %0.4f, %0.4f, Lenght: %0.4f", s.x, s.y, s.z, s.length());
			
			glRotatef(sz * ARBrowser::R2D, s.x, s.y, s.z);
		}
		
		// Move the origin down 1 meter.
		glTranslatef(0.0, 0.0, -1.0);
	}
	
	// Load the camera projection matrix
	glMatrixMode(GL_PROJECTION);
	
	CGSize viewSize = [self bounds].size;
	
	MATRIX perspectiveProjection;
	MatrixPerspectiveFovRH(perspectiveProjection, f2vt(70), f2vt(viewSize.width / viewSize.height), f2vt(0.1f), f2vt(1000.0f), 0);
	glMultMatrixf(perspectiveProjection.f);
	
	glMatrixMode(GL_MODELVIEW);
	ARWorldLocation * origin = [locationController worldLocation];
	
	glRotatef([origin rotation], 0, 0, 1);
	
	glGetFloatv(GL_PROJECTION_MATRIX, state->projectionMatrix.f);
	glGetFloatv(GL_MODELVIEW_MATRIX, state->viewMatrix.f);
	
	glColor4f(0.7, 0.7, 0.7, 0.2);
	glLineWidth(1.0);
	
	if (displayGrid) {
		ARBrowser::renderVertices(state->grid);
		ARBrowser::renderAxis();
	}
	
	NSArray * worldPoints = [[self delegate] worldPoints];
	
	for (ARWorldPoint * point in worldPoints) {
		Vec3 delta = [origin calculateRelativePositionOf:point] * distanceScale;
		//NSLog(@"Delta: %0.3f, %0.3f, %0.3f", delta.x, delta.y, delta.z);
		
		// Calculate actual (non-scaled) distance.
		float distance = delta.length() * (1.0/distanceScale);
		
		if (distance < minimumDistance || distance > maximumDistance) {
			continue;
		}
		
		glPushMatrix();
		
		// Scale the object down if it is closer than the minimum distance.
		if (distance <= scaleDistance) {
			glScalef(distance/scaleDistance, distance/scaleDistance, distance/scaleDistance);
		}
		
		glTranslatef(delta.x, delta.y, delta.z);
		
		[[point model] draw];
		
		// Render the bounding sphere for debugging.
		//ARBrowser::VerticesT points;
		//ARBoundingSphere sphere = [[point model] boundingSphere];
		//ARBrowser::generateGlobe(points, sphere.radius);
		
		//glTranslatef(sphere.center.x, sphere.center.y, sphere.center.z);
		//ARBrowser::renderVertices(points);
		
		glPopMatrix();
	}
	
	if (displayRadar)
		[self drawRadar];
	
	[super update];
}

- (void) stopRendering
{
	[videoFrameController stop];
	
	[super stopRendering];
}

- (void) startRendering
{
	[videoFrameController start];
	
	[super startRendering];
}

- (void)dealloc
{
	[videoFrameController stop];
	
	[videoFrameController release];	
	[videoBackground release];
	
	delete state;
	
	[super dealloc];
}

@end
