//
//  LaunchViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 7/24/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import "GroupsViewController.h"

@interface RootViewController : GroupsViewController {
	UIView *groupsTitleView;
}

@property (nonatomic, retain) IBOutlet UIView *groupsTitleView;

- (void)showAllNotesItem:(BOOL)animated;
- (void)showAllNotes;
- (void)showAllNotesWithQuickAdd;

@end
