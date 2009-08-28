//
//  StringHelper.m
//  MapNotes
//
//  Created by Brian Erickson on 8/26/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import "StringHelper.h"


@implementation NSString (StringHelper)

#pragma mark Methods to determine the height of a string for resizeable table cells
- (CGFloat)RAD_textHeightForSystemFontOfSize:(CGFloat)size {
	//Calculate the expected size based on the font and linebreak mode of your label
	CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 90;
	CGFloat maxHeight = 9999;
	CGFloat minHeight = 21;
	
	CGSize maximumLabelSize = CGSizeMake(maxWidth,maxHeight);
	
	CGSize expectedLabelSize = [self sizeWithFont:[UIFont systemFontOfSize:size] 
								constrainedToSize:maximumLabelSize 
									lineBreakMode:UILineBreakModeWordWrap]; 
	if (expectedLabelSize.height < minHeight) {
		return minHeight;
	} else {
		return expectedLabelSize.height;
	}
}

- (CGRect)RAD_frameForCellLabelWithSystemFontOfSize:(CGFloat)size {
	CGFloat width = [UIScreen mainScreen].bounds.size.width - 90;
	CGFloat height = [self RAD_textHeightForSystemFontOfSize:size] + 10.0;
	return CGRectMake(43.0f, 10.0f, width, height);
}

- (void)RAD_resizeLabel:(UILabel *)aLabel WithSystemFontOfSize:(CGFloat)size {
	aLabel.frame = [self RAD_frameForCellLabelWithSystemFontOfSize:size];
	aLabel.text = self;
	[aLabel sizeToFit];
}

- (UILabel *)RAD_newSizedCellLabelWithSystemFontOfSize:(CGFloat)size withBold:(BOOL)isBold {
	UILabel *cellLabel = [[UILabel alloc] initWithFrame:[self RAD_frameForCellLabelWithSystemFontOfSize:size]];
	cellLabel.textColor = [UIColor blackColor];
	cellLabel.backgroundColor = [UIColor clearColor];
	cellLabel.textAlignment = UITextAlignmentLeft;
	if (isBold) {
		cellLabel.font = [UIFont boldSystemFontOfSize:size];
	} else {
		cellLabel.font = [UIFont systemFontOfSize:size];
	}
	
	cellLabel.text = self; 
	cellLabel.numberOfLines = 0; 
	[cellLabel sizeToFit];
	return cellLabel;
}

@end

