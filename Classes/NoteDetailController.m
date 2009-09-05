//
//  NoteDetailController.m
//  MapNotes
//
//  Created by Brian Erickson on 7/26/09.
//  Copyright 2009 Local Matters, Inc. All rights reserved.
//

#import "Note.h"
#import "Group.h"

#import "NoteDetailController.h"
#import "NotePhotoViewController.h"
#import "NoteAnnotation.h"
#import "RoundedRectView.h"
#import "ImageManipulator.h"
#import "GroupsViewController.h"
#import "StringHelper.h"

//Note Description View contstants
#define kTextViewFontSize        14.0
#define kTextViewFontSizeDefault 17.0
#define kDefaultNoteLabel        @"Description"
#define kDefaultGroupLabel		 @"Group"
#define kMainLabelTag 1
#define kIconImageTag 2

@implementation NoteDetailController

@synthesize selectedNote;

@synthesize mapView = _mapView;
@synthesize noteAnnotation;
@synthesize tableHeaderView, tableFooterView;
@synthesize photoButton, deleteButton, nameTextField;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	 [super viewDidLoad];
	 self.tableView.backgroundColor = [UIColor clearColor];

	 //self.editing = NO; // Initially displays an Edit button and noneditable view
	 self.tableView.allowsSelectionDuringEditing = YES;

	 // Create and set the table header / footer view.
	 if (tableHeaderView == nil) {
		 [[NSBundle mainBundle] loadNibNamed:@"NoteDetailHeader" owner:self options:nil];
		 self.tableView.tableHeaderView = tableHeaderView;
	 }
	 if (tableFooterView == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"NoteDetailFooter" owner:self options:nil];
		self.tableView.tableFooterView = tableFooterView;
	 }
	 
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.navigationItem.rightBarButtonItem = [self editButtonItem];

	if (selectedNote.title != nil) {
		self.navigationItem.title = selectedNote.title;
		[nameTextField setTitle:[selectedNote title] forState:UIControlStateNormal];
		[nameTextField setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[nameTextField setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
	} else {
		[nameTextField setTitle:@"Note Title" forState:UIControlStateNormal];
		//nameTextField.titleLabel.font = [UIFont boldSystemFontOfSize:18];
		[nameTextField setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		[nameTextField setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];

	}
	[self initializeMap];
	[self updatePhotoInfo];
	[self.tableView reloadData];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

// If the setEditing: parameter is YES, the view should display editable controls; 
// otherwise, it should display noneditable controls.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
	[self.navigationItem setHidesBackButton:editing animated:YES];

	nameTextField.enabled = editing;
	
    if (editing == YES){
        // change view to an editable view
		nameTextField.enabled = YES;
		deleteButton.hidden = NO;
		//[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	}
    else {
        // save the changes if needed and change view to noneditable
		nameTextField.enabled = NO;
		deleteButton.hidden = YES;
    }
	
	// recalculate height / width of the description text field 
	//[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	//[self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

	
	// Update photo display accordingly
	[self updatePhotoInfo];
	
	/*
	 If editing is finished, save the managed object context.
	 */
	if (!editing) {
		NSManagedObjectContext *context = selectedNote.managedObjectContext;
		NSError *error = nil;
		if (![context save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}

	}
	
}

- (IBAction)editTitle {
	NoteTitleViewController *titleController = [[NoteTitleViewController alloc] initWithNibName:@"EditTitle" bundle:nil];
    titleController.delegate = self;
	titleController.note = self.selectedNote;

    [self.navigationController pushViewController:titleController animated:YES];
	
    [titleController release];
}

- (void)editDesc {
	NoteDescViewController *descController = [[NoteDescViewController alloc] initWithNibName:@"EditDesc" bundle:nil];
    descController.delegate = self;
	descController.note = self.selectedNote;
	
    [self.navigationController pushViewController:descController animated:YES];
	
    [descController release];
}

#pragma mark -
#pragma mark Note Title View Controller Methods
- (void)noteTitleViewController:(NoteTitleViewController *)controller 
					didSetTitle:(Note *)note
						didSave:(BOOL)didSave {
	if (didSave) {
		self.selectedNote = note;
	}
	[self.navigationController popViewControllerAnimated:YES];
	
}

#pragma mark -
#pragma mark Note Description View Controller Methods
- (void)noteDescViewController:(NoteDescViewController *)controller 
					didSetDesc:(Note *)note
						didSave:(BOOL)didSave {
	if (didSave) {
		self.selectedNote = note;
	}
	[self.navigationController popViewControllerAnimated:YES];
	//[self.tableView reloadData];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

}

#pragma mark -
#pragma mark Photo Acquisition Methods
- (IBAction)editPhoto {
	//Update the photo in response to a tap on the photo button.
	if (self.editing) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									 initWithTitle:nil
									 delegate:self
									 cancelButtonTitle:nil
									 destructiveButtonTitle:nil
									 otherButtonTitles:nil];
		// Take Photo Button
		if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			[actionSheet addButtonWithTitle:kTakePhotoButtonText];
		}
		
		// Choose Existing Button
		[actionSheet addButtonWithTitle:kChoosePhotoButtonText];
		
		// Delete Button
		if (nil != selectedNote.photo) {
			[actionSheet addButtonWithTitle:kDeletePhotoButtonText];
		}
		
		// Cancel Button
		actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
		
		//actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		[actionSheet showInView:self.view];
		[actionSheet release];
	}
	else if (nil != selectedNote.photo) {
		// Display the photo in its own view
		NotePhotoViewController *notePhotoViewController = [[NotePhotoViewController alloc] init];
        notePhotoViewController.hidesBottomBarWhenPushed = YES;
		notePhotoViewController.note = selectedNote;
		[self.navigationController pushViewController:notePhotoViewController animated:YES];
		[notePhotoViewController release];
	}
}

- (void)updatePhotoInfo {
	
	// Synchronize the photo image view and the text on the photo button with the event's photo.
	UIImage *image = selectedNote.thumbnail;
	
	if (image) {
		[photoButton setImage:image forState:UIControlStateNormal];
	}
	else if (self.editing) {
		image = [UIImage imageNamed:@"img_photo-add.png"];
		[photoButton setImage:image forState:UIControlStateNormal];
	} else {
		image = [UIImage imageNamed:@"img_photo-blank.png"];
		[photoButton setImage:image forState:UIControlStateNormal];		
	}
}

- (void)deleteExistingPhoto {
	/*
	 Delete the Photo object and dispose of the thumbnail.
	 Because the relationship was modeled in both directions, the event's relationship to the photo will automatically be set to nil.
	 */
	if (nil != selectedNote.photo) {
		[selectedNote.managedObjectContext deleteObject:selectedNote.photo];
		selectedNote.thumbnail = nil;
		
		// Commit the change.
		NSError *error;
		if (![selectedNote.managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
		}
		[self updatePhotoInfo];
	}
}

- (void)initializeMap {
	// Add Note to Map
	self.noteAnnotation = [NoteAnnotation annotationWithNote:selectedNote];
	
	MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
	region.center = selectedNote.location.coordinate;
	region.span.longitudeDelta = 0.005f;
	region.span.latitudeDelta = 0.005f;
	
	[self.mapView setRegion:region animated:NO];
	[self.mapView addAnnotation:self.noteAnnotation];
	// Done adding Note to map
	
}

#pragma mark -
#pragma mark Action Sheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ([actionSheet buttonTitleAtIndex:buttonIndex] == kTakePhotoButtonText) {
		// Take Photo
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		imagePicker.delegate = self;
		[self presentModalViewController:imagePicker animated:YES];
		[imagePicker release];
	} 
	else if ([actionSheet buttonTitleAtIndex:buttonIndex] == kChoosePhotoButtonText) {
		// Choose Existing
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePicker.delegate = self;
		[self presentModalViewController:imagePicker animated:YES];
		[imagePicker release];		
	} 
	else if ([actionSheet buttonTitleAtIndex:buttonIndex] == kDeletePhotoButtonText) {
		[self deleteExistingPhoto];
	}
}

