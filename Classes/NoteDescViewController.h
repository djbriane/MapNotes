//
//  TextNoteAddViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 8/9/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoteDescDelegate;
@class Note;

@interface NoteDescViewController : UITableViewController <UITextViewDelegate> {
	@private
		Note *note;
		id <NoteDescDelegate> delegate;
		IBOutlet UITableView *myTableView;
}

@property(nonatomic, retain) Note *note;
@property(nonatomic, assign) id <NoteDescDelegate> delegate;
@property(nonatomic, retain) IBOutlet UITableView *myTableView;

- (void)save;
- (void)cancel;

@end

@protocol NoteDescDelegate <NSObject>
// recipe == nil on cancel
- (void)noteDescViewController:(NoteDescViewController *)noteDescViewController didSetDesc:(Note *)note didSave:(BOOL)didSave;

@end

