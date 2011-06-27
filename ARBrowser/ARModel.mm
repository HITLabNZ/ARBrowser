//
//  ARModel.m
//  ARBrowser
//
//  Created by Samuel Williams on 13/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import "ARModel.h"

#import "ARObjectModel.h"

@implementation ARModel

+ (id<ARRenderable>) objectModelWithName:(NSString*)name inDirectory:(NSString*)directory
{
	return [[ARObjectModel alloc] initWithName:name inDirectory:directory];
}


@end
