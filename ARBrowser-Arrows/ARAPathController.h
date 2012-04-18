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
@property(nonatomic,assign) NSUInteger currentSegmentIndex;

- (NSArray*)visiblePoints;
- (NSArray*)visiblePointsFromLocation:(ARWorldLocation *)origin withinDistance:(float)distance;

- (BOOL)updateSegmentIndexFromLocation:(ARWorldLocation *)location;

@end
