//
//  ARModel.h
//  ARBrowser
//
//  Created by Samuel Williams on 13/04/11.
//  Copyright 2011 Orion Transfer Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

struct ARModelState;

@interface ARModel : NSObject {
	struct ARModelState * state;
}

- initWithName: (NSString*)name inDirectory: (NSString*)directory;
- (void) draw;

@end
