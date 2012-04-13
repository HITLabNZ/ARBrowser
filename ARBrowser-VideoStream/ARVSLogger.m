//
//  ARVSLogger.m
//  ARBrowser
//
//  Created by Samuel Williams on 30/01/12.
//  Copyright (c) 2012 Samuel Williams. All rights reserved.
//

#import "ARVSLogger.h"
#import <ImageIO/ImageIO.h>

@interface ARVSLogger ()
@property(readwrite,retain) NSString * path;
@end

@implementation ARVSLogger

@synthesize path = _path;

+ loggerForDocumentName:(NSString*)name {
	NSError * error = nil;
	
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSDateFormatter * format = [[NSDateFormatter new] autorelease];
	[format setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
	
	NSString * top = [NSString stringWithFormat:@"%@-%@", name, [format stringFromDate:[NSDate date]]];
	NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:top];
	
	NSFileManager * fileManager = [NSFileManager defaultManager];

	[fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
	
	if (error) {
		NSLog(@"Error creating directory at path %@: %@", directory, error);
		return nil;
	}
		
	return [[[ARVSLogger alloc] initWithPath:directory] autorelease];
}

- initWithPath:(NSString*)path {
	self = [super init];
	
	if (self) {
		[self setPath:path];
		
		NSFileManager * fileManager = [NSFileManager defaultManager];
		
		NSString * logPath = [path stringByAppendingPathComponent:@"log.txt"];
		
		if (![fileManager fileExistsAtPath:logPath]) {
			[fileManager createFileAtPath:logPath contents:nil attributes:nil];
		}
		
		_fileHandle = [[NSFileHandle fileHandleForWritingAtPath:logPath] retain];
		[_fileHandle seekToEndOfFile];
		
		_syncTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(synchronizeFile:) userInfo:nil repeats:YES];
		
		NSLog(@"Opening log file: %@", logPath);
	}
	
	return self;
}

- (void)close {
	NSLog(@"Closing log file: %@", _path);
	
	if (_syncTimer) {
		[_syncTimer invalidate];
		_syncTimer = nil;
	}
	
	if (_fileHandle) {
		[_fileHandle closeFile];
		[_fileHandle release];
		_fileHandle = nil;
	}
}

- (void)dealloc
{
	[self close];
	
	[self setPath:nil];
	
	[super dealloc];
}

- (void) synchronizeFile: (id)sender {
	NSLog(@"Sync log file: %@", _path);
	[_fileHandle synchronizeFile];
}

- (void)logWithFormat:(NSString *)messageFormat, ... {
	va_list args;
	va_start(args, messageFormat);
	
	_logCounter++;
	
	NSString * message = [[NSString alloc] initWithFormat:messageFormat arguments:args];
	
	NSString * logMessage = [NSString stringWithFormat:@"%d, %@\n", _logCounter, message];
	[_fileHandle writeData:[logMessage dataUsingEncoding:NSUTF8StringEncoding]];	
	
	[message release];
}

-(void)saveImage:(CGImageRef)imageRef toPath:(NSString *)path {
    NSURL *outURL = [[NSURL alloc] initFileURLWithPath:path];
	
	// Save the image to a png file:
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((CFURLRef)outURL, (CFStringRef)@"public.png" , 1, NULL);
    CGImageDestinationAddImage(destination, imageRef, NULL);
    CGImageDestinationFinalize(destination);
	
    [outURL release];
}

- (void)logImage:(CGImageRef)image withFormat:(NSString *)format, ... {
	va_list args;
	va_start(args, format);
	
	NSString * imageName = [[NSString alloc] initWithFormat:format arguments:args];
	NSString * path = [_path stringByAppendingPathComponent:[imageName stringByAppendingString:@".png"]];

	[self saveImage:image toPath:path];
}

@end
