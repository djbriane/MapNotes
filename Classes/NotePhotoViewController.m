//
//  NotePhotoViewController.m
//  MapNotes
//
//  Created by Brian Erickson on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NotePhotoViewController.h"

#import "Note.h"

@implementation NotePhotoViewController

@synthesize note;
@synthesize imageView;

- (void)loadView {
	self.title = @"Photo";

    imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor blackColor];
    
    self.view = imageView;
}


- (void)viewWillAppear:(BOOL)animated {
    imageView.image = [note.photo valueForKey:@"image"];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)dealloc {
    [imageView release];
    [note release];
    [super dealloc];
}


@end
