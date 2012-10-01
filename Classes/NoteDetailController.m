//
//  NoteDetailController.m
//  MapNotes
//
//  Created by Brian Erickson on 7/26/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import "Note.h"
#import "Group.h"
#import "Photo.h"

#import "NoteDetailController.h"
#import "MapNotesAppDelegate.h"
#import "NotePhotoViewController.h"
#import "NoteAnnotation.h"
#import "RoundedRectView.h"
#import "ImageManipulator.h"
#import "GroupsViewController.h"
#import "StringHelper.h"

@implementation NoteDetailController

@synthesize selectedNote;

@synthesize mapView = _mapView;
@synthesize noteAnnotation;
@synthesize tableHeaderView, tableFooterView, tableShareView;
@synthesize photoEditButton, photoButton, nameTextField, photoBorderImage;
@synthesize deleteButton, emailButton, shareButton, infoLabelButton;

- (void)dealloc {
	self.mapView = nil;
	[noteAnnotation release];
	//[selectedNote release];

	[photoEditButton release];
	[photoButton release];
	[nameTextField release];
	[photoBorderImage release];
	[tableHeaderView release];
	
	[deleteButton release];
	[emailButton release];
	[shareButton release];
	[infoLabelButton release];
	
	[tableShareView release];
	[tableFooterView release];

    [super dealloc];
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.mapView = nil;
	self.noteAnnotation = nil;
	//self.selectedNote = nil;
	
	self.photoEditButton = nil;
	self.photoButton = nil;
	self.nameTextField = nil;
	self.photoBorderImage = nil;
	self.tableHeaderView = nil;
	
	self.deleteButton = nil;
	self.emailButton = nil;
	self.shareButton = nil;
	self.infoLabelButton = nil;
	
	self.tableShareView = nil;
	self.tableFooterView = nil;
}

- (void)didReceiveMemoryWarning {
	NSLog(@"NoteDetailController - Received Memory Warning");
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	/*
	 self.mapView = nil;
	 self.photoEditButton = nil;
	 self.photoButton = nil;
	 self.deleteButton = nil;
	 self.infoLabelButton = nil;
	 */
	self.tableHeaderView = nil;
	self.tableShareView = nil;
	self.tableFooterView = nil;
}


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableView.backgroundColor = [UIColor clearColor];

	[self loadTableHeaderAndFooterViews];
	
	//self.editing = NO; // Initially displays an Edit button and noneditable view
	self.tableView.allowsSelectionDuringEditing = YES;
	self.tableView.sectionHeaderHeight = 5.0;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
	self.navigationItem.title = @"Note Detail";
	
	if (![MFMailComposeViewController canSendMail]) {
		[self.emailButton setEnabled:NO];
	}

	if (UIAppDelegate.infoDisplay == 0) {
		[self setCreatedDateLabel];
	} else {
		[self setLocationInfoLabel];
	}
	
	[self initializeMap];
	[self.tableView reloadData];
	[self updatePhotoInfo];
}

