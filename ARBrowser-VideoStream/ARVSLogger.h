//
//  ARVSLogger.h
//  ARBrowser
//
//  Created by Samuel Williams on 30/01/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#include <UIKit/UIKit.h>
#include <CoreGraphics/CoreGraphics.h>

@interface ARVSLogger : NSObject {
	NSString * _path;
	NSFileHandle * _fileHandle;
	NSTimer * _syncTimer;
	NSUInteger _logCounter;
}

@property(nonatomic,retain) NSDate * startDate;
@property(readonly,retain) NSString * path;

- (NSTimeInterval)timestamp;

+ loggerForDocumentName:(NSString*)name;

- initWithPath:(NSString*)path;
- (void)close;

- (void)logWithFormat:(NSString *)format, ...;

- (void)logImage:(CGImageRef)image withFormat:(NSString *)format, ...;

@end
