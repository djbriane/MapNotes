//
//  Group.h
//  MapNotes
//
//  Created by Brian Erickson on 9/14/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import <CoreData/CoreData.h>

@class Note;

@interface Group :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * marker;
@property (nonatomic, retain) NSSet* notes;

- (UIImage *)getPinImage;

@end


@interface Group (CoreDataGeneratedAccessors)
- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)value;
- (void)removeNotes:(NSSet *)value;

@end