- (void)loadTableHeaderAndFooterViews {
	// Create and set the table header / footer view.
	/*
	if (tableHeaderView == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"NoteDetailHeader" owner:self options:nil];
		self.tableView.tableHeaderView = tableHeaderView;
	} */
	
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 290)];
	self.tableView.tableFooterView = footerView;
	[footerView release];
	
	if (tableFooterView == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"NoteDetailFooter" owner:self options:nil];
		tableFooterView.frame = CGRectMake(0, 59, 320, 228);
	}
	[self.tableView.tableFooterView addSubview:tableFooterView];
	
	if (tableShareView == nil) {	
		//[[NSBundle mainBundle] loadNibNamed:@"NoteDetailShare" owner:self options:nil];
		[[NSBundle mainBundle] loadNibNamed:@"NoteDetailEmail" owner:self options:nil];
		[self.tableView.tableFooterView addSubview:tableShareView];
	}
	[self.tableView.tableFooterView addSubview:tableShareView];
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
	NSArray *visibleCells;
	UITableViewCell *currentCell;
	//UIImageView *detailsDescIcon;
	//UILabel *detailsDescLabel;
    [super setEditing:editing animated:animated];
	[self.navigationItem setHidesBackButton:editing animated:YES];
	
    if (editing == YES){		
        // change view to an editable view
		[nameTextField setEnabled:YES];
		
		// set state for photo button
		[photoButton setEnabled:YES];
		if (selectedNote.thumbnail) {
			[photoEditButton setHidden:NO];
		} else {
			[photoEditButton setHidden:YES];
		}

		//[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationDelegate:self];
		//[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:deleteButton cache:YES];
		[tableShareView setAlpha:0.0];
		tableFooterView.frame = CGRectMake(0, 0, 320, 228);
		[deleteButton setAlpha:1.0];
		[UIView commitAnimations];
		deleteButton.hidden = NO;
		[deleteButton setEnabled:YES];
		[tableShareView removeFromSuperview];

	}
    else {
        // save the changes if needed and change view to noneditable
		[nameTextField setEnabled:NO];
		
		// set state for photo button
		if (selectedNote.thumbnail) {
			[photoButton setEnabled:YES];
		} else {
			[photoButton setEnabled:NO];
		}
		[photoEditButton setHidden:YES];
		
		[self.tableView.tableFooterView addSubview:tableShareView];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationDelegate:self];
		//[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:deleteButton cache:YES];
		[tableShareView setAlpha:1.0];
		tableFooterView.frame = CGRectMake(0, 59, 320, 172);
		[deleteButton setAlpha:0.0];
		[UIView commitAnimations];
		[deleteButton setEnabled:NO];
    }
	
	// Adjust note desc label width
	visibleCells = [self.tableView visibleCells];
	if ([selectedNote.details length] != 0) {
		currentCell = [visibleCells objectAtIndex:0];
		NSArray *rowToReload = [NSArray arrayWithObject:[self.tableView indexPathForCell:currentCell]];
		[self.tableView reloadRowsAtIndexPaths:rowToReload withRowAnimation:UITableViewRowAnimationFade];  
	}
	
	// Update photo display accordingly
	//[self updatePhotoInfo];
	
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

#pragma mark -
#pragma mark Interface Methods
- (IBAction)editTitle:(id)sender {
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

- (IBAction)deleteNote:(id)sender {
	if (deleteButton.enabled) {
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:@"Are you sure?"
									  delegate:self
									  cancelButtonTitle:@"Cancel"
									  destructiveButtonTitle:kDeleteNoteButtonText
									  otherButtonTitles:nil];
				
		//actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		[actionSheet showInView:self.view];
		[actionSheet release];		
	}
}

- (IBAction)shareNote:(id)sender {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"What the Tweet?"
															message:@"Send your Note+Photo+Location to Twitter Coming Soon!"
														   delegate:nil
												  cancelButtonTitle:@"Okay"
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
}

- (IBAction)rotateInfoLabel:(id)sender {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:self];
	[infoLabelButton setAlpha:0.0];
	[UIView commitAnimations];
	
	if (UIAppDelegate.infoDisplay == 0) {
		[self setLocationInfoLabel];
		UIAppDelegate.infoDisplay = 1;
	} else {
		[self setCreatedDateLabel];
		UIAppDelegate.infoDisplay = 0;
	}
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:self];
	[infoLabelButton setAlpha:1.0];
	[UIView commitAnimations];
}

- (void)setCreatedDateLabel {
	NSString *createdDate;
	
	// A date formatter for the creation/modified dates.
	static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
		
	// return the created date if its the first section
	createdDate = [NSString stringWithFormat:@"Created: %@", [dateFormatter stringFromDate:[selectedNote dateCreated]]];
	[infoLabelButton setTitle:createdDate forState:UIControlStateNormal];
	infoLabelButton.titleLabel.font = [UIFont systemFontOfSize: 15];
}
	 
