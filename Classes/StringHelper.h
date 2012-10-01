//
//  StringHelper.h
//  MapNotes
//
//  Created by Brian Erickson on 8/26/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import <UIKit/UIKit.h>

@interface NSString (StringHelper)

- (CGFloat)RAD_textHeightForSystemFontOfSize:(CGFloat)size;
- (UILabel *)RAD_newSizedCellLabelWithSystemFontOfSize:(CGFloat)size;	
- (CGRect)RAD_frameForCellLabelWithSystemFontOfSize:(CGFloat)size;
- (void)RAD_resizeLabel:(UILabel *)aLabel withSystemFontOfSize:(CGFloat)size;

@end
