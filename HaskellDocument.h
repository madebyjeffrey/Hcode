//
//  MyDocument.h
//  Hcode
//
//  Created by Jeffrey Drake on 10-04-16.
//  Copyright 2010 N/A. All rights reserved.
//


#import <Cocoa/Cocoa.h>

#import "NoodleKit/NoodleLineNumberView.h"

@protocol Plus
- (NSUInteger)lineNumberForCharacterIndex:(NSUInteger)index inText:(NSString *)text; // sorry need internal method
@end

@interface HaskellDocument: NSDocument
{
}

@property (retain) IBOutlet NSTextField * locationLabel;
@property (retain) IBOutlet NSTextView * documentView;
@property (retain) NSString * temporaryStorage;
@property (retain) NoodleLineNumberView<Plus> * lineNumberView;
@property (retain) IBOutlet NSScrollView * scrollView;

@end
