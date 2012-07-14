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

typedef enum {
	ARASegmentAhead = 1,
	ARASegmentEntering = 2,
	ARASegmentExiting = 4,
	ARASegmentBehind = 8,
	ARASegmentDispositionAny = (1|2|4|8)
} ARASegmentDisposition;

@interface ARASegment : NSObject

@property(nonatomic,retain) ARWorldLocation * from;
@property(nonatomic,retain) ARWorldLocation * to;
@property(nonatomic,retain) NSArray * steps;

@property(nonatomic,retain) NSMutableDictionary * metadata;

- initFrom:(ARWorldLocation *)from to:(ARWorldLocation *)to;

/// Compute a set of intermediate steps between two points:
+ (NSArray *)intermediateStepsFrom:(ARWorldLocation *)from to:(ARWorldLocation *)to;

- (float)distanceFrom:(ARWorldLocation *)location;

- (ARASegmentDisposition)dispositionRelativeTo:(ARWorldLocation *)location;

- (ARASegmentDisposition)snapLocation:(ARWorldLocation *)location;

- (CLLocationDistance)distance;

@end