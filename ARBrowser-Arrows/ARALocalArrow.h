//  ARALocalArrow.h
//  ARBrowser
//
//  Created by Samuel Williams on 16/4/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ARAPath.h"
#import "ARWorldPoint.h"

@interface ARALocalArrow : NSObject {
	// Typicalyly, 0.75 would be a good value
	float _angleScale, _radius;
}

@property(nonatomic,assign) float angleScale;
@property(nonatomic,assign) float radius;

@property(nonatomic,assign) ARAPathBearing pathBearing;
@property(nonatomic,assign) ARLocationRadians currentBearing;

- (void)draw;

@end