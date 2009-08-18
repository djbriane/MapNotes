//
//  QuickAddViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 8/5/09.
//  Copyright 2009 Local Matters, Inc.. All rights reserved.
//

#import "QuickAddViewController.h"
#import "RootViewController.h"
#import "MapNotesAppDelegate.h"
#import "ImageManipulator.h"
#import "Note.h"

@implementation QuickAddViewController

@synthesize delegate;
@synthesize mapView = _mapView;
@synthesize locationManager, locationTimer, managedObjectContext;
@synthesize addTextNoteButton, addPhotoNoteButton, updateLocationButton, updateLocationActivity;
@synthesize locationInfoLabel;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Get a handle on the location manager from the app delegate
	self.locationManager = ((MapNotesAppDelegate *)[UIApplication sharedApplication].delegate).locationManager;
	self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self 
														selector:@selector(checkAndUpdateLocation) 
														userInfo:nil 
														 repeats:YES];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	//[UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (self.locationTimer != nil) {
		[self.locationTimer invalidate];
	}
	//[UIApplication sharedApplication].statusBarHidden = NO;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.mapView = nil;
	self.locationManager = nil;
	self.locationTimer = nil;
	
	self.locationInfoLabel = nil;
	self.addTextNoteButton = nil;
	self.addPhotoNoteButton = nil;
	self.updateLocationButton = nil;
	self.updateLocationActivity = nil;
	
}

- (void)checkAndUpdateLocation {	
	// check if we have a good location
	if (nil != self.locationManager.location) {
		MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
		region.center = locationManager.location.coordinate;
		region.span.longitudeDelta = 0.02f;
		region.span.latitudeDelta = 0.02f;

		[self.mapView setRegion:region animated:NO];
		self.mapView.hidden = NO;

		// Update UI to reflect we have a good location
		[self.updateLocationActivity stopAnimating];
		self.locationInfoLabel.text = [NSString stringWithFormat:@"Accuracy: %4.0fm", locationManager.location.horizontalAccuracy];
		self.updateLocationButton.enabled = YES;
		self.addTextNoteButton.enabled = YES;
		self.addPhotoNoteButton.enabled = YES;
		[self.locationTimer invalidate];
	} else {
		[self.updateLocationActivity startAnimating];
		self.updateLocationButton.enabled = NO;
		self.addTextNoteButton.enabled = NO;
		self.addPhotoNoteButton.enabled = NO;
	}
}

- (Note *)createNewNote {
	if (!self.locationManager.location) {
		return nil;
	}
	
	// Create and configure a new instance of the Event entity
	Note *note = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note"
													   inManagedObjectContext:self.managedObjectContext];
	
	[note setLocation:self.locationManager.location];
	//[note setGeoLatitude:[NSNumber numberWithDouble:self.locationManager.location.coordinate.latitude]];
	//[note setGeoLongitude:[NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude]];
	//[note setGeoAccuracy:[NSNumber numberWithDouble:self.locationManager.location.horizontalAccuracy]];
	
	[note setDateCreated:[NSDate date]];

	return note;
}

- (IBAction)addTextNote:(id)sender {
	Note *note = [self createNewNote];
	//[note setTitle:@"New Note"];
	
	/*
	NSError *error;
	if (![self.managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
	}
	*/
	
	
	NoteTitleViewController *titleController = [[NoteTitleViewController alloc] initWithNibName:@"NoteTitle" bundle:nil];
    titleController.delegate = self;
	
	titleController.note = note;
	
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:titleController];
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
    [titleController release];
}

- (IBAction)addPhotoNote:(id)sender {
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
	
	// Cancel Button
	actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
	
	//actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (IBAction)viewNotes:(id)sender {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)updateLocation:(id)sender {
	[self.locationManager startUpdatingLocation];
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
}

#pragma mark -
#pragma mark Image Picker Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker 
		didFinishPickingImage:(UIImage *)selectedImage 
				  editingInfo:(NSDictionary *)editingInfo {
	
	// Create a new note
	Note *note = [self createNewNote];
	
	// Create a new photo object and associate it with the event.
	NSManagedObject *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" 
														   inManagedObjectContext:note.managedObjectContext];
	
	
	// Scale the image to a manageable size and rotate it properly to account for camera
	UIImage *image = [[ImageManipulator scaleAndRotateImage:selectedImage] retain];
	note.photo = photo;
	
	// Set the image for the image managed object.
	[photo setValue:image forKey:@"image"];
	
	// Generate and set a thumbnail for the note
	UIImage *thumbnail = [[ImageManipulator generatePhotoThumbnail:image] retain];
	note.thumbnail = thumbnail;
	[thumbnail release];
	[image release];
	
	// Commit the change.
	NSError *error;
	if (![note.managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"%@:%s Error saving context: %@", [self class], _cmd, [error localizedDescription]);
	}
	
    if ([self.delegate respondsToSelector:@selector (quickAddViewController:showNewNote:)]) {
		[self.delegate quickAddViewController:self showNewNote:note];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	// The user canceled -- simply dismiss the image picker.
	[self dismissModalViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	// Customize the title of the nav bar for camera capture
	//navigationController.navigationBar.topItem.title = @"Custom Picker Title";
    //navigationController.navigationBar.topItem.prompt = @"Custom Picker Prompt";
}

#pragma mark -
#pragma mark Note Title View Controller Methods

- (void)noteTitleViewController:(NoteTitleViewController *)controller 
					didSetTitle:(Note *)note
						didSave:(BOOL)didSave {

	if (didSave == NO) {
		[note.managedObjectContext deleteObject:note];
	}

	NSError *error = nil;
	if (![note.managedObjectContext save:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	if (didSave) {
		if ([self.delegate respondsToSelector:@selector (quickAddViewController:showNewNote:)]) {
			[self.delegate quickAddViewController:self showNewNote:note];
		}
	} else {
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void)dealloc {
	self.mapView = nil;
	[managedObjectContext release];
	[locationManager release];
	[locationTimer release];

	[locationInfoLabel release];
	[addTextNoteButton release];
	[addPhotoNoteButton release];
	[updateLocationButton release];
    [super dealloc];
}


@end
