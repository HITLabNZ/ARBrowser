//
//  ARAPathController.h
//  ARBrowser
//
//  Created by Samuel Williams on 2/04/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ARAPath.h"
#import "ARModel.h"

@class UNRoute;

@interface ARAPathController : NSObject

@property(nonatomic,retain) id<ARRenderable> markerModel;
@property(nonatomic,retain) id<ARRenderable> stepModel;

@property(nonatomic,retain) ARAPath * path;
@property(nonatomic,readonly,retain) ARWorldLocation * currentLocation;

// The radius from the turning point that we consider the user is making a turn from:
@property(nonatomic,assign) float turningRadius;

@property(nonatomic,readonly,assign) NSUInteger currentSegmentIndex;
@property(nonatomic,readonly,assign) BOOL turning;

// We formulate a number from -1 to +1.
// -1 means we are entering the turn.
// 0 means we are at the middle of the turn.
// 1 means we are exiting the turn.
// This number is calculated by looking at the distance from the current segment and the distance to the next segment, and the ratio of distance to distanceFromCurrentSegment.
// This value is only valid if the property turning is YES.
@property(nonatomic,assign) float turningRatio;

@property(nonatomic,readonly,retain) ARASegment * currentSegment;

- (NSArray*)visiblePoints;
- (NSArray*)visiblePointsFromLocation:(ARWorldLocation *)origin withinDistance:(float)distance;

- (BOOL)updateLocation:(ARWorldLocation *)location;
- (ARAPathBearing) currentBearing;

@end
