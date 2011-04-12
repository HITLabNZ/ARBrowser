//
//  ARBrowserView.m
//  ARBrowser
//
//  Created by Samuel Williams on 9/04/11.
//  Copyright 2011 Orion Transfer Ltd. All rights reserved.
//

#import "ARBrowserView.h"
#import "ARLocationController.h"

#import "Model.h"
#import "ARWorldPoint.h"
#import "ARModel.h"

struct ARBrowserInternalState {
	ARBrowser::VerticesT grid;
	Mat44 proj, view;
};

@implementation ARBrowserView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame pixelFormat:GL_RGB565_OES depthFormat:GL_DEPTH_COMPONENT16_OES preserveBackbuffer:YES];
	
    if (self) {
        videoFrameController = [[ARVideoFrameController alloc] init];
		videoBackground = [[ARVideoBackground alloc] init];
		
		[videoFrameController start];
		
		// Initialise the location controller
		[ARLocationController sharedInstance];
		
		state = new ARBrowserInternalState;
		ARBrowser::generateGrid(state->grid);
    }
	
    return self;
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
	
	ARBrowser::renderVertices(state->grid);
	ARBrowser::renderAxis();
	
	glGetFloatv(GL_PROJECTION_MATRIX, state->proj.f);
	glGetFloatv(GL_MODELVIEW_MATRIX, state->view.f);
	
	if ([_delegate respondsToSelector:@selector(worldPoints)]) {
		NSArray * worldPoints = [_delegate worldPoints];
		
		for (ARWorldPoint * point in worldPoints) {
			Vec3 delta = [point position] - [origin position];
			
			glPushMatrix();
			glTranslatef(delta.x, delta.y, delta.z);
			
			[[point model] draw];
			
			glPopMatrix();
		}
	}
	
	[super update];
}

- (void)dealloc
{
	[videoFrameController release];	
	[videoBackground release];
	
	delete state;

    [super dealloc];
}

@end
