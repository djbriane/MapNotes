//
//  TextNoteAddViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 8/9/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import "NoteTitleViewController.h"
#import "Note.h"

@implementation NoteTitleViewController

@synthesize note;
@synthesize titleTextField;
@synthesize delegate;

- (void)viewDidLoad {
    
    // Configure the navigation bar
    if (note.title != nil) {
		self.navigationItem.title = @"Edit Title";
	} else {
		self.navigationItem.title = @"Add Note";
	}
    titleTextField.text = note.title;
	
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


- (void)save {
	note.title = titleTextField.text;

	[self.delegate noteTitleViewController:self didSetTitle:note didSave:YES];
}


- (void)cancel {
    [self.delegate noteTitleViewController:self didSetTitle:note didSave:NO];
}


- (void)dealloc {
    [note release];    
    [titleTextField release];    
    [super dealloc];
}

@end
