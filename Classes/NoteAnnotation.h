//
//  NoteAnnotation.h
//  LocationDisplay
//
//  Created by Brian Erickson on 7/23/09.
//  Copyright 2009 Brian Erickson. May be freely distributed under the MIT license.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class Note;

@interface NoteAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D _coordinate;
	Note *_note;
	NSString *title;
	NSString *subtitle;
}

+ (id)annotationWithNote:(Note *)note;
- (id)initWithNote:(Note *)note;

@property (nonatomic, assign) Note *note;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