#pragma mark -
#pragma mark Image Picker Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker 
		didFinishPickingImage:(UIImage *)selectedImage 
				  editingInfo:(NSDictionary *)editingInfo {
	
	// Delete Existing Photo
	[self deleteExistingPhoto];
	
	// Create a new photo object and associate it with the event.
	NSManagedObject *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" 
														   inManagedObjectContext:selectedNote.managedObjectContext];
	
	
	// Scale the image to a manageable size and rotate it properly to account for camera
	UIImage *image = [[ImageManipulator scaleAndRotateImage:selectedImage] retain];
	selectedNote.photo = photo;
	
	// Set the image for the image managed object.
	[photo setValue:image forKey:@"image"];
	
	// Generate and set a thumbnail for the note
	UIImage *thumbnail = [[ImageManipulator generatePhotoThumbnail:image] retain];
	selectedNote.thumbnail = thumbnail;
	[thumbnail release];
	[image release];
	
	// Commit the change.
	NSError *error;
	if (![selectedNote.managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
	}
	
	// Update the user interface appropriately.
	[self updatePhotoInfo];
	
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	// The user canceled -- simply dismiss the image picker.
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // There are three sections, for note details, move folders and share
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	/*
	 The number of rows varies by section.
	 */
    NSInteger rows = 0;
    switch (section) {
        case 0:
			// Details and Group
			rows = 2;
			break;
        default:
            break;
    }
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"CellIdentifier";
	static NSString *NoteCellIdentifier = @"NoteCellIdentifier";
	UITableViewCell *cell;
	UILabel *mainLabel;
    UIImageView *photo;
	
	if (indexPath.section == 0 && indexPath.row == 0) {
		// set up note description cell
		cell = [tableView dequeueReusableCellWithIdentifier:NoteCellIdentifier];
		if (cell == nil) {
			//cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:NoteCellIdentifier] autorelease];
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NoteCellIdentifier] autorelease];
			
			photo = [[[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 21.0, 22.0)] autorelease];
			photo.tag = kIconImageTag;
			//photo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
			[cell.contentView addSubview:photo];
		} else {
			photo = (UIImageView *)[cell.contentView viewWithTag:kIconImageTag];
		}
		
	} else {
		// All Other Cell Setup
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
	}

	
    // Set the text in the cell for the section/row.    
    NSString *cellText = nil;
	CGFloat fontSize;
	BOOL isBold = NO;
   
    switch (indexPath.section) {
        case 0:
			// If the cell is enabled, the accessory view tracks touches and, if tapped, sends the data-source object
			// a tableView:accessoryButtonTappedForRowWithIndexPath: message.
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;

			switch (indexPath.row) {
				case 0:
					// Details
					if ([selectedNote.details length] == 0) {
						cellText = kDefaultNoteLabel;
						fontSize = kTextViewFontSizeDefault;
						isBold = YES;
					} else {
						cellText = selectedNote.details;
						fontSize = kTextViewFontSize;
					}
					// check if there is already a mainLabel in the view before we add a new one
					mainLabel = (UILabel *)[cell.contentView viewWithTag:kMainLabelTag];
					if (mainLabel != nil) {
						[mainLabel removeFromSuperview];
					}
					mainLabel = [cellText RAD_newSizedCellLabelWithSystemFontOfSize:fontSize withBold:isBold];
					mainLabel.tag = kMainLabelTag;
					[cell.contentView addSubview:mainLabel];
					photo.image = [UIImage imageNamed:@"icon_desc.png"];
					break;
				case 1:
					if (selectedNote.group != nil) {
						cellText = selectedNote.group.name;
					} else {
						cellText = kDefaultGroupLabel;
					}
					cell.imageView.image = [UIImage imageNamed:@"icon_group.png"];
					cell.textLabel.text = cellText;
					break;
				default:
					break;
			}
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && self.editing) {
		if (indexPath.row == 0) {
			// note description
			[self editDesc];
		} else if (indexPath.row == 1) {
			// change group
			GroupsViewController *groupsViewController = [[GroupsViewController alloc] initWithStyle:UITableViewStyleGrouped];
			groupsViewController.view.backgroundColor = [UIColor clearColor];
			
			groupsViewController.selectedNote = selectedNote;

			//[groupsViewController setEditing:YES animated:NO];
			[self.navigationController pushViewController:groupsViewController animated:YES];

			[groupsViewController release];
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section != 0) {
		return nil;
	}
	
	// A date formatter for the creation/modified dates.
	static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
	
	// return the created date if its the first section
	return [NSString stringWithFormat:@"Created: %@", [dateFormatter stringFromDate:[selectedNote dateCreated]]];

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 0.0;
	} 
	return self.tableView.sectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// return dynamic size for note description
	if (indexPath.section == 0 && indexPath.row == 0) {
		NSString *label = [selectedNote.details length] == 0 ? kDefaultNoteLabel : selectedNote.details;
		CGFloat fontSize = [selectedNote.details length] == 0 ? kTextViewFontSizeDefault : kTextViewFontSize;

		CGFloat height = [label RAD_textHeightForSystemFontOfSize:fontSize] + 20.0;
		return height;
	}
	// return default
	return 44;
}


#pragma mark -
#pragma mark Editing rows

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    /*
	static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	 */
	/* Disable for now, don't like how this works */
	/*
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				if ([selectedNote.details length] == 0) {
					style = UITableViewCellEditingStyleInsert;
				} else {
					style = UITableViewCellEditingStyleDelete;
				}
				break;
			case 1:
				if (selectedNote.group == nil) {
					style = UITableViewCellEditingStyleInsert;
				} else {
					style = UITableViewCellEditingStyleDelete;
				}
				break;
			default:
				break;
		}
	}
	 */
    return style;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	// For this view we don't want to indent the cells so return NO
	return NO;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.mapView = nil;
	self.tableHeaderView = nil;
	self.tableFooterView = nil;
}

- (void)dealloc {
	self.mapView = nil;
	self.selectedNote = nil;
    [super dealloc];
}

@end

