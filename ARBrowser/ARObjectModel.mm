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
		_name = [name copy];
		_directory = [directory copy];
    }
    
    return self;
}

- (void)dealloc
{
	[_name release];
	[_directory release];

	if (mesh)
		delete mesh;
	
    [super dealloc];
}

- (void) loadMesh
{
	if (!mesh) {
        mesh = new ARBrowser::Model([_name UTF8String], [_directory UTF8String]);
	}
}

- (void) draw
{	
	[self loadMesh];
	
	mesh->render();
}

- (ARBoundingSphere) boundingSphere
{
	[self loadMesh];

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
