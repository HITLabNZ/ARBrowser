//
//  ARAPath.h
//  ARBrowser
//
//  Created by Samuel Williams on 25/03/12.
//  Copyright (c) 2012 Orion Transfer Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ARAPath : NSObject

@property(nonatomic,retain) NSArray * points;

/// For each point, we built a set of intermediate segments, this array contains lists of each segment corresponding to each point.
@property(nonatomic,retain) NSArray * segments;

- initWithPoints:(NSArray *)points;

+ (ARAPath *) testRouteAtLocation:(CLLocation *)location;

@end
