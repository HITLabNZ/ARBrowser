//
//  ARATurnIconView.m
//  ARBrowser
//
//  Created by Samuel Williams on 19/07/12.
//
//

#import "ARAIconView.h"

@implementation ARAIconView

@synthesize overlayColor = _overlayColor, originalImage = _originalImage;

+ (UIImage *)tintedImage: (UIImage *)image withColor:(UIColor *)color {
    CGRect rect = {{0, 0}, image.size};
	UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Make sure the image is drawn up the right way:
	CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
	
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, image.CGImage);
	
    // Apply tint
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
	
	[color setFill];
	CGContextFillRect(context, rect);
	
	UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return result;
}

- (void)setOverlayColor:(UIColor *)overlayColor {
	if (_overlayColor == overlayColor) return;
	
	[_overlayColor release];
	_overlayColor = [overlayColor retain];
	
	if (_originalImage) {
		if (_overlayColor) {
			[super setImage:[ARAIconView tintedImage:self.originalImage withColor:_overlayColor]];
		} else {
			[super setImage:_originalImage];
		}
	}
}

- (void)setImage:(UIImage *)image {
	if (_originalImage != image) {
		self.originalImage = image;
		
		if (_overlayColor) {
			image = [ARAIconView tintedImage:image withColor:_overlayColor];
		}
		
		[super setImage:image];
	}
}

@end
