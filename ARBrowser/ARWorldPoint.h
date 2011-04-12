//
//  ARWorldPoint.h
//  ARBrowser
//
//  Created by Samuel Williams on 13/04/11.
//  Copyright 2011 Orion Transfer Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARWorldLocation.h"

@class ARModel;

@interface ARWorldPoint : ARWorldLocation {
	ARModel * model;
	
	NSMutableDictionary * metadata;
}

@property(nonatomic,retain) ARModel * model;
@property(nonatomic,retain) NSMutableDictionary * metadata;

@end
