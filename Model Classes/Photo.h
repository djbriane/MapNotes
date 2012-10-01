//
//  Photo.h
//  MapNotes
//
//  Created by Brian Erickson on 9/17/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import <CoreData/CoreData.h>

@class Note;

@interface Photo :  NSManagedObject  
{
}

@property (nonatomic, retain) id image;
@property (nonatomic, retain) Note * note;

@end



