//
//  ImageManipulator.h
//  MapNotes
//
//  Created by Brian Erickson on 8/3/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

@interface ImageManipulator : NSObject {
}

+ (UIImage *)roundedCornerImageFromImage:(UIImage *)img withCornerWidth:(int)cornerWidth andCornerHeight:(int)cornerHeight;
+ (UIImage *)croppedImageFromImage:(UIImage *)imageToCrop toRect:(CGRect)rect;
+ (UIImage *)scaleAndRotateImage:(UIImage *)image;
+ (UIImage *)generatePhotoThumbnail:(UIImage *)image;

@end

@interface UIImage (INResizeImageAllocator)
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
- (UIImage*)scaleImageToSize:(CGSize)newSize;
@end

