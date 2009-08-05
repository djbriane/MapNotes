//
//  ImageManipulator.h
//  MapNotes
//
//  Created by Brian Erickson on 8/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@interface ImageManipulator : NSObject {
}

+ (UIImage *)roundedCornerImageFromImage:(UIImage *)img withCornerWidth:(int)cornerWidth andCornerHeight:(int)cornerHeight;
+ (UIImage *)croppedImageFromImage:(UIImage *)imageToCrop toRect:(CGRect)rect;
+ (UIImage *)generatePhotoThumbnail:(UIImage *)image;

@end

@interface UIImage (INResizeImageAllocator)
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
- (UIImage*)scaleImageToSize:(CGSize)newSize;
@end

