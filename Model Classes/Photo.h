//
//  Photo.h
//  MapNotes
//
//  Created by Brian Erickson on 7/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Note;

@interface Photo :  NSManagedObject  
{
}

@property (nonatomic, retain) id image;
@property (nonatomic, retain) Note * note;

@end