- (void)setLocationInfoLabel {
	NSString *locationInfo;
	CLLocation *noteLocation = [selectedNote location];
	
	// return the created date if its the first section
	// convert altitude to feet
	if (noteLocation.verticalAccuracy > 0) {
		CGFloat altitude = noteLocation.altitude * 3.2808399;
		locationInfo = [NSString stringWithFormat:@"Loc: %1.2f, %1.2f Acc: %1.0fm Alt: %1.0fft", noteLocation.coordinate.latitude, noteLocation.coordinate.longitude, noteLocation.horizontalAccuracy, altitude];
	} else {
		locationInfo = [NSString stringWithFormat:@"Loc: %1.2f, %1.2f Accuracy: %1.0fm", noteLocation.coordinate.latitude, noteLocation.coordinate.longitude, noteLocation.horizontalAccuracy];
	}
	[infoLabelButton setTitle:locationInfo forState:UIControlStateNormal];
	infoLabelButton.titleLabel.font = [UIFont systemFontOfSize: 13];

}	 

- (void)deleteExistingNote {
	NSManagedObjectContext *context = selectedNote.managedObjectContext;

	[context deleteObject:selectedNote];		
	
	// Save the context.
	NSError *error;
	if (![context save:&error]) {
		// Handle the error...
		//NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
	}
	
	// return to notes view
	[self.navigationController popViewControllerAnimated:YES];
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
	//[self.tableView setEditing:YES animated:NO];
	[self.navigationController popViewControllerAnimated:YES];
	//[self.tableView reloadData];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

}

#pragma mark -
#pragma mark Photo Acquisition Methods
- (IBAction)editPhoto:(id)sender {
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
			actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:kDeletePhotoButtonText];
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
	/*
	if (image && self.editing) {
		[photoEditButton setHidden:NO];
	} else {
		[photoEditButton setHidden:YES];
	}
	
	[photoBorderImage setHidden:YES];
	 */
	if (image) {
		[photoBorderImage setHidden:NO];
		[photoButton setImage:image forState:UIControlStateNormal];
		if (self.editing) {
			[photoEditButton setHidden:NO];
		} else {
			[photoEditButton setHidden:YES];
		}
	} else {
		[photoBorderImage setHidden:YES];
		[photoEditButton setHidden:YES];
		[photoButton setImage:[UIImage imageNamed:@"img_photo-add.png"] forState:UIControlStateNormal];
		[photoButton setImage:[UIImage imageNamed:@"img_no-photo.png"] forState:UIControlStateDisabled];
		//image = [UIImage imageNamed:@"img_no-photo.png"];
		//[photoButton setImage:image forState:UIControlStateNormal];
		//[photoButton setEnabled:NO];
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
			//NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
		}
		[self updatePhotoInfo];
	}
}

- (void)initializeMap {
	// Add Note to Map
	self.noteAnnotation = [NoteAnnotation annotationWithNote:selectedNote];
	
	MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
	region.center = selectedNote.location.coordinate;
	region.span.longitudeDelta = 0.004f;
	region.span.latitudeDelta = 0.004f;
	
	[self.mapView setRegion:region animated:NO];
	[self.mapView addAnnotation:self.noteAnnotation];
	// Done adding Note to map
	
	NSArray *annotations = [self.mapView annotations];
	if ([annotations objectAtIndex:0] != nil) {
		MKAnnotationView *anAnnotation = [self.mapView viewForAnnotation:[annotations objectAtIndex:0]];
		//UIImage *pinImage = (UIImage *)[ autorelease];
		if (selectedNote.group != nil) {
			[anAnnotation setImage:[selectedNote.group getPinImage]];	
		} else {
			[anAnnotation setImage:[UIImage imageNamed:@"node_orange.png"]];
		}
	}
	
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
	else if ([actionSheet buttonTitleAtIndex:buttonIndex] == kDeleteNoteButtonText) {
		[self deleteExistingNote];
	}
}

