//
//  TaskManager.m
//  Hcode
//
//  Created by Jeffrey Drake on 10-05-21.
//  Copyright 2010 Jeffrey Drake. All rights reserved.
//

#import "TaskManager.h"
#import "Console.h"
#import "HcodeDelegate.h"
#import "SynthesizeSingleton.h"

@implementation TaskManager

SYNTHESIZE_SINGLETON_FOR_CLASS(TaskManager)

- (void) runDocument: (HaskellDocument*) document
{
	if (taskActive)
	{
		// Alert for already running task?
		return;
	}
	
	if ([document hasSheBang] == YES)
	{
		[[Console sharedConsole] log: @"Starting...\n"];
		NSTask *task = [[NSTask alloc] init];
		task.launchPath = [[document fileURL] path];
		[self redirectOutputFrom: task];
		
		NSMenuItem *run = [[HcodeDelegate sharedHcodeDelegate] runItem];

		[run setTitle: @"Stop"];
		_document = document;
		
		[document.playButton setImage: [NSImage imageNamed: @"Stop"]];
		
		[task launch]; // implement IO redirection
		_task = task;
		taskActive = YES;
		return;
	}
	
}

- (BOOL) active
{
	return taskActive;
}

- (void) terminate
{
	[_task terminate];
	
	_task = nil;
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
	
	NSMenuItem *run = [[HcodeDelegate sharedHcodeDelegate] runItem];
	
	[run setTitle: @"Build and Run"];
	[((HaskellDocument*)_document).playButton setImage: [NSImage imageNamed: @"Play"]];
	
	taskActive = NO;
	
	_task = nil;
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

@end

/* for storage...
 
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
