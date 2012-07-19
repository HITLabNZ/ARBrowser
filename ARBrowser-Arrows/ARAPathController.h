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

@interface ARAPathController : NSObject

@property(nonatomic,retain) id<ARRenderable> markerModel;
@property(nonatomic,retain) id<ARRenderable> stepModel;

@property(nonatomic,retain) ARAPath * path;

/// The current location relative to the path:
@property(nonatomic,readonly,retain) ARWorldLocation * currentLocation;

/// The radius from the turning point that we consider the user is making a turn from:
@property(nonatomic,assign) float turningRadius;

/// The current path segment that we are checking for turning, sequencing from one segment to the next in order:
@property(nonatomic,readonly,assign) NSUInteger currentSegmentIndex;

/// True if the user is within a turn, e.g. distance from the turning point < turningRadius:
@property(nonatomic,readonly,assign) BOOL turning;

// We formulate a number from -1 to +1.
// -1 means we are entering the turn.
// 0 means we are at the middle of the turn.
// 1 means we are exiting the turn.
// This number is calculated by looking at the distance from the current segment and the distance to the next segment, and the ratio of distance to distanceFromCurrentSegment.
// This value is only valid if the property turning is YES.
@property(nonatomic,assign) float turningRatio;

/// Convenient helper for the current segment as given by currentSegmentIndex and path:
@property(nonatomic,readonly,retain) ARASegment * currentSegment;

- (NSArray*)visiblePoints;
- (NSArray*)visiblePointsFromLocation:(ARWorldLocation *)origin withinDistance:(float)distance;

- (BOOL)updateLocation:(ARWorldLocation *)location;
- (ARAPathBearing) currentBearing;

@end
