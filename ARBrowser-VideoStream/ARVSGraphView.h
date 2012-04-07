//
//  ARVSGraph.h
//  ARBrowser
//
//  Created by Samuel Williams on 9/02/12.
//  Copyright (c) 2012 Orion Transfer Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARVSGraphView : UIView {
	// The number of sequences to display:
	NSUInteger _sequences;
	UIColor ** _colors;
	
	// The count of points in a sequence
	NSUInteger _count;
	CGFloat * _points;
	
	NSUInteger _current;
		
	CGFloat _scale;
}

@property(nonatomic,assign) CGFloat scale;

- (void)setPointCount:(NSUInteger)count;

- (void)setSequenceCount:(NSUInteger)count;
- (void)setColor:(UIColor*)color ofSequence:(NSUInteger)sequence;

- (void)addPoints:(CGFloat*)points;

@end
