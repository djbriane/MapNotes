//
//  NoteAnnotation.m
//  LocationDisplay
//
//  Created by Brian Erickson on 7/23/09.
//  Copyright 2009 Local Matters, Inc. All rights reserved.
//

#import "NoteAnnotation.h"
#import "Note.h"

@implementation NoteAnnotation

@synthesize note = _note;
@synthesize coordinate = _coordinate;
@synthesize title;
@synthesize subtitle;

+ (id)annotationWithNote:(Note *)note {
	return [[[[self class] alloc] initWithNote:note] autorelease];
}

- (id)initWithNote:(Note *)note {
	self = [super init];
	if(nil != self) {
		self.note = note;
		self.coordinate = note.location.coordinate;
	}
	return self;
}

@end

