//
//  ARObjectModel.m
//  ARBrowser
//
//  Created by Samuel Williams on 27/06/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import "ARObjectModel.h"


@implementation ARObjectModel

- initWithName: (NSString*)name inDirectory: (NSString*)directory
{
    self = [super init];
    if (self) {
        mesh = new ARBrowser::Model([name UTF8String], [directory UTF8String]);
    }
    
    return self;
}

- (void)dealloc
{
	if (mesh)
		delete mesh;
	
    [super dealloc];
}

- (void) draw
{
	if (mesh)
		mesh->render();
}

- (ARBoundingSphere) boundingSphere
{
	if (mesh) {
		ARBrowser::BoundingBox box = mesh->boundingBox();
		
		ARBoundingSphere sphere = {box.center(), box.radius()};
		
		return sphere;
	} else {
		ARBoundingSphere sphere = {Vec3(0, 0, 0), 0};
		
		return sphere;
	}
}

@end
