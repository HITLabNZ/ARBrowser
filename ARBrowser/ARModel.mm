//
//  ARModel.m
//  ARBrowser
//
//  Created by Samuel Williams on 13/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import "ARModel.h"

#import "ARObjectModel.h"
#import "ARViewModel.h"

@implementation ARModel

+ (id<ARRenderable>) objectModelWithName:(NSString*)name inDirectory:(NSString*)directory
{
	return [[[ARObjectModel alloc] initWithName:name inDirectory:directory] autorelease];
}

+ (id<ARRenderable>) viewModelWithView: (UIView*)view
{
	ARViewModel * model = [[ARViewModel alloc] init];
	
	[model setOverlay:view];
	
	return [model autorelease];
}

@end
