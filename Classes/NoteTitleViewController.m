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
    self.navigationItem.title = @"Add Note";
    
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
	
	NSError *error = nil;
	if (![note.managedObjectContext save:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
    
	[self.delegate noteTitleViewController:self didSetTitle:note];
}


- (void)cancel {
	
	[note.managedObjectContext deleteObject:note];
	
	NSError *error = nil;
	if (![note.managedObjectContext save:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
	
    [self.delegate noteTitleViewController:self didSetTitle:nil];
}


- (void)dealloc {
    [note release];    
    [titleTextField release];    
    [super dealloc];
}

@end
