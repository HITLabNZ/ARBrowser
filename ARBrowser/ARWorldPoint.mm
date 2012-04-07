//
//  ARWorldPoint.m
//  ARBrowser
//
//  Created by Samuel Williams on 13/04/11.
//  Copyright 2011 Samuel Williams. All rights reserved.
//

#import "ARWorldPoint.h"


@implementation ARWorldPoint

@synthesize model, metadata, fixed = _fixed;

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
		return [NSString stringWithFormat:@"<ARWorldPoint: %0.8f %0.8f '%@'>", _coordinate.latitude, _coordinate.longitude, name];
	else
		return [super description];
}

- (NSString*) title
{
	NSString * title = [metadata objectForKey:@"title"];
	
	if (title)
		return title;
	
	NSString * name = [metadata objectForKey:@"name"];
	
	if (name)
		return name;
	
	return @"ARWorldPoint";
}

- (NSString*) subtitle
{
	NSString * subtitle = [metadata objectForKey:@"subtitle"];
	
	if (subtitle)
		return subtitle;
	
	return [self description];
}

@end
