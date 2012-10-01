//
//  QuickAddViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 8/5/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import "QuickAddViewController.h"
#import "RootViewController.h"
#import "MapNotesAppDelegate.h"
#import "ImageManipulator.h"
#import "LocationController.h"
#import "NoteDetailController.h"
#import "NoteAnnotation.h"
#import "Note.h"
#import "Group.h"
#import "Photo.h"

// Pinch Analytics
#import "Beacon.h"

@implementation QuickAddViewController

@synthesize delegate;
@synthesize mapView = _mapView;
@synthesize locationTimer, managedObjectContext, selectedGroup, notesArray;
@synthesize addTextNoteButton, addPhotoNoteButton, viewNotesButton, updateLocationButton, updateLocationActivity, loadingImageView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[UIApplication sharedApplication].statusBarHidden = YES;
	[self.viewNotesButton setEnabled:YES];
	//[self.mapView setAlpha:0.0];
	
	// update location
	[self startUpdatingLocation];
	
	// get notes
	[self fetchExistingNotes];
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
	} 
	
	CLLocation *location = [[LocationController sharedInstance] currentLocation];
	// Send location info to Pinch Analytics
	[[Beacon shared] setBeaconLocation:location];

	MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
	
	region.center = location.coordinate;
	region.span.longitudeDelta = 0.01f;
	region.span.latitudeDelta = 0.01f;

	// Load annotations
	if(nil != self.notesArray) {
		for (Note *aNote in self.notesArray) {
			// create an annotation
			NoteAnnotation *aNoteAnnotation;
			aNoteAnnotation = [NoteAnnotation annotationWithNote:aNote];
			if ([aNote.title length] != 0) {
				aNoteAnnotation.title = aNote.title;
			} else if ([aNote.details length] != 0) {
				aNoteAnnotation.title = aNote.details;
			} else {
				static NSDateFormatter *dateFormatter = nil;
				if (dateFormatter == nil) {
					dateFormatter = [[NSDateFormatter alloc] init];
					[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
					[dateFormatter setDateStyle:NSDateFormatterShortStyle];
				}
				aNoteAnnotation.title = [dateFormatter stringFromDate:[aNote dateCreated]];
			}
			[self.mapView addAnnotation:aNoteAnnotation];
		}
	}
	
	[self.mapView setRegion:region animated:NO];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];	
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:self];
	[self.loadingImageView setAlpha:1.0];
	[UIView commitAnimations];
	self.mapView.hidden = NO;
	
	// Update UI to reflect we have a good location
	[self.updateLocationActivity stopAnimating];
	self.updateLocationButton.enabled = YES;
	self.addTextNoteButton.enabled = YES;
	self.addPhotoNoteButton.enabled = YES;
	
	[self.locationTimer invalidate];
	
	// continue checking for a new location
	/*
	self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self 
														selector:@selector(pollAndUpdateLocation) 
														userInfo:nil 
														 repeats:YES];
	 */
}

- (void)startUpdatingLocation {
	// invalidate any existing timer
	[self.locationTimer invalidate];
	
	// disable the location button and start animating
	self.updateLocationButton.enabled = NO;
	//[self.updateLocationActivity startAnimating];
	
	// tell the location controller to start updating and set up a timer 
	[[LocationController sharedInstance] start];
	self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self 
														selector:@selector(checkAndUpdateLocation) 
														userInfo:nil 
														 repeats:YES];
}

- (void)fetchExistingNotes {
	/*
	 Fetch existing events.
	 Create a fetch request; find the Event entity and assign it to the request; add a sort descriptor; then execute the fetch.
	 */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// Order the notes by creation date, most recent first.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	// set up a Predicate if a group has been selected
	if (self.selectedGroup != nil) {
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"(group = %@)", self.selectedGroup];
		[request setPredicate: pred];
	} 
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"%@:%s Error fetching context: %@", [self class], _cmd, [error localizedDescription]);
	}
	
	// Set self's events array to the mutable array, then clean up.
	[self setNotesArray:mutableFetchResults];	
	[mutableFetchResults release];
	[request release];
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
	if (selectedGroup != nil) {
		[note setGroup:selectedGroup];
	}

	return note;
}

