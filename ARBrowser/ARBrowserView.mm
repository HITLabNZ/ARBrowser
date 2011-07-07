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

@synthesize delegate, distanceScale;

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

- (void) update {
	ARVideoFrame * videoFrame = [videoFrameController videoFrame];
	
	if (videoFrame && videoFrame->data) {
		[videoBackground update:videoFrame];
	}
	
	[videoBackground draw];

	glEnable(GL_DEPTH_TEST);
	glClear(GL_DEPTH_BUFFER_BIT);
	
	CMAcceleration gravity = [[ARLocationController sharedInstance] currentAcceleration];
		
	// Calculate the camera paremeters
	{
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		
		// This moves the camera back slightly and improves the perspective for debugging purposes.
		//glTranslatef(0.0, 0.0, -2.0);
		
		// F defines the negative normal for the plain
		// x -> latitude, y -> longitude, z -> altitude
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
			
			glRotatef(sz * (180.0 / M_PI), s.x, s.y, s.z);
		}
		
		// Move the origin down 1 meter.
		glTranslatef(0.0, 0.0, -1.0);
	}
	
	// Load the camera projection matrix
	glMatrixMode(GL_PROJECTION);
	
	MATRIX perspectiveProjection;
	MatrixPerspectiveFovRH(perspectiveProjection, f2vt(70), f2vt(((float) 320 / (float) 480)), f2vt(0.1f), f2vt(1000.0f), 0);
	glMultMatrixf(perspectiveProjection.f);
	
	glMatrixMode(GL_MODELVIEW);
	ARWorldLocation * origin = [[ARLocationController sharedInstance] worldLocation];
	
	glRotatef([origin rotation], 0, 0, 1);
	
	glGetFloatv(GL_PROJECTION_MATRIX, state->projectionMatrix.f);
	glGetFloatv(GL_MODELVIEW_MATRIX, state->viewMatrix.f);
	
	glColor4f(0.7, 0.7, 0.7, 1.0);
	ARBrowser::renderVertices(state->grid);
	ARBrowser::renderAxis();
	
	NSArray * worldPoints = [[self delegate] worldPoints];
		
	for (ARWorldPoint * point in worldPoints) {
		Vec3 delta = [origin calculateRelativePositionOf:point] * distanceScale;
		
		glPushMatrix();
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
	[videoFrameController release];	
	[videoBackground release];
	
	delete state;

    [super dealloc];
}

@end