#pragma mark -
#pragma mark Image Picker Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker 
		didFinishPickingImage:(UIImage *)selectedImage 
				  editingInfo:(NSDictionary *)editingInfo {

	[self dismissModalViewControllerAnimated:YES];
	
	// Delete Existing Photo
	[self deleteExistingPhoto];
	
	// Create a new photo object and associate it with the event.
	Photo *photo = (Photo *)[NSEntityDescription insertNewObjectForEntityForName:@"Photo" 
														   inManagedObjectContext:selectedNote.managedObjectContext];
	
	
	// Save the image to the users album
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil);
	}
	
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
		//NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
	}
	
	// Update the user interface appropriately.
	[self updatePhotoInfo];
	
	//[self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	// The user canceled -- simply dismiss the image picker.
	[self dismissModalViewControllerAnimated:YES];

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"CellIdentifier";
	static NSString *NoteCellIdentifier = @"NoteCellIdentifier";
	UITableViewCell *cell;
	UILabel *mainLabel;
    UIImageView *photo;
	
	if (indexPath.section == 0 && indexPath.row == 0 && !tableView.editing && [selectedNote.details length] != 0 ) {
		// set up note description cell
		cell = [tableView dequeueReusableCellWithIdentifier:NoteCellIdentifier];
		if (cell == nil) {
			//cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:NoteCellIdentifier] autorelease];
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NoteCellIdentifier] autorelease];
			
			photo = [[[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 21.0, 22.0)] autorelease];
			photo.tag = kIconImageTag;
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
   
    switch (indexPath.section) {
        case 0:
			// If the cell is enabled, the accessory view tracks touches and, if tapped, sends the data-source object
			// a tableView:accessoryButtonTappedForRowWithIndexPath: message.
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;

			switch (indexPath.row) {
				case 0:
					// Details
					if (!tableView.editing && [selectedNote.details length] != 0) {
						cellText = selectedNote.details;
						fontSize = kTextViewFontSize;
						// check if there is already a mainLabel in the view before we add a new one
						mainLabel = (UILabel *)[cell.contentView viewWithTag:kMainLabelTag];
						if (mainLabel != nil) {
							[mainLabel removeFromSuperview];
						}
						mainLabel = [cellText RAD_newSizedCellLabelWithSystemFontOfSize:fontSize];
						mainLabel.tag = kMainLabelTag;
						[cell.contentView addSubview:mainLabel];
						[mainLabel release];
						photo.image = [UIImage imageNamed:@"icon_desc.png"];
						photo.highlightedImage = [UIImage imageNamed:@"icon_desc-high.png"];
						break;
					} else if ([selectedNote.details length] != 0) {
						cellText = selectedNote.details;
					} else {
						cellText = kDefaultNoteLabel;
					}
					cell.imageView.image = [UIImage imageNamed:@"icon_desc.png"];
					cell.imageView.highlightedImage = [UIImage imageNamed:@"icon_desc-high.png"];
					cell.textLabel.textColor = [UIColor colorWithRed:(51.0/255.0) green:(51.0/255.0) blue:(51.0/255.0) alpha:1.0];
					cell.textLabel.text = cellText;	
					break;
				case 1:
					if (selectedNote.group != nil) {
						cellText = selectedNote.group.name;
					} else {
						cellText = kDefaultGroupLabel;
					}
					cell.imageView.image = [UIImage imageNamed:@"icon_group.png"];
					cell.imageView.highlightedImage = [UIImage imageNamed:@"icon_group-high.png"];
					cell.textLabel.text = cellText;
					cell.textLabel.textColor = [UIColor colorWithRed:(51.0/255.0) green:(51.0/255.0) blue:(51.0/255.0) alpha:1.0];
					break;
				default:
					break;
			}
            break;
		case 1: {
			// set up share cell
			UIImageView *bgView;
			bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_share.png"]];
			cell.backgroundView = bgView;
			[bgView release];
			bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_share-high.png"]];			
			cell.selectedBackgroundView = bgView;
			[bgView release];
			
			//cell.textLabel.text = @"Email";
			cell.contentView.alpha = 0.0;
			break; }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self didSelectInsertRowAtIndexPath:indexPath];
}

