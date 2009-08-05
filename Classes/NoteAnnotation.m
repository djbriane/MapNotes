//
//  NoteAnnotation.m
//  LocationDisplay
//
//  Created by Brian Erickson on 7/23/09.
//  Copyright 2009 Local Matters, Inc. All rights reserved.
//

#import "NoteAnnotation.h"

@implementation NoteAnnotation

@synthesize coordinate = _coordinate;
@synthesize title;
@synthesize subtitle;

+ (id)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate {
	return [[[[self class] alloc] initWithCoordinate:coordinate] autorelease];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
	self = [super init];
	if(nil != self) {
		self.coordinate = coordinate;
	}
	return self;
}

@end

