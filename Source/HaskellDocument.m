//
//  MyDocument.m
//  Hcode
//
//  Created by Jeffrey Drake on 10-04-16.
//  Copyright 2010 N/A. All rights reserved.
//
//	Credits:
//		Improving stdout reading	dirtyfreebooter/macdev

#import "HaskellDocument.h"
#import "Console.h"
#import "HcodeDelegate.h"
#import "TaskManager.h"


@implementation HaskellDocument

@synthesize locationLabel, documentView, temporaryStorage, lineNumberView, scrollView, playButton;

- (id)init {
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

- (void) awakeFromNib {
	self.lineNumberView = [[[CodeLineNumberView alloc] 
								initWithScrollView: scrollView] autorelease];
	[scrollView setVerticalRulerView: self.lineNumberView];
	[scrollView setHasHorizontalRuler: NO];
	[scrollView setHasVerticalRuler: YES];
	[scrollView setRulersVisible: YES];
	
	NSView *themeFrame = [[documentWindow contentView] superview];
	NSRect c = [themeFrame frame]; // container
	NSRect aV = [accessoryView frame]; // accessory view
	NSRect newFrame = NSMakeRect(c.size.width - aV.size.width,
								 c.size.height - aV.size.height,
								 aV.size.width,
								 aV.size.height);
	
	[accessoryView setFrame: newFrame];
	[themeFrame addSubview: accessoryView];
	
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController {
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

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
	NSData *data = [[self.documentView string] dataUsingEncoding: NSUTF8StringEncoding];

	if (data == nil) {
		*outError = [NSError errorWithDomain: @"Couldn't write data." code: 101 userInfo: NULL];
		return nil;
	}
	return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
	NSString *contents = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
	
	NSLog(@"contents: %@", contents);
	if (contents == nil) 	{
		*outError = [NSError errorWithDomain: @"Couldn't load in data." code: 100 userInfo: NULL];
		return NO;
	} else {
		self.temporaryStorage = contents;
	}

    return YES;
}


// Update the line containing
- (void)textViewDidChangeSelection:(NSNotification *)aNotification
{
	[[locationLabel cell] setStringValue: 
		 [NSString stringWithFormat: @"%u : %u", [documentView line]+1, [documentView column]+1]];
}

- (void)buildAndRun: (id) sender
{
	if ([[TaskManager sharedTaskManager] active])
		[[TaskManager sharedTaskManager] terminate];
	else 
		[[TaskManager sharedTaskManager] runDocument: self];
}

- (BOOL) hasSheBang
{
	NSString *firstLine = [self.documentView getLine: 0];
	
	NSString *firstChars = [firstLine substringToIndex: 2];
	
	return ([firstChars compare: @"#!"] == NSOrderedSame) ? YES : NO;
}

- (IBAction) birdTrack: (id) sender
{
	// Add '> ' to the beginning of each line
	
	// Retrieving the current selection, only the first
	NSRange trackRange = [[[self.documentView selectedRanges] objectAtIndex: 0] rangeValue];

	NSString *textString = [[self.documentView textStorage] string];
	
	if (trackRange.length != 0) // selection is at least more than the single caret
	{
		// If there is a multiline selection, and it ends in a newline, a track will end up on the line afterwards too
		NSString *trackRangeContents = [textString substringWithRange: trackRange];
		NSString *lastCharacter = [trackRangeContents substringWithRange: NSMakeRange([trackRangeContents length] - 1, 1)];
		
		// Checking for the lastCharacter being a newline of some sort
		NSRange rangeOfNewLine = [lastCharacter rangeOfCharacterFromSet: [NSCharacterSet newlineCharacterSet]];
		
		if (rangeOfNewLine.location != NSNotFound) // Newline is at the end
			trackRange.length--;
	}
	
	// Lines in selection
	NSArray *lineRange = [[self.documentView lineNumbersForRange: trackRange] copy];
	
	// Going to enumerate in reverse order, so that inserts don't change our lines
	NSEnumerator *lineEnumerator = [lineRange reverseObjectEnumerator];
	
	// Going through every line
	for (NSNumber *lineIndex in lineEnumerator)
	{
		// We obtain a line index, and we must convert it to a character index
		NSUInteger lineStart = [self.documentView characterIndexForLine: [lineIndex unsignedIntegerValue]];
		
		// Checking for a bird track already present
		NSRange trackRange = NSMakeRange(lineStart, 2);
		
		// Check if document is long enough to even check for a track
		if (([textString length] - lineStart) >= 2)
		{
			// Do we have a "> " already here?
			NSRange trackPresentRange = [textString rangeOfString: @"> " options: 0 range: trackRange];
			if (trackPresentRange.location != NSNotFound) // Track is here
				continue; 
		}
		
		trackRange.length = 0; // Replacement range is begining of line with a length of 0 as if the caret was there
		
		// Add track to the current line
		if ([self.documentView shouldChangeTextInRange: trackRange replacementString: @"> "])
		{
			[self.documentView replaceCharactersInRange: trackRange withString: @"> "];
			
			[self.documentView didChangeText];
		}
	}
	
	// update selection to the area we modified, whole lines - only if we had a selection
	
	if (trackRange.length > 0)
	{
		NSUInteger fi, li;
		fi = [self.documentView characterIndexForLine: [[lineRange objectAtIndex: 0] unsignedIntegerValue]];
		li = [self.documentView characterIndexForLine: [[lineRange lastObject] unsignedIntegerValue]+1];
	
		NSRange y = { fi, li-fi };
	
		[self.documentView setSelectedRanges: [NSArray arrayWithObject: [NSValue valueWithRange: y]]]; 
	}
}

- (IBAction) unBirdTrack: (id) sender
{
	// Remove '> ' to the beginning of each line
	
	// Retrieving the current selection, only the first
	NSRange trackRange = [[[self.documentView selectedRanges] objectAtIndex: 0] rangeValue];
	
	NSString *textString = [[self.documentView textStorage] string];
	
	if (trackRange.length != 0) // selection is at least more than the single caret
	{
		// If there is a multiline selection, and it ends in a newline, a track will end up on the line afterwards too
		NSString *trackRangeContents = [textString substringWithRange: trackRange];
		NSString *lastCharacter = [trackRangeContents substringWithRange: NSMakeRange([trackRangeContents length] - 1, 1)];
		
		// Checking for the lastCharacter being a newline of some sort
		NSRange rangeOfNewLine = [lastCharacter rangeOfCharacterFromSet: [NSCharacterSet newlineCharacterSet]];
		
		if (rangeOfNewLine.location != NSNotFound) // Newline is at the end
			trackRange.length--;
	}
	
	// Lines in selection
	NSArray *lineRange = [[self.documentView lineNumbersForRange: trackRange] copy];
	
	// Going to enumerate in reverse order, so that inserts don't change our lines
	NSEnumerator *lineEnumerator = [lineRange reverseObjectEnumerator];
	
	// Going through every line
	for (NSNumber *lineIndex in lineEnumerator)
	{
		// We obtain a line index, and we must convert it to a character index
		NSUInteger lineStart = [self.documentView characterIndexForLine: [lineIndex unsignedIntegerValue]];
		
		// Checking for a bird track already present
		NSRange trackRange = NSMakeRange(lineStart, 2);
		
		// Check if document is long enough to even check for a track
		if (([textString length] - lineStart) >= 2)
		{
			// Do we have a "> " already here?
			NSRange trackPresentRange = [textString rangeOfString: @"> " options: 0 range: trackRange];
			if (trackPresentRange.location != NSNotFound) // Track is here
			{
				if ([self.documentView shouldChangeTextInRange: trackRange replacementString: @""])
				{
					[self.documentView replaceCharactersInRange: trackRange withString: @""];
					
					[self.documentView didChangeText];
				}
			}
		} else {
			continue; // should we end instead of continuing? It should be the end if we don't have enough space for to even check
		}
	}
	
	// update selection to the area we modified, whole lines - only if we had a selection
	if (trackRange.length > 0)
	{
		NSUInteger fi, li;
		fi = [self.documentView characterIndexForLine: [[lineRange objectAtIndex: 0] unsignedIntegerValue]];
		li = [self.documentView characterIndexForLine: [[lineRange lastObject] unsignedIntegerValue]+1];
		
		NSRange y = { fi, li-fi };
		
		[self.documentView setSelectedRanges: [NSArray arrayWithObject: [NSValue valueWithRange: y]]]; 
	}
}


@end
