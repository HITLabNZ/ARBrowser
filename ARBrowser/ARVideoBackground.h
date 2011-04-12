//
//  ARVideoBackground.h
//  ARBrowser
//
//  Created by Samuel Williams on 5/04/11.
//  Copyright 2011 Orion Transfer Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ARVideoFrameController.h"

@interface ARVideoBackground : NSObject {
	GLuint texture;
	CGSize size, scale;
		
	int lastIndex;
		
	GLenum pixelFormat, internalFormat, dataType;
}

- (void) update: (ARVideoFrame*) frame;
- (void) draw;

@end
