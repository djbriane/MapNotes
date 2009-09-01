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

@synthesize group;
@synthesize titleTextField;
@synthesize delegate;

- (void)viewDidLoad {
    
    // Configure the navigation bar
    if (group.name != nil) {
		self.navigationItem.title = @"Edit Name";
	} else {
		self.navigationItem.title = @"Add Group";
	}
	if (group != nil) {
		titleTextField.text = group.name;
	}
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"StripedBG.png"]];
	
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    [cancelButtonItem release];
    
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    [saveButtonItem release];
	
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
	group.name = titleTextField.text;
	
	[self.delegate groupNameViewController:self didSetTitle:group didSave:YES];
}


- (void)cancel {
    [self.delegate groupNameViewController:self didSetTitle:group didSave:NO];
}


- (void)dealloc {
    [group release];    
    [titleTextField release];    
    [super dealloc];
}



@end

