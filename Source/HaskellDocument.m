//
//  MyDocument.m
//  Hcode
//
//  Created by Jeffrey Drake on 10-04-16.
//  Copyright 2010 N/A. All rights reserved.
//

#import "HaskellDocument.h"
#import "Console.h"
#import "HcodeDelegate.h"

@interface HaskellDocument (Private)
- (NSString *)haskellLaunchPath;
@end

@implementation HaskellDocument

@synthesize locationLabel, documentView, temporaryStorage, lineNumberView, scrollView;

@synthesize _task, _fileHandle;

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

// Support for executing 'runhaskell' on current document

// NOTE: This function is not complete yet and is in the middle of an overhaul.
- (void)buildAndRun: (id) sender
{
	NSLog(@"RunHaskell on %@", [[self fileURL] path]);
	
	// Lets see if there is a shebang
	//NSString *firstLine = [self.documentView getLine: 0];
	
//	NSLog(@"First Line: %@ ...", firstLine);
	//[[self.documentView textStorage] string];
	//NSRange line1Range = { 0, [self.documentView characterIndexForLine: 1] };
	
//	NSLog(@"Line 1 from index 0 to index %d", line1Range.length);
//	NSString *firstLine = [store substringToIndex: [self.documentView characterIndexForLine: 1]-1];
//	NSLog(@"Line 1 is \"%@\"", firstLine);
	
//	NSString *firstChar = [firstLine substringToIndex: 2];
	
//	if ([firstChar compare: @"#!"] == NSOrderedSame)
//		NSLog(@"Has Shebang");
	
	// Next set this to save the document first (ask?)
/*	NSTask *rh = [[NSTask alloc] init];
	rh.launchPath = [self haskellLaunchPath];
	rh.arguments = [NSArray arrayWithObject: [[self fileURL] path]];
    NSLog(@"launch path: %@", rh.launchPath);
	[rh launch]; */
	
	
	// BREAK THIS OUT INTO MORE INTELLIGENT SUBMETHODS - have them return NO if they fail to continue and we can
	// try the next one
	
	// Option 1: Check for #! for instructions for running
	if (_task)
	{	// Must terminate
		[_task terminate];
	} else {
		if ([self runAsScript] == NO)  // run it as a script
		{
			
		}
	}
	
	return;
	// Option 2: Do we have a cabal file in the folder
	/*
	NSString *folder = [[[self fileURL] path] stringByDeletingLastPathComponent];
	NSFileManager *filesystem = [[NSFileManager alloc] init];
	NSError *error = nil;
	
	NSArray *files = [filesystem contentsOfDirectoryAtPath: folder error: &error];
	if (files == nil)
		NSLog(@"Error reading contents of folder %@ with error %@", folder, error);
	else {
		NSPredicate *cabalFilter = [NSPredicate predicateWithFormat: @"pathExtension like 'cabal'"];
		
		NSArray *filteredFiles = [files filteredArrayUsingPredicate: cabalFilter];
		
//		NSLog(@"filteredFiles: %@", filteredFiles);
		
		if ([filteredFiles count] > 0)
		{
			NSLog(@"Found at least one cabal file, letting cabal build it");
		
			NSTask *env = [[NSTask alloc] init];
			[env setLaunchPath: @"/usr/bin/env"];
			[env setArguments: [NSArray arrayWithObject: @"cabal configure"]];
			[env launch];
			[env waitUntilExit];
			if ([env terminationStatus] == 0) { // next step
				env == [[NSTask alloc] init];
				[env setLaunchPath: @"/usr/bin/env"];
				[env setArguments: [NSArray arrayWithObject: @"cabal build"]];
				[env launch];
				[env waitUntilExit];
				if ([env terminationStatus] == 0) {
					NSLog(@"Build Succeeded");
					// Find the output!
				}
			}
				
		}
	}

	
	*/
	// Runhaskell like we do now, but with /usr/bin/env runhaskell
}

- (NSString *)haskellLaunchPath
{
    // TODO: Allow this to be set in the preferences file?
    NSTask *which = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    NSString *path = @"/usr/bin/runhaskell";
    [which setLaunchPath:@"/usr/bin/which"];
    [which setArguments:[NSArray arrayWithObject:@"runhaskell"]];
    [which setStandardOutput:pipe];
    [which launch];
    [which waitUntilExit];
    if ([which terminationStatus] == 0) {
        NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
        path = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        path = [path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"Found runhaskell using which: %@", path);
    }
    [which release];
    return path;
}

- (BOOL) hasSheBang
{
	NSString *firstLine = [self.documentView getLine: 0];
	
	NSString *firstChars = [firstLine substringToIndex: 2];
	
	return ([firstChars compare: @"#!"] == NSOrderedSame) ? YES : NO;
}

- (BOOL) runAsScript
{
	if ([self hasSheBang] == YES)
	{
		[[Console sharedConsole] log: @"Starting...\n"];
		NSTask *task = [[NSTask alloc] init];
		task.launchPath = [[self fileURL] path];
		[self redirectOutputFrom: task];
		
		NSMenuItem *run = [((HcodeDelegate*)[[NSApplication sharedApplication] delegate]) runItem];
		
		[run setTitle: @"Stop"];
			
		[task launch]; // implement IO redirection
		
		return YES;
	}
	
	return NO;
}

- (void) redirectOutputFrom: (NSTask*) task
{
	NSPipe *pipe = [NSPipe pipe];
	
	_fileHandle = [pipe fileHandleForReading];
//	[_fileHandle readInBackgroundAndNotify];
//	[_fileHandle readToEndOfFileInBackgroundAndNotify];
	_task = task;
	[_fileHandle waitForDataInBackgroundAndNotify];
	
	
	[_task setStandardOutput: pipe];
	[_task setStandardError: pipe];
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(readPipe:)
												 name: NSFileHandleDataAvailableNotification // NSFileHandleReadCompletionNotification
											   object: _fileHandle];

	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(taskDidEnd:)
												 name: NSTaskDidTerminateNotification	
											   object: _task];
	

	//NSFileHandleReadToEndOfFileCompletionNotification
}

- (void) taskDidEnd: (NSNotification*) notification
{
	[[NSNotificationCenter defaultCenter] removeObserver: self 
													name: NSFileHandleDataAvailableNotification // NSFileHandleReadCompletionNotification 
												  object: nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self 
													name: NSTaskDidTerminateNotification 
												  object: nil];	
	
	[[Console sharedConsole] log: @"\nTerminated.\n"];
	
	NSMenuItem *run = [((HcodeDelegate*)[[NSApplication sharedApplication] delegate]) runItem];
	
	[run setTitle: @"Build and Run"];
	
	
	self._task = nil;
}


- (void) readPipe: (NSNotification*) notification
{
	NSData *data;
	NSString *text;
	
	if ([notification object] != _fileHandle)
		return;
	
//	data = [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
	data = [_fileHandle availableData];
	
	text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	
	[[Console sharedConsole] log: text];
	
	if (_task)
		[_fileHandle waitForDataInBackgroundAndNotify];
	//	[_fileHandle readInBackgroundAndNotify];
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
