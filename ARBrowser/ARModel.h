//
//  ARModel.h
//  ARBrowser
//
//  Created by Samuel Williams on 13/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ARWorldPoint.h"

/// This class represents a 3D model.
@interface ARModel : NSObject

+ (id<ARRenderable>) objectModelWithName:(NSString*)name inDirectory:(NSString*)directory;

@end