- (void)didSelectInsertRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			// note description
			[self editDesc];
		} else if (indexPath.row == 1) {
			// change group
			GroupsViewController *groupsViewController = [[GroupsViewController alloc] initWithStyle:UITableViewStyleGrouped];
			groupsViewController.view.backgroundColor = [UIColor clearColor];
			groupsViewController.selectedNote = selectedNote;
			
			[self.navigationController pushViewController:groupsViewController animated:YES];
			[groupsViewController release];
		}
		//[self setEditing:YES animated:NO];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		if (tableHeaderView == nil) {
			// tableHeaderView
			UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 89)];
			tableHeaderView = headerView;

			// photo button
			UIButton *setPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(9, 15, 64, 64)];
			[setPhotoButton setImage:[UIImage imageNamed:@"img_no-photo.png"] forState:UIControlStateDisabled];
			[setPhotoButton setImage:[UIImage imageNamed:@"img_photo-add.png"] forState:UIControlStateNormal];
			[setPhotoButton addTarget:self action:@selector(editPhoto:) forControlEvents:UIControlEventTouchUpInside];
			photoButton = setPhotoButton;
			[headerView addSubview:setPhotoButton];
			
			// photo border
			UIImageView *photoBorder = [[UIImageView alloc] initWithFrame:CGRectMake(9, 15, 64, 64)];
			photoBorder.image = [UIImage imageNamed:@"img_photo-border.png"];
			[photoBorder setHidden:YES];
			photoBorderImage = photoBorder;
			[headerView addSubview:photoBorder];
			
			// edit overlay
			UIButton *editOverlay = [[UIButton alloc] initWithFrame:CGRectMake(9, 15, 64, 64)];
			[editOverlay setImage:[UIImage imageNamed:@"img_photo-edit.png"] forState:UIControlStateNormal];
			[editOverlay addTarget:self action:@selector(editPhoto:) forControlEvents:UIControlEventTouchUpInside];
			[editOverlay setHidden:YES];

			photoEditButton = editOverlay;
			[headerView addSubview:editOverlay];
			
			// title button
			UIButton *titleButton = [[UIButton alloc] initWithFrame:CGRectMake(90, 15, 221, 64)];
			[titleButton setBackgroundImage:[UIImage imageNamed:@"img_title-bkgnd.png"] forState:UIControlStateNormal];
			[titleButton setBackgroundImage:[UIImage imageNamed:@"img_title-bkgnd-blue.png"] forState:UIControlStateHighlighted];
			[titleButton setBackgroundImage:[UIImage imageNamed:@"img_blank.png"] forState:UIControlStateDisabled];
			[titleButton addTarget:self action:@selector(editTitle:) forControlEvents:UIControlEventTouchUpInside];
			titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
			titleButton.contentEdgeInsets = UIEdgeInsetsMake(3.0, 10.0, 3.0, 20.0);
			titleButton.titleLabel.font = [UIFont boldSystemFontOfSize: 18];
			titleButton.titleLabel.textAlignment = UITextAlignmentLeft;
			titleButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
			
			nameTextField = titleButton;
			NSLog(@"Note Title Label: %@", titleButton.titleLabel.text);
			[headerView addSubview:titleButton];
		}
		
		if ([selectedNote.title length] != 0) {
			[nameTextField setTitle:[selectedNote title] forState:UIControlStateNormal];
			UIColor *myDarkGray = [UIColor colorWithRed:(45.0/255.0) green:(48.0/255.0) blue:(51.0/255.0) alpha:1.0];
			[nameTextField setTitleColor:myDarkGray forState:UIControlStateDisabled];
			[nameTextField setTitleColor:myDarkGray forState:UIControlStateNormal];
			//[nameTextField setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		} else {
			[nameTextField setTitle:@"Add Title" forState:UIControlStateNormal];
			[nameTextField setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
			[nameTextField setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
		}
		
		return tableHeaderView;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 94.0;
	} 
	return self.tableView.sectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// return dynamic size for note description
	if (indexPath.section == 0 && indexPath.row == 0 && !tableView.editing && [selectedNote.details length] != 0) {
		NSString *label = selectedNote.details;
		CGFloat fontSize = kTextViewFontSize;

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
    return style;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	// For this view we don't want to indent the cells so return NO
	if (indexPath.section == 0) {
		return YES;
	}
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Remove the value in the field that was clicked
		NSManagedObjectContext *context = UIAppDelegate.managedObjectContext;
		
		if (indexPath.section == 0) {
			switch (indexPath.row) {
				case 0:
					[selectedNote setDetails:nil];
					break;
				case 1:
					[selectedNote setGroup:nil];
					break;
				default:
					break;
			}
		}
		
		// Save the context.
		NSError *error;
		if (![context save:&error]) {
			// Handle the error...
			//NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
		}
		// reload the row that was deleted
		[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		[self didSelectInsertRowAtIndexPath:indexPath];
	}
}

#pragma mark -
#pragma mark MKMapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKAnnotationView *view = nil;

	view = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
	
	if(nil == view) {
		view = [[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"identifier"] autorelease];
	}

	if (selectedNote.group != nil) {
		[view setImage:[selectedNote.group getPinImage]];	
	} else {
		[view setImage:[UIImage imageNamed:@"node_orange.png"]];
	} 
	CGPoint offsetPixels;
	offsetPixels.x = 0;
	offsetPixels.y = -16;
	view.centerOffset = offsetPixels;
	
	[view setCanShowCallout:NO];
	
	return view;
}

