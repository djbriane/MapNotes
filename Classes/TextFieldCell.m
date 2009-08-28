//
//  TextFieldCell.m
//  MapNotes
//
//  Created by Brian Erickson on 8/26/09.
//  Copyright 2009 WRKSHP, LLC. All rights reserved.
//

#import "TextFieldCell.h" 

// cell identifier for this custom cell
NSString* kCellTextView_ID = @"CellTextView_ID";

@implementation TextViewCell
@synthesize textView;

//Helper method to create the workout cell from a nib file...
+ (TextViewCell*) createNewTextCellFromNib { 
    NSArray* nibContents = [[NSBundle mainBundle] loadNibNamed:@"TextViewCell" owner:self options:nil]; 
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator]; 
    TextViewCell* tCell = nil; 
    NSObject* nibItem = nil; 
    while ( (nibItem = [nibEnumerator nextObject]) != nil) { 
        if ( [nibItem isKindOfClass: [TextViewCell class]]) { 
            tCell = (TextViewCell*) nibItem; 
            if ([tCell.reuseIdentifier isEqualToString: kCellTextView_ID]) 
                break; // we have a winner 
            else 
                tCell = nil; 
        } 
    } 
    return tCell; 
} 

- (void)dealloc
{
    [textView release];
    [super dealloc];
}

@end
