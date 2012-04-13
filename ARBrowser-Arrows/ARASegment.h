//
//  ARASegment.h
//  ARBrowser
//
//  Created by Samuel Williams on 3/04/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ARModel.h"

#include <vector>

@interface ARASegment : NSObject

@property(nonatomic,retain) NSArray * steps;

+ (ARASegment *)segmentFrom:(ARWorldLocation *)from to:(ARWorldLocation *)to;

- (BOOL) isVisibleFrom:(ARWorldLocation *)location;

@end
