//
//  Note.h
//  MapNotes
//
//  Created by Brian Erickson on 7/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Note :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * geoAccuracy;
@property (nonatomic, retain) NSData * audio;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSNumber * geoLongitude;
@property (nonatomic, retain) NSNumber * geoLatitude;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSSet* tags;

@end


@interface Note (CoreDataGeneratedAccessors)
- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)value;
- (void)removeTags:(NSSet *)value;

@end

