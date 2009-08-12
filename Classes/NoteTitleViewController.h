//
//  TextNoteAddViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 8/9/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoteTitleDelegate;
@class Note;

@interface NoteTitleViewController : UIViewController <UITextFieldDelegate> {
	@private
		Note *note;
		UITextField *titleTextField;
		id <NoteTitleDelegate> delegate;
}

@property(nonatomic, retain) Note *note;
@property(nonatomic, retain) IBOutlet UITextField *titleTextField;
@property(nonatomic, assign) id <NoteTitleDelegate> delegate;

- (void)save;
- (void)cancel;

@end


@protocol NoteTitleDelegate <NSObject>
// recipe == nil on cancel
- (void)noteTitleViewController:(NoteTitleViewController *)noteTitleViewController didSetTitle:(Note *)note didSave:(BOOL)didSave;

@end

