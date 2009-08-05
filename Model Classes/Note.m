// 
//  Note.m
//  MapNotes
//
//  Created by Brian Erickson on 7/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Note.h"

@implementation Note 

@dynamic geoAccuracy;
@dynamic dateCreated;
@dynamic geoLongitude;
@dynamic geoLatitude;
@dynamic title;
@dynamic details;
@dynamic dateModified;
@dynamic thumbnail;
@dynamic photo;
@dynamic group;

@end 

@implementation ImageToDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
	NSData *data = UIImagePNGRepresentation(value);
	return data;
}


- (id)reverseTransformedValue:(id)value {
	UIImage *uiImage = [[UIImage alloc] initWithData:value];
	return [uiImage autorelease];
}

@end
