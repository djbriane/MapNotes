//
//  TextNoteAddViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 8/9/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import "NoteTitleViewController.h"
#import "Note.h"

@implementation NoteTitleViewController

@synthesize note;
@synthesize titleTextField, charCountLabel;
@synthesize delegate;

- (void)viewDidLoad {
    
    // Configure the navigation bar
    if (note.title != nil) {
		self.navigationItem.title = @"Edit Title";
	} else {
		self.navigationItem.title = @"Add Note";
	}
    titleTextField.text = note.title;
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"img_bkgnd.png"]];
	
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    [cancelButtonItem release];
    
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    [saveButtonItem release];
	
	if (note != nil) {
		charCountLabel.text = [NSString stringWithFormat:@"%d", (kMaxTitleLength - note.title.length)];
	} else {
		charCountLabel.text = [NSString stringWithFormat:@"%d", (kMaxTitleLength)];
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
	//NSLog([NSString stringWithFormat:@"Length (Pre): %d", textField.text.length]);
	//NSLog([NSString stringWithFormat:@"Length (Post): %d", string.length]);
	//NSLog([NSString stringWithFormat:@"Range: %d", range.length]);

	if (textField.text.length >= kMaxTitleLength && range.length == 0) {
        charCountLabel.text = @"0";	
		return NO; // return NO to not change text
    } else {
		NSInteger charCount;
		if (range.length > 0) {
			charCount = kMaxTitleLength - textField.text.length + range.length;
		} else {
			charCount = kMaxTitleLength - textField.text.length - string.length;
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
