//
//  GroupNameViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 8/29/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupNameDelegate;
@class Group;

@interface GroupNameViewController : UIViewController <UITextFieldDelegate> {
	@private
		Group *group;
		UITextField *titleTextField;
		id <GroupNameDelegate> delegate;
	
}

@property(nonatomic, retain) Group *group;
@property(nonatomic, retain) IBOutlet UITextField *titleTextField;
@property(nonatomic, assign) id <GroupNameDelegate> delegate;

- (IBAction)doneButtonOnKeyboardPressed:(id)sender;
- (void)save;
- (void)cancel;

@end

@protocol GroupNameDelegate <NSObject>
// recipe == nil on cancel
- (void)groupNameViewController:(GroupNameViewController *)groupNameViewController didSetTitle:(Group *)group didSave:(BOOL)didSave;

@end
