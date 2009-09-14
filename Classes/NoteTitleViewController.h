//
//  TextNoteAddViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 8/9/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#define kMaxTitleLength 35

#import <UIKit/UIKit.h>

@protocol NoteTitleDelegate;
@class Note;

@interface NoteTitleViewController : UIViewController <UITextFieldDelegate> {
	@private
		Note *note;
		UITextField *titleTextField;
		UILabel *charCountLabel;
		id <NoteTitleDelegate> delegate;
}

@property(nonatomic, retain) Note *note;
@property(nonatomic, retain) IBOutlet UITextField *titleTextField;
@property (nonatomic, retain) IBOutlet UILabel *charCountLabel;
@property(nonatomic, assign) id <NoteTitleDelegate> delegate;

- (IBAction)doneButtonOnKeyboardPressed:(id)sender;
- (void)save;
- (void)cancel;

@end


@protocol NoteTitleDelegate <NSObject>
// recipe == nil on cancel
- (void)noteTitleViewController:(NoteTitleViewController *)noteTitleViewController didSetTitle:(Note *)note didSave:(BOOL)didSave;

@end

