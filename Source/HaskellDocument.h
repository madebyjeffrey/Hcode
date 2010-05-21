//
//  MyDocument.h
//  Hcode
//
//  Created by Jeffrey Drake on 10-04-16.
//  Copyright 2010 N/A. All rights reserved.
//
//  Credits:
//		stdout redirection from http://macosx.com/forums/software-programming-web-scripting/4522-better-way-read-nstask.html
//

#import <Cocoa/Cocoa.h>

#import "CodeLineNumberView.h"

#import "CodeView.h"

@interface HaskellDocument: NSDocument
{
	IBOutlet NSTextField * locationLabel;
	IBOutlet CodeView * documentView;
	NSString * temporaryStorage;
	CodeLineNumberView * lineNumberView;
	IBOutlet NSScrollView * scrollView;
	
	IBOutlet NSView * accessoryView;
	IBOutlet NSWindow * documentWindow;
	IBOutlet NSButton * playButton;
}

@property (retain) IBOutlet NSTextField * locationLabel;
@property (retain) IBOutlet CodeView * documentView;
@property (retain) NSString * temporaryStorage;
@property (retain) CodeLineNumberView * lineNumberView;
@property (retain) IBOutlet NSScrollView * scrollView;
@property (retain) 	IBOutlet NSButton * playButton;

- (BOOL) hasSheBang;

@end
