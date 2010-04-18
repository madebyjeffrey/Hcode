//
//  MyDocument.m
//  Hcode
//
//  Created by Jeffrey Drake on 10-04-16.
//  Copyright 2010 N/A. All rights reserved.
//

#import "HaskellDocument.h"

@interface NSResponder (shift)

- (IBAction) shiftLeft: (id) sender;
- (IBAction) shiftRight: (id) sender;
@end

@implementation HaskellDocument

@synthesize locationLabel, documentView, temporaryStorage, lineNumberView, scrollView;

- (id)init
{
    self = [super init];
    if (self) {
		self.temporaryStorage = @"";
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"HaskellDocument";
}

- (void) awakeFromNib
{
	self.lineNumberView = [[[NoodleLineNumberView alloc] 
								initWithScrollView: scrollView] autorelease];
	[scrollView setVerticalRulerView: self.lineNumberView];
	[scrollView setHasHorizontalRuler: NO];
	[scrollView setHasVerticalRuler: YES];
	[scrollView setRulersVisible: YES];
	
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
	
	[documentView setAllowsUndo: NO];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	self.documentView.string = @"";
	[documentView insertText: self.temporaryStorage];
	[self.documentView invalidateTextContainerOrigin];
	self.temporaryStorage = @"";
	[self.documentView setRichText: NO];
	NSFont *font = [NSFont fontWithName: @"Menlo" size: 11.0];
	[self.documentView setFont: font];
	[self.documentView setSelectedRange: NSMakeRange(0, 0)];
	[self.documentView scrollRangeToVisible: NSMakeRange(0, 0)]; //[[documentView string] length])];
	[documentView setAllowsUndo: YES];	
	
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	
	NSData *data = [[self.documentView string] dataUsingEncoding: NSUTF8StringEncoding];

	if (data == nil)
	{
		*outError = [NSError errorWithDomain: @"Couldn't write data." code: 101 userInfo: NULL];
		return nil;
	}
	
/*    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	} */
	return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
	NSString *contents = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
	
	NSLog(@"contents: %@", contents);
	if (contents == nil)
	{
		*outError = [NSError errorWithDomain: @"Couldn't load in data." code: 100 userInfo: NULL];
		return NO;
	} else {
//		NSAttributedString *store = [[NSAttributedString alloc] initWithString: contents];
//		NSLog(@"view: %@", documentView);
	//	[self.documentView setString: contents];
		self.temporaryStorage = contents;
	}
/*    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}*/
		
    return YES;
}

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector {
	if ([self respondsToSelector: aSelector]) {
		BOOL (*method)(id, SEL, NSTextView*);
		method = (BOOL (*)(id, SEL, NSTextView*))[self methodForSelector: aSelector];
		return method(self, aSelector, aTextView);
	} else {
		return NO;
	}
}
/*
		 
	if (aSelector == @selector(insertTab:))	{
		if ([ranges count] > 1)
		{
		
		NSRange range = 
		[aTextView insertText: @"    "];
		return YES;
	} else if (aSelector == @selector(insertNewline:)) {
		NSArray *ranges = [aTextView selectedRanges];
		
		if ([ranges count] > 1) {
			return NO;
		} else {
			NSUInteger cursor_index = [[ranges objectAtIndex: 0] rangeValue].location;
			NSRange single_range = NSMakeRange(cursor_index, 0);
			NSString *doc = [[aTextView textStorage] string];
			NSRange whole_line = [doc lineRangeForRange: single_range];
			NSString *line = [doc substringWithRange: whole_line];
			int i = 0;
			for (i = 0; i < whole_line.length; i++)
			{
				if ([line characterAtIndex: i] != ' ')
					break;
			}
			
			NSString *indent = [line substringWithRange: NSMakeRange(0, i)];
			indent = [@"\n" stringByAppendingFormat: indent, nil];
			
			if ([aTextView shouldChangeTextInRange: [[ranges objectAtIndex: 0] rangeValue] 
								replacementString: indent]) {
				[aTextView replaceCharactersInRange: [[ranges objectAtIndex: 0] rangeValue]
										 withString: indent];
				[aTextView didChangeText];
			}
			
//			[[aTextView textStorage] 
//				replaceCharactersInRange: [[ranges objectAtIndex: 0] rangeValue] withString:indent];
			
			
			
//			NSLog(@"Previous line: %@", line);
			
			return YES;
			
		}

	}
	return NO;
}*/
	
- (BOOL) insertTab: (NSTextView*) aTextView {
	[aTextView insertText: @"    "]; // doesn't align!
	return YES;
}


- (BOOL) insertNewline: (NSTextView*) aTextView {
	NSArray *ranges = [aTextView selectedRanges];
	
	// Note, behaviour matches xcode as best observed.
	
	// Obtain the left most location selected
	NSUInteger cursor_index = [[ranges objectAtIndex: 0] rangeValue].location;

	// Make faux range to get the text for the line it is on
	NSRange single_range = NSMakeRange(cursor_index, 0);
	NSString *doc = [[aTextView textStorage] string];
	NSRange whole_line = [doc lineRangeForRange: single_range];
	NSString *line = [doc substringWithRange: whole_line];

	// Find out how many spaces are preceeding the text on that line
	int i = 0;
	for (i = 0; i < whole_line.length; i++)
	{
		if ([line characterAtIndex: i] != ' ')
			break;
	}
	
	// Our indent is that many spaces
	NSString *indent = [line substringWithRange: NSMakeRange(0, i)];
	indent = [@"\n" stringByAppendingFormat: indent, nil];
	
	// Replace the first selection with a new line followed by the indent spacing.	
	if ([aTextView shouldChangeTextInRange: [[ranges objectAtIndex: 0] rangeValue] 
						 replacementString: indent]) {
		[aTextView replaceCharactersInRange: [[ranges objectAtIndex: 0] rangeValue]
								 withString: indent];
		[aTextView didChangeText];
	}
	
	return YES;
}
	
- (BOOL) shiftLeft: (id) sender {
	
//	NSLog(@"shiftLeft: %@", aTextView);
	
	return YES;
	
}

- (BOOL) shiftRight: (id) sender {
//	NSLog(@"shiftRight: %@", aTextView);
	
	return YES;
}

- (void)textViewDidChangeSelection:(NSNotification *)aNotification
{
	// Always display the location of the top left most part of a selection
	NSRange range = [[[documentView selectedRanges] objectAtIndex: 0] rangeValue];

	NSString *str = [[documentView textStorage] string];
	
	NSUInteger line = [lineNumberView lineNumberForCharacterIndex: range.location 
														   inText: str];
	
	NSRange lineRange = [str lineRangeForRange: NSMakeRange(range.location, 0)];
	
	NSUInteger column = range.location - lineRange.location;
	
	
	
	[[locationLabel cell] setStringValue: [NSString stringWithFormat: @"%u : %u", line+1, column+1]];
	
}

@end
