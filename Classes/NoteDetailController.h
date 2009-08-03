//
//  NoteDetailController.h
//  MapNotes
//
//  Created by Brian Erickson on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class Note;
@class NoteAnnotation;
@class RoundedRectView;

@interface NoteDetailController : UITableViewController <UINavigationControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate> {
	Note *selectedNote;
	
	MKMapView *_mapView;
	NoteAnnotation *noteAnnotation;
	
	UIView *tableHeaderView;
	UIView *tableFooterView;
	UIButton *photoButton;
	UITextField *nameTextField;	
}

@property (nonatomic, retain) Note *selectedNote;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NoteAnnotation *noteAnnotation;

@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;
@property (nonatomic, retain) IBOutlet UIView *tableFooterView;
@property (nonatomic, retain) IBOutlet UIButton *photoButton;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;

- (void)updatePhotoInfo;
- (UIImage *)generatePhotoThumbnail:(UIImage *)image;
- (IBAction)editPhoto;

@end
