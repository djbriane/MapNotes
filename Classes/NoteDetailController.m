//
//  NoteDetailController.m
//  MapNotes
//
//  Created by Brian Erickson on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Note.h"
#import "Photo.h"

#import "NoteDetailController.h"
#import "NoteAnnotation.h"
#import "RoundedRectView.h"


@implementation NoteDetailController

@synthesize selectedNote;
@synthesize mapView = _mapView;
@synthesize noteAnnotation;
@synthesize tableHeaderView;
@synthesize tableFooterView;
@synthesize photoButton;
@synthesize nameTextField;

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
	 
	 self.navigationItem.rightBarButtonItem = [self editButtonItem];
	 self.navigationItem.title = selectedNote.title;
	 
	 self.editing = NO; // Initially displays an Edit button and noneditable view
	 
	 // Create and set the table header / footer view.
	 if (tableHeaderView == nil) {
		 [[NSBundle mainBundle] loadNibNamed:@"NoteDetailHeader" owner:self options:nil];
		 self.tableView.tableHeaderView = tableHeaderView;
		 self.tableView.allowsSelectionDuringEditing = YES;
	 }
	 if (tableFooterView == nil) {
		 [[NSBundle mainBundle] loadNibNamed:@"NoteDetailFooter" owner:self options:nil];
		 self.tableView.tableFooterView = tableFooterView;
		 self.tableView.allowsSelectionDuringEditing = NO;
	 }
	 
	 [self updatePhotoInfo];
	 
	 // Add Note to Map (Move this to seperate function)
	 CLLocationCoordinate2D location;
	 location.latitude = [selectedNote.geoLatitude doubleValue];
	 location.longitude = [selectedNote.geoLongitude doubleValue];

	 self.noteAnnotation = [NoteAnnotation annotationWithCoordinate:location];
	 
	 MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
	 region.center = location;
	 region.span.longitudeDelta = 0.005f;
	 region.span.latitudeDelta = 0.005f;
	 
	 [self.mapView setRegion:region animated:NO];
	 [self.mapView addAnnotation:self.noteAnnotation];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	nameTextField.text = [selectedNote title];
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
		nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    }
    else {
        // save the changes if needed and change view to noneditable
		nameTextField.borderStyle = UITextBorderStyleNone;
    }
	
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	
	if (textField == nameTextField) {
		selectedNote.title = nameTextField.text;
		self.navigationItem.title = selectedNote.title;
	}
	return YES;
}	

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Photo Acquisition Methods
- (IBAction)editPhoto {
	/*
	 Update the photo in response to a tap on the photo button.
	 * If the event already has a photo, delete it
	 * If the event doesn't have a photo, show an image picker to allow the user to choose one
	 */
	
	if (selectedNote.photo) {
		/*
		 Delete the Photo object and dispose of the thumbnail.
		 Because the relationship was modeled in both directions, the event's relationship to the photo will automatically be set to nil.
		 */
		NSManagedObjectContext *context = selectedNote.managedObjectContext;
		[context deleteObject:selectedNote.photo];
		selectedNote.thumbnail = nil;
		
		// Commit the change.
		NSError *error;
		if (![selectedNote.managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
		}
		
		// Update the user interface appropriately.
		[self updatePhotoInfo];
	}
	else {
		// Let the user choose a new photo.
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.delegate = self;
		[self presentModalViewController:imagePicker animated:YES];
		[imagePicker release];
	}
}

- (void)updatePhotoInfo {
	
	// Synchronize the photo image view and the text on the photo button with the event's photo.
	UIImage *image = selectedNote.thumbnail;
	
	if (image) {
		[photoButton setImage:image forState:UIControlStateNormal];
	}
	else {
		image = [UIImage imageNamed:@"img_photo-add.png"];
		[photoButton setImage:image forState:UIControlStateNormal];
	}
}

#pragma mark -
#pragma mark Image Picker Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo {
	
	// Create a new photo object and associate it with the event.
	Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:selectedNote.managedObjectContext];
	selectedNote.photo = photo;
	
	// Set the image for the photo object.
	photo.image = selectedImage;
	
	// Create a thumbnail version of the image for the event object.
	CGSize size = selectedImage.size;
	CGFloat ratio = 0;
	if (size.width > size.height) {
		ratio = 44.0 / size.width;
	}
	else {
		ratio = 44.0 / size.height;
	}
	CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
	
	UIGraphicsBeginImageContext(rect.size);
	[selectedImage drawInRect:rect];
	selectedNote.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	
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
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	/*
	 The number of rows varies by section.
	 */
    NSInteger rows = 0;
    switch (section) {
        case 0:
			rows = 2;
			break;
        case 1:
		case 2:
            // For the action 'buttons' there is just one row
            rows = 0;
            break;
        default:
            break;
    }
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	// A date formatter for the creation/modified dates.
    static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
	
	static NSNumberFormatter *numberFormatter = nil;
	if (numberFormatter == nil) {
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setMaximumFractionDigits:3];
	}

	NSString *geoString = [NSString stringWithFormat:@"%@, %@ : %@",
						[numberFormatter stringFromNumber:[selectedNote geoLatitude]],
						[numberFormatter stringFromNumber:[selectedNote geoLongitude]],
						[numberFormatter stringFromNumber:[selectedNote geoAccuracy]]];
	
    // Set the text in the cell for the section/row.
    
    NSString *cellText = nil;
   
    switch (indexPath.section) {
        case 0:
			// If the cell is enabled, the accessory view tracks touches and, if tapped, sends the data-source object
			// a tableView:accessoryButtonTappedForRowWithIndexPath: message.
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			switch (indexPath.row) {
				case 0:
					// Location
					cellText = geoString;
					break;
				case 1:
					// Created Date
					cellText = [dateFormatter stringFromDate:[selectedNote dateCreated]];
					break;
				default:
					break;
			}
            break;
        case 1:
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cellText = NSLocalizedString(@"Move Folder", @"Move to new folder");
            break;
        case 2:
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cellText = NSLocalizedString(@"Share", @"Share note with friends");
            break;
        default:
            break;
    }
    
    cell.textLabel.text = cellText;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 0.0;
	} 
	return self.tableView.sectionHeaderHeight;
}


#pragma mark -
#pragma mark Editing rows

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    
	static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
    switch (indexPath.section) {
		case 1:
		case 2:
			cell.hidden = YES;
			break;
		default:
			break;
	}
    return style;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	// For this view we don't want to indent the cells so return NO
	return NO;
}

- (void)dealloc {
	self.selectedNote = nil;
    [super dealloc];
}


@end

