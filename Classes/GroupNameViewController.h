//
//  GroupNameViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 8/29/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#define kMaxGroupLength 25

#import <UIKit/UIKit.h>

@protocol GroupNameDelegate;
@class Group;

@interface GroupNameViewController : UIViewController <UITextFieldDelegate> {
	@private
		Group *group;
		BOOL isNewGroup;
		UITextField *titleTextField;
		UILabel *charCountLabel;
		UISegmentedControl *markerTypeControl;
		id <GroupNameDelegate> delegate;
	
}

@property (nonatomic, retain) Group *group;
@property (nonatomic, assign) BOOL isNewGroup;
@property (nonatomic, retain) IBOutlet UITextField *titleTextField;
@property (nonatomic, retain) IBOutlet UILabel *charCountLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *markerTypeControl;
@property (nonatomic, assign) id <GroupNameDelegate> delegate;

- (IBAction)doneButtonOnKeyboardPressed:(id)sender;
- (void)save;
- (void)cancel;

@end

@protocol GroupNameDelegate <NSObject>
// recipe == nil on cancel
- (void)groupNameViewController:(GroupNameViewController *)groupNameViewController 
					didSetTitle:(Group *)group 
						didSave:(BOOL)didSave
					   newGroup:(BOOL)newGroup;

@end
