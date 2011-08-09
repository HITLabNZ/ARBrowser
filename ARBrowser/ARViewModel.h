//
//  ARViewModel.h
//  ARBrowser
//
//  Created by Samuel Williams on 3/08/11.
//  Copyright 2011 Orion Transfer Ltd. All rights reserved.
//

#import "ARModel.h"

#import "Model.h"
#import "Texture2D.h"

@interface ARViewModel : NSObject<ARRenderable> {
	GLuint billboardTexture;
	
	BOOL _dirty;
	UIView * _overlay;
	
	float _scale;
}

@property(nonatomic, retain) IBOutlet UIView * overlay;
@property(nonatomic, assign) float scale;

/// Next time the billboard is generated, update the view.
- (void) setNeedsUpdate;
- (void) updateNow;

@end
