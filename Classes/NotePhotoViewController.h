//
//  NotePhotoViewController.h
//  MapNotes
//
//  Created by Brian Erickson on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@class Note;

@interface NotePhotoViewController : UIViewController {
    @private
        Note *note;
        UIImageView *imageView;
}

@property(nonatomic, retain) Note *note;
@property(nonatomic, retain) UIImageView *imageView;

@end