- (IBAction)addTextNote:(id)sender {
	Note *note = [self createNewNote];
	if (!note) {
		// TODO: Should throw an error here? Something went horribly wrong if we get here
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

	[[Beacon shared] startSubBeaconWithName:@"QuickAdd - New Text Note" timeSession:NO];

	/*
	NoteDescViewController *descController = [[NoteDescViewController alloc] initWithNibName:@"EditDesc" bundle:nil];
    descController.delegate = self;
	descController.note = note;
	
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:descController];
	navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.4902 green:0.5098 blue:.5294 alpha:1.0];
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];	
    [descController release];
	 */
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
	[[Beacon shared] startSubBeaconWithName:@"Quick Add - View Notes" timeSession:NO];
}

- (IBAction)updateLocation:(id)sender {
	if ([[LocationController sharedInstance] locationKnown]) {
		CLLocation *location = [[LocationController sharedInstance] currentLocation];
		[self.mapView setCenterCoordinate:location.coordinate animated:YES];
	} else {
		[self startUpdatingLocation];
	}
	
	// Close annotation callouts
	for(NoteAnnotation *aMKAnn in  [self.mapView selectedAnnotations]) {
		[self.mapView deselectAnnotation:aMKAnn animated:YES];
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
		[[Beacon shared] startSubBeaconWithName:@"QuickAdd - Take Photo" timeSession:YES];
	} 
	else if ([actionSheet buttonTitleAtIndex:buttonIndex] == kChoosePhotoButtonText) {
		// Choose Existing
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePicker.delegate = self;
		[self presentModalViewController:imagePicker animated:YES];
		[imagePicker release];
		[[Beacon shared] startSubBeaconWithName:@"QuickAdd - Choose Photo" timeSession:YES];
	} 
}

#pragma mark -
#pragma mark Image Picker Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker 
		didFinishPickingImage:(UIImage *)selectedImage 
				  editingInfo:(NSDictionary *)editingInfo {
	
	// Save the image to the users album
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil);
	}
	
	// Create a new note
	Note *note = [self createNewNote];
	if (!note) {
		// TODO: Throw an error here
		return;
	}
	
	// Create a new photo object and associate it with the event.
	Photo *photo = (Photo *)[NSEntityDescription insertNewObjectForEntityForName:@"Photo" 
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
	
    if ([self.delegate respondsToSelector:@selector (quickAddViewController:showNote:editing:)]) {
		[self.delegate quickAddViewController:self showNote:note editing:YES];
	}
	[[Beacon shared] endSubBeaconWithName:@"QuickAdd - Take Photo"];
	[[Beacon shared] endSubBeaconWithName:@"QuickAdd - Choose Photo"];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	// The user canceled -- simply dismiss the image picker.
	[self dismissModalViewControllerAnimated:YES];
	[[Beacon shared] endSubBeaconWithName:@"QuickAdd - Take Photo"];
	[[Beacon shared] endSubBeaconWithName:@"QuickAdd - Choose Photo"];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	// Customize the title of the nav bar for camera capture
	//navigationController.navigationBar.topItem.title = @"Custom Picker Title";
    //navigationController.navigationBar.topItem.prompt = @"Custom Picker Prompt";
}

#pragma mark -
#pragma mark Note Description View Controller Methods

- (void)noteTitleViewController:(NoteTitleViewController *)controller 
					didSetTitle:(Note *)note
						didSave:(BOOL)didSave {

	if (didSave == NO) {
		[note.managedObjectContext deleteObject:note];
	}

	NSError *error = nil;
	if (![note.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	if (didSave) {
		if ([self.delegate respondsToSelector:@selector (quickAddViewController:showNote:editing:)]) {
			[self.delegate quickAddViewController:self showNote:note editing:YES];
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
#pragma mark MKMapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKAnnotationView *view = nil;
	if(annotation != mapView.userLocation) {
		view = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
		
		if(nil == view) {
			view = [[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"identifier"] autorelease];
			view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		}
			
		// add the note thumbnail to the flyout
		NoteAnnotation *noteAnnotation = (NoteAnnotation *)annotation;
		if (noteAnnotation.note.thumbnail != nil) {
			UIImageView *photoView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)] autorelease];
			view.leftCalloutAccessoryView = photoView;
			photoView.image = noteAnnotation.note.thumbnail;
		}

		if (noteAnnotation.note.group != nil) {
			[view setImage:[noteAnnotation.note.group getPinImage]];	
		} else {
			[view setImage:[UIImage imageNamed:@"node_orange.png"]];
		}
		CGPoint offsetPixels;
		offsetPixels.x = 0;
		offsetPixels.y = -16;
		view.centerOffset = offsetPixels;
		
		[view setCanShowCallout:YES];
	} 
	return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	NoteAnnotation *ann = (NoteAnnotation *)view.annotation;
/*
	NoteDetailController *noteDetailController = [[NoteDetailController alloc] initWithStyle:UITableViewStyleGrouped];
	noteDetailController.view.backgroundColor = [UIColor clearColor];
	noteDetailController.selectedNote = ann.note;
	[noteDetailController setEditing:NO animated:NO];
    [UIAppDelegate.navigationController pushViewController:noteDetailController animated:NO];
	[noteDetailController release];

	[self dismissModalViewControllerAnimated:YES];
 */
	if ([self.delegate respondsToSelector:@selector (quickAddViewController:showNote:editing:)]) {
		[self.delegate quickAddViewController:self showNote:ann.note editing:NO];
	}
	[[Beacon shared] startSubBeaconWithName:@"QuickAdd - View Note from Map" timeSession:NO];
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
	[selectedGroup release];

	[addTextNoteButton release];
	[addPhotoNoteButton release];
	[viewNotesButton release];
	[updateLocationButton release];
    [super dealloc];
}


@end