#pragma mark -
#pragma mark Mail Delegate Methods
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {	
	if (result == MFMailComposeResultFailed) {
		// Handle the error 
		NSString *errorMsg;
		if (error == MFMailComposeErrorCodeSaveFailed) {
			errorMsg = @"Failed to Save Mail Message.";
		} else {
			errorMsg = @"Failed to Send Mail Message.";
		}
		UIAlertView *mailFailedAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[mailFailedAlert show];
		[mailFailedAlert release];
	}
	// dismiss the mail dialog
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)emailNote:(id)sender {
	[NSTimer scheduledTimerWithTimeInterval:.01 target:self 
								   selector:@selector(showEmailView) 
								   userInfo:nil 
									repeats:NO];
}

- (void)showEmailView {
	[self showComposeEmailViewWithNote:selectedNote];
}


- (void)showComposeEmailViewWithNote:(Note *)note {
	NSString *noteableSig = @"Sent from Noteable for iPhone\r\nhttp://appwrkshp.com/noteable";
	NSString *mapInfo;
	NSString *mapLink;
	NSString *mapLinkEscaped;
	NSString *bodyMessage;
	
	MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
	mailComposeViewController.navigationBar.tintColor = [UIColor colorWithRed:(129.0/255.0) green:(137.0/255.0) blue:(149.0/255.0) alpha:1.0];
	mailComposeViewController.mailComposeDelegate = self;
	[mailComposeViewController setSubject:note.title];
	
	if ([note.title length] == 0 && [note.details length] == 0) {
		mapInfo = [NSString stringWithFormat:@"(Location from Noteable)"];
	} else if ([note.details length] == 0) {
		mapInfo = [NSString stringWithFormat:@"(%@)", note.title];
	} else {
		if ([note.details length] > 25) {
			mapInfo = [NSString stringWithFormat:@"(%@ - %@)", note.title, [note.details substringToIndex:25]];		
		} else {
			mapInfo = [NSString stringWithFormat:@"(%@ - %@)", note.title, note.details];
		}
	}
	mapLink = [NSString stringWithFormat:@"http://maps.google.com/?q=%1.6f,%1.6f %@&ll=%1.6f,%1.6f", 
			   note.location.coordinate.latitude, 
			   note.location.coordinate.longitude, 
			   mapInfo, 
			   note.location.coordinate.latitude, 
			   note.location.coordinate.longitude];
	
	mapLinkEscaped = [mapLink stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	
	if ([note.details length] != 0) {
		bodyMessage = [NSString stringWithFormat:@"%@\r\n\r\n%@\r\n\r\n%@", note.details, mapLinkEscaped, noteableSig];
	} else {
		bodyMessage = [NSString stringWithFormat:@"%@\r\n\r\n%@", mapLinkEscaped, noteableSig];;
	}
	[mailComposeViewController setMessageBody:bodyMessage isHTML:NO];
	
	if (note.photo != nil) {
		NSData *imageData = UIImageJPEGRepresentation([note.photo valueForKey:@"image"], 1);
		[mailComposeViewController addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"noteable_photo.jpg"];
	}	
	[self presentModalViewController:mailComposeViewController animated:YES];
}

@end

