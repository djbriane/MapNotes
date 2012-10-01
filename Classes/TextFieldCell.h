//
//  TextFieldCell.h
//  MapNotes
//
//  Created by Brian Erickson on 8/26/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import <UIKit/UIKit.h>

// cell identifier for this custom cell
extern NSString *kCellTextView_ID;

@interface TextViewCell : UITableViewCell {
    IBOutlet UITextView *textView;
}
+ (TextViewCell*) createNewTextCellFromNib;

@property (nonatomic, retain) UITextView *textView;

@end
