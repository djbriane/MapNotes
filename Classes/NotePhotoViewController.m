//
//  NotePhotoViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 7/26/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import "NotePhotoViewController.h"
#import "MapNotesAppDelegate.h"
#import "Note.h"

#define ZOOM_VIEW_TAG 100

@implementation NotePhotoViewController

@synthesize note;
@synthesize imageScrollView;

- (void)loadView {
	[super loadView];

	self.title = @"Photo";
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	/*
	scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    //imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor blackColor];
    [scrollView addSubview:imageView];
    self.view = scrollView;
	*/
	
	// set up main scroll view
    imageScrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [imageScrollView setBackgroundColor:[UIColor blackColor]];
    [imageScrollView setDelegate:self];
    [imageScrollView setBouncesZoom:YES];
    [[self view] addSubview:imageScrollView];
    
    // add touch-sensitive image view to the scroll view
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[note.photo valueForKey:@"image"]];
    //[imageView setDelegate:self];
    [imageView setTag:ZOOM_VIEW_TAG];
    [imageScrollView setContentSize:[imageView frame].size];
    [imageScrollView addSubview:imageView];
    [imageView release];
    
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = [imageScrollView frame].size.width  / [imageView frame].size.width;
    [imageScrollView setMinimumZoomScale:minimumScale];
    [imageScrollView setZoomScale:minimumScale];
	
}


- (void)viewWillAppear:(BOOL)animated {
    //imageView.image = [note.photo valueForKey:@"image"];
	UIAppDelegate.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	UIAppDelegate.navigationController.navigationBar.translucent = NO;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [imageScrollView viewWithTag:ZOOM_VIEW_TAG];
}

/************************************** NOTE **************************************/
/* The following delegate method works around a known bug in zoomToRect:animated: */
/* In the next release after 3.0 this workaround will no longer be necessary      */
/**********************************************************************************/
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

- (void)dealloc {
    [imageScrollView release];
    [note release];
    [super dealloc];
}


@end
