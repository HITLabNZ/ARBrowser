//
//  ARWorldPoint.m
//  ARBrowser
//
//  Created by Samuel Williams on 13/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import "ARWorldPoint.h"


@implementation ARWorldPoint

@synthesize model, metadata;

- (id)init
{
    self = [super init];
    if (self) {
        metadata = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
	[metadata release];

    [super dealloc];
}

- (NSString*) description {
	id name = [metadata objectForKey:@"name"];
	
	if (name)
		return [NSString stringWithFormat:@"<ARWorldPoint: %0.5f %0.5f '%@'>", location.latitude, location.longitude, name];
	else
		return [super description];
}

@end
