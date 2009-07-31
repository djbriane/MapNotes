//
//  Note.h
//  MapNotes
//
//  Created by Brian Erickson on 7/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Photo;
@class Group;

@interface Note :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * geoAccuracy;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSNumber * geoLongitude;
@property (nonatomic, retain) NSNumber * geoLatitude;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) id thumbnail;
@property (nonatomic, retain) Photo * photo;
@property (nonatomic, retain) Group * group;

@end



