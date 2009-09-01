// 
//  Note.m
//  MapNotes
//
//  Created by Brian Erickson on 7/31/09.
//  Copyright 2009 Local Matters, Inc. All rights reserved.
//

#import "Note.h"
#import "Group.h"
#import "CLLocation+DistanceComparison.h"

@implementation Note 

@dynamic dateCreated;
@dynamic title;
@dynamic details;
@dynamic dateModified;
@dynamic thumbnail;
@dynamic photo;
@dynamic group;
@dynamic location;

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
