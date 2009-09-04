//
//  LaunchViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright 2009 Local Matters, Inc. All rights reserved.
//

#import "GroupsViewController.h"

@interface RootViewController : GroupsViewController {
	UIView *groupsTitleView;
}

@property (nonatomic, retain) IBOutlet UIView *groupsTitleView;

- (void)showAllNotes;
- (void)showAllNotesWithQuickAdd;

@end
