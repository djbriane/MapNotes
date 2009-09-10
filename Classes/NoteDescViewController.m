//
//  NoteDetailsViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 8/9/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import "TextFieldCell.h"
#import "NoteDescViewController.h"
#import "Note.h"

//Text View contstants
#define kUITextViewCellRowHeight 180.0

@implementation NoteDescViewController

@synthesize note;
@synthesize delegate;
@synthesize myTableView;

- (void)viewDidLoad {
    
    // Configure the navigation bar
    if (note.title != nil) {
		self.navigationItem.title = @"Edit Description";
	} else {
		self.navigationItem.title = @"Add Description";
	}
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"img_bkgnd.png"]];
	
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    [cancelButtonItem release];
    
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    [saveButtonItem release];
}

- (void)viewDidAppear:(BOOL)flag {
    [super viewDidAppear:flag];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Support all orientations except upside-down
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



- (void)save {
	TextViewCell *cell = (TextViewCell *) [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	//[cell.textView resignFirstResponder];
	note.details = [cell.textView text];
	[self.delegate noteDescViewController:self didSetDesc:note didSave:YES];
}

- (void)cancel {
    [self.delegate noteDescViewController:self didSetDesc:note didSave:NO];
}

#pragma mark Table view methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result;
    result = kUITextViewCellRowHeight;    
    return result;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    TextViewCell *cell = (TextViewCell *) [tableView dequeueReusableCellWithIdentifier:kCellTextView_ID];
	
    if (cell == nil) {
        cell = [TextViewCell createNewTextCellFromNib];
    }
	
    // Set up the cell...
    cell.textView.text = note.details;
	//[cell.textView setReturnKeyType:UIReturnKeyDone];
    [cell.textView becomeFirstResponder];
    cell.textView.delegate = self;
    return cell;
}

#pragma mark UITextView delegate methods
- (void)textViewDidBeginEditing:(UITextView *)textView {
	
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	/*
	if ([text isEqualToString:@"\n"]) {
		//[textView resignFirstResponder];
		[self save];
		return NO;
	}
	 */
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	//[self save];
	//TextViewCell *cell = (TextViewCell *) [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	//note.details = [cell.textView text];
	//[self.delegate noteDescViewController:self didSetDesc:note didSave:YES];
}

- (void)dealloc {
    [note release];    
    [myTableView release];    
    [super dealloc];
}

@end
