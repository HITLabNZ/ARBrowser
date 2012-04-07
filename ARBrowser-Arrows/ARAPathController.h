//
//  ARAPathController.h
//  ARBrowser
//
//  Created by Samuel Williams on 2/04/12.
//  Copyright (c) 2012 Orion Transfer Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ARAPath.h"
#import "ARModel.h"

@interface ARAPathController : NSObject

@property(nonatomic,retain) id<ARRenderable> markerModel;
@property(nonatomic,retain) id<ARRenderable> stepModel;

@property(nonatomic,retain) ARAPath * path;

- (NSArray*)visiblePoints;
- (NSArray*)visiblePointsFromLocation:(ARWorldLocation *)origin;

@end
