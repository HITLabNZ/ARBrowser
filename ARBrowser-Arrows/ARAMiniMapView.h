//
//  ARAMiniMapView.h
//  ARBrowser
//
//  Created by Samuel Williams on 14/07/12.
//  Copyright (c) 2012 Orion Transfer Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARAPathController.h"

@interface ARAMiniMapView : UIView

@property(nonatomic,retain) ARAPathController * pathController;
@property(nonatomic,retain) ARWorldLocation * location;
@property(nonatomic,retain) UIImage * markerImage;

@end
