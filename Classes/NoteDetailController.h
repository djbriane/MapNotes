//
//  NoteDetailController.h
//  MapNotes
//
//  Created by Brian Erickson on 7/26/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
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
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>
#import "NoteTitleViewController.h"
#import "NoteDescViewController.h"

@class NoteTitleViewController;
@class Note;
@class NoteAnnotation;
@class RoundedRectView;

@interface NoteDetailController : UITableViewController <MKMapViewDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, NoteTitleDelegate, NoteDescDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate> {
	Note *selectedNote;

	MKMapView *_mapView;
	NoteAnnotation *noteAnnotation;
	
	UIView *tableHeaderView;
	UIView *tableFooterView;
	UIView *tableShareView;

	UIButton *deleteButton;
	UIButton *emailButton;
	UIButton *shareButton;
	UIButton *infoLabelButton;
	UIButton *takePictureButton;
	UIButton *selectFromCameraRollButton;
	
	UIButton *nameTextField;	
	UIButton *photoEditButton;
	UIButton *photoButton;
	UIImageView *photoBorderImage;
}

@property (nonatomic, retain) Note *selectedNote;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NoteAnnotation *noteAnnotation;

@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;
@property (nonatomic, retain) IBOutlet UIView *tableFooterView;
@property (nonatomic, retain) IBOutlet UIView *tableShareView;

@property (nonatomic, retain) IBOutlet UIButton *deleteButton;
@property (nonatomic, retain) IBOutlet UIButton *infoLabelButton;
@property (nonatomic, retain) IBOutlet UIButton *emailButton;
@property (nonatomic, retain) IBOutlet UIButton *shareButton;

@property (nonatomic, retain) IBOutlet UIButton *nameTextField;
@property (nonatomic, retain) IBOutlet UIButton *photoEditButton;
@property (nonatomic, retain) IBOutlet UIButton *photoButton;
@property (nonatomic, retain) IBOutlet UIImageView *photoBorderImage;

- (void)updatePhotoInfo;
- (void)initializeMap;
- (void)didSelectInsertRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)deleteExistingNote;
- (void)setCreatedDateLabel;
- (void)setLocationInfoLabel;
- (void)loadTableHeaderAndFooterViews;
- (void)showEmailView;
- (void)showComposeEmailViewWithNote:(Note *)note;
- (IBAction)editPhoto:(id)sender;
- (IBAction)editTitle:(id)sender;
- (IBAction)deleteNote:(id)sender;
- (IBAction)shareNote:(id)sender;
- (IBAction)emailNote:(id)sender;
- (IBAction)rotateInfoLabel:(id)sender;

@end
