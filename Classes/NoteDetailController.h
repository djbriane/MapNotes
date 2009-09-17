//
//  NoteDetailController.h
//  MapNotes
//
//  Created by Brian Erickson on 7/26/09.
//  Copyright 2009 Local Matters, Inc.. All rights reserved.
//

#define kTakePhotoButtonText	@"Take Photo"
#define kChoosePhotoButtonText	@"Choose Existing Photo"
#define kDeletePhotoButtonText	@"Delete Photo"
#define kDeleteNoteButtonText	@"Delete Note"

//Note Description View contstants
#define kTextViewFontSize        15.0
#define kTextViewFontSizeDefault 17.0
#define kDefaultNoteLabel        @"Description"
#define kDefaultGroupLabel		 @"Group"
#define kMainLabelTag 1
#define kIconImageTag 2
#define kDetailsInfoLabelTag 3
#define kDetailsDescLabel 15

#define kMinimumGestureLength 25
#define kMaximumVariance 5

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NoteTitleViewController.h"
#import "NoteDescViewController.h"

@class NoteTitleViewController;
@class Note;
@class NoteAnnotation;
@class RoundedRectView;

@interface NoteDetailController : UITableViewController <MKMapViewDelegate, UINavigationControllerDelegate, NoteTitleDelegate, NoteDescDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate> {
	Note *selectedNote;

	MKMapView *_mapView;
	NoteAnnotation *noteAnnotation;
	
	UIView *tableHeaderView;
	UIView *tableFooterView;
	CGPoint gestureStartPoint;
	
	UIButton *photoEditButton;
	UIButton *photoButton;
	UIButton *deleteButton;
	UIButton *infoLabelButton;
	UIButton *takePictureButton;
	UIButton *selectFromCameraRollButton;
	UIImageView *photoBorderImage;
	
	UIButton *nameTextField;	
}

@property (nonatomic, retain) Note *selectedNote;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NoteAnnotation *noteAnnotation;

@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;
@property (nonatomic, retain) IBOutlet UIView *tableFooterView;
@property CGPoint gestureStartPoint;

@property (nonatomic, retain) IBOutlet UIButton *photoEditButton;
@property (nonatomic, retain) IBOutlet UIButton *photoButton;
@property (nonatomic, retain) IBOutlet UIButton *deleteButton;
@property (nonatomic, retain) IBOutlet UIButton *infoLabelButton;

@property (nonatomic, retain) IBOutlet UIButton *nameTextField;
@property (nonatomic, retain) IBOutlet UIImageView *photoBorderImage;

- (void)updatePhotoInfo;
- (void)initializeMap;
- (void)didSelectInsertRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)deleteExistingNote;
- (void)setCreatedDateLabel;
- (void)setLocationInfoLabel;
- (IBAction)editPhoto:(id)sender;
- (IBAction)editTitle:(id)sender;
- (IBAction)deleteNote:(id)sender;
- (IBAction)shareNote:(id)sender;
- (IBAction)rotateInfoLabel:(id)sender;

@end
