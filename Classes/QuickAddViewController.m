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
#import "LocationController.h"
#import "Note.h"

@implementation QuickAddViewController

@synthesize delegate;
@synthesize mapView = _mapView;
@synthesize locationTimer, managedObjectContext;
@synthesize addTextNoteButton, addPhotoNoteButton, viewNotesButton, updateLocationButton, updateLocationActivity;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[UIApplication sharedApplication].statusBarHidden = YES;

	// update location
	[self startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (self.locationTimer != nil) {
		[self.locationTimer invalidate];
	}
	[[LocationController sharedInstance] stop];
	//[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
	//[UIApplication sharedApplication].statusBarHidden = NO;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)checkAndUpdateLocation {
	// check if we have a good location
	if (![[LocationController sharedInstance] locationKnown]) {
		[self.updateLocationActivity startAnimating];
		self.updateLocationButton.enabled = NO;
		self.addTextNoteButton.enabled = NO;
		self.addPhotoNoteButton.enabled = NO;
		return;
	} else {
		MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
		CLLocation *location = [[LocationController sharedInstance] currentLocation];
		region.center = location.coordinate;
		region.span.longitudeDelta = 0.02f;
		region.span.latitudeDelta = 0.02f;

		[self.mapView setRegion:region animated:NO];
		self.mapView.hidden = NO;
		
		// Update UI to reflect we have a good location
		[self.updateLocationActivity stopAnimating];
		self.updateLocationButton.enabled = YES;
		self.addTextNoteButton.enabled = YES;
		self.addPhotoNoteButton.enabled = YES;
		
		[[LocationController sharedInstance] stop];
		[self.locationTimer invalidate];
	} 
}


- (void)startUpdatingLocation {
	// invalidate any existing timer
	[self.locationTimer invalidate];
	
	// disable the location button and start animating
	self.updateLocationButton.enabled = NO;
	[self.updateLocationActivity startAnimating];
	
	// tell the location controller to start updating and set up a timer 
	[[LocationController sharedInstance] start];
	self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self 
														selector:@selector(checkAndUpdateLocation) 
														userInfo:nil 
														 repeats:YES];
}

- (Note *)createNewNote {
	CLLocation *myLocation = [[LocationController sharedInstance] currentLocation];
	if (!myLocation) {
		return nil;
	}
	
	// Create and configure a new instance of the Event entity
	Note *note = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note"
													   inManagedObjectContext:self.managedObjectContext];
	
	[note setLocation:myLocation];
	[note setDateCreated:[NSDate date]];

	return note;
}

- (IBAction)addTextNote:(id)sender {
	Note *note = [self createNewNote];
	if (!note) {
		// TODO: Should throw an error here.
		return;
	}

	NoteTitleViewController *titleController = [[NoteTitleViewController alloc] initWithNibName:@"EditTitle" bundle:nil];
    titleController.delegate = self;
	titleController.note = note;
	
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:titleController];
	navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.4902 green:0.5098 blue:.5294 alpha:1.0];
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
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)updateLocation:(id)sender {
	[self startUpdatingLocation];
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
	if (!note) {
		// TODO: Throw an error here
		return;
	}
	
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

#pragma mark -
#pragma mark Map View Delegate Methods
/*
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
	NSLog(@"Start Loading Map");
	//self.viewNotesButton.enabled = NO;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
	NSLog(@"Finish Loading Map");
	//self.viewNotesButton.enabled = YES;
}
*/
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
	NSLog(@"Map View Fail with error %@, %@", error, [error userInfo]);
}

- (void)mapView:(MKMapView *)mapView // there is a bug in the map view in beta 5
// that makes this method required, the map view is nto checking if we 
// respond before invoking so it blows up if we don't
didSelectSearchResult:(id)result
  userInitiated:(BOOL)userInitiated {
}

#pragma mark -
#pragma mark Memory / Dealloc Methods
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	// Setting mapView to nil causes crashes when the uses dismisses the view 
	//self.mapView.delegate = nil;
	//self.mapView = nil;
	
	self.locationTimer = nil;
	
	self.addTextNoteButton = nil;
	self.addPhotoNoteButton = nil;
	self.viewNotesButton = nil;
	self.updateLocationButton = nil;
	self.updateLocationActivity = nil;
	
}

- (void)dealloc {
	// Setting mapView to nil causes crashes when the uses dismisses the view 
	self.mapView.delegate = nil;
	//self.mapView = nil;
	[managedObjectContext release];
	[locationTimer release];

	[addTextNoteButton release];
	[addPhotoNoteButton release];
	[viewNotesButton release];
	[updateLocationButton release];
    [super dealloc];
}


@end
