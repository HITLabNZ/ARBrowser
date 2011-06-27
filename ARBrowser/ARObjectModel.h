//
//  ARObjectModel.h
//  ARBrowser
//
//  Created by Samuel Williams on 27/06/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

// This file is a private header and should not be included directly.

#import <Foundation/Foundation.h>

#include "ARModel.h"
#include "Model.h"

@interface ARObjectModel : NSObject<ARRenderable> {
@private
	ARBrowser::Model * mesh;
}

- initWithName: (NSString*)name inDirectory: (NSString*)directory;

- (void) draw;
- (ARBoundingSphere) boundingSphere;

@end
