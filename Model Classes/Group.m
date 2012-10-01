// 
//  Group.m
//  MapNotes
//
//  Created by Brian Erickson on 9/14/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import "Group.h"

#import "Note.h"

@implementation Group 

@dynamic name;
@dynamic marker;
@dynamic notes;


- (UIImage *)getPinImage {
	NSInteger pinMarker = [self.marker intValue];
	switch (pinMarker) {
		case 0:
			return [UIImage imageNamed:@"node_orange.png"];
			break;
		case 1:
			return [UIImage imageNamed:@"node_green.png"];
			break;
		case 2:
			return [UIImage imageNamed:@"node_purple.png"];
			break;
		case 3:
			return [UIImage imageNamed:@"node_yellow.png"];
			break;
		default:
			break;
	}
	return [UIImage imageNamed:@"node_orange.png"];
}

@end
