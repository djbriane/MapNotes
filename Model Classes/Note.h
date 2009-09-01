//
//  Note.h
//  MapNotes
//
//  Created by Brian Erickson on 7/31/09.
//  Copyright 2009 Local Matters, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Group;

@interface ImageToDataTransformer : NSValueTransformer {
}
@end

@interface Note :  NSManagedObject {
}

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) CLLocation * location;

@property (nonatomic, retain) NSManagedObject * photo;
@property (nonatomic, retain) Group * group;

@end



