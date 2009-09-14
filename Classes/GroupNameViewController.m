//
//  GroupNameViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 8/29/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import "GroupNameViewController.h"
#import "Group.h"

@implementation GroupNameViewController

@synthesize group, isNewGroup;
@synthesize titleTextField, charCountLabel, markerTypeControl;
@synthesize delegate;

- (void)viewDidLoad {
    
    // Configure the navigation bar
    if (group.name != nil) {
		self.navigationItem.title = @"Edit Name";
	} else {
		self.navigationItem.title = @"New Group";
	}
	if (group != nil) {
		titleTextField.text = group.name;
		[markerTypeControl setSelectedSegmentIndex:[group.marker intValue]];
	}
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"img_bkgnd.png"]];
	
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    [cancelButtonItem release];
    
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    [saveButtonItem release];
	
	if (group != nil) {
		charCountLabel.text = [NSString stringWithFormat:@"%d", (kMaxGroupLength - group.name.length)];
	} else {
		charCountLabel.text = [NSString stringWithFormat:@"%d", (kMaxGroupLength)];
	}
	
	[titleTextField becomeFirstResponder];
}


- (void)viewDidUnload {
	self.titleTextField = nil;
	[super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Support all orientations except upside-down
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField.text.length >= kMaxGroupLength && range.length == 0) {
        charCountLabel.text = @"0";	
		return NO; // return NO to not change text
    } else {
		NSInteger charCount;
		if (range.length > 0) {
			charCount = kMaxGroupLength - textField.text.length + range.length;
		} else {
			charCount = kMaxGroupLength - textField.text.length - string.length;
		}
		
		charCountLabel.text = [NSString stringWithFormat:@"%d", charCount];
		return YES;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == titleTextField) {
		[titleTextField resignFirstResponder];
		[self save];
	}
	return YES;
}

-(IBAction)doneButtonOnKeyboardPressed:(id)sender {
	[self save];
}

- (void)save {
	[group setName:titleTextField.text];
	//NSNumber selectedIndex = [markerTypeControl selectedSegmentIndex];
	[group setMarker:[NSNumber numberWithInteger:[markerTypeControl selectedSegmentIndex]]];
	//[group setMarker:(NSNumber *)[markerTypeControl selectedSegmentIndex]];
	[self.delegate groupNameViewController:self didSetTitle:group didSave:YES newGroup:isNewGroup];
}


- (void)cancel {
    [self.delegate groupNameViewController:self didSetTitle:group didSave:NO newGroup:isNewGroup];
}


- (void)dealloc {
    [group release];    
    [titleTextField release];    
    [super dealloc];
}



@end

