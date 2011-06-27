//
//  ARWorldPoint.h
//  ARBrowser
//
//  Created by Samuel Williams on 13/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARWorldLocation.h"

/// Bounding Box
typedef struct {
	Vec3 center;
	float radius;
} ARBoundingSphere;

@protocol ARRenderable
- (void) draw;
- (ARBoundingSphere) boundingSphere;
@end

@interface ARWorldPoint : ARWorldLocation {
	id<ARRenderable> model;
	
	NSMutableDictionary * metadata;
}

@property(nonatomic,retain) id<ARRenderable> model;
@property(nonatomic,retain) NSMutableDictionary * metadata;

@end
