//
//  ARAMiniMapView.h
//  ARBrowser
//
//  Created by Samuel Williams on 14/07/12.
//  Copyright (c) 2012 Orion Transfer Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARAPath.h"

@interface ARAMiniMapView : UIView

@property(nonatomic,retain) ARAPath * path;
@property(nonatomic,retain) ARWorldLocation * location;

@end
