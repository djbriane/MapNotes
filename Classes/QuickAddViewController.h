//
//  QuickAddViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 8/5/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#define kTakePhotoButtonText	@"Take Photo"
#define kChoosePhotoButtonText	@"Choose Existing Photo"
#define kDeletePhotoButtonText	@"Delete Photo"

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NoteTitleViewController.h"

@class NoteTitleViewController;

@class Note;
@class Group;

@protocol QuickAddViewControllerDelegate;

@interface QuickAddViewController : UIViewController <MKMapViewDelegate, NoteTitleDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	id<QuickAddViewControllerDelegate> delegate;
	
	NSManagedObjectContext *managedObjectContext;
	MKMapView *_mapView;
	NSTimer *locationTimer;
	Group *selectedGroup;
	NSMutableArray *notesArray;
	
	IBOutlet UIImageView *loadingImageView;
	//IBOutlet UILabel *locationInfoLabel;
	IBOutlet UIButton *addTextNoteButton;
	IBOutlet UIButton *addPhotoNoteButton;
	IBOutlet UIButton *viewNotesButton;
	IBOutlet UIButton *updateLocationButton;
	IBOutlet UIActivityIndicatorView *updateLocationActivity;
}

@property (nonatomic, assign) id<QuickAddViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSTimer *locationTimer;
@property (nonatomic, retain) Group *selectedGroup;
@property (nonatomic, retain) NSMutableArray *notesArray;

@property (nonatomic, retain) IBOutlet UIButton *addTextNoteButton;
@property (nonatomic, retain) IBOutlet UIButton *addPhotoNoteButton;
@property (nonatomic, retain) IBOutlet UIButton *viewNotesButton;
@property (nonatomic, retain) IBOutlet UIButton *updateLocationButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *updateLocationActivity;
@property (nonatomic, retain) IBOutlet UIImageView *loadingImageView;

- (void)checkAndUpdateLocation;
- (void)startUpdatingLocation;
- (Note *)createNewNote;
- (void)fetchExistingNotes;

- (IBAction)addPhotoNote:(id)sender;
- (IBAction)addTextNote:(id)sender;
- (IBAction)viewNotes:(id)sender;
- (IBAction)updateLocation:(id)sender;

@end

@protocol QuickAddViewControllerDelegate <NSObject>

@optional

- (void)quickAddViewController:(QuickAddViewController *)controller showNote:(Note *)note editing:(BOOL)editing;

@end