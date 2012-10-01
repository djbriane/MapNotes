//
//  NotePhotoViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 7/26/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

@class Note;

@interface NotePhotoViewController : UIViewController <UIScrollViewDelegate> {
    @private
        Note *note;
        //UIImageView *imageView;
	    UIScrollView *imageScrollView;
}

@property(nonatomic, retain) Note *note;
@property(nonatomic, retain) UIScrollView *imageScrollView;

@end
