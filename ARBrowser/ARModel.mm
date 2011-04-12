//
//  ARModel.m
//  ARBrowser
//
//  Created by Samuel Williams on 13/04/11.
//  Copyright 2011 Orion Transfer Ltd. All rights reserved.
//

#import "ARModel.h"

#import "Model.h"

struct ARModelState {
	ARBrowser::Model * model;
};

@implementation ARModel

- initWithName: (NSString*)name inDirectory: (NSString*)directory
{
    self = [super init];
    if (self) {
        state = new ARModelState;
		state->model = new ARBrowser::Model([name UTF8String], [directory UTF8String]);
    }
    
    return self;
}

- (void)dealloc
{
	if (state) {
		if (state->model)
			delete state->model;
		
		delete state;
	}
	
    [super dealloc];
}

- (void) draw
{
	if (state && state->model)
		state->model->render();
}

@end
