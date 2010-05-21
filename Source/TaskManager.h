//
//  TaskManager.h
//  Hcode
//
//  Created by Jeffrey Drake on 10-05-21.
//  Copyright 2010 Jeffrey Drake. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HaskellDocument.h"

@interface TaskManager : NSObject {
	BOOL taskActive;
	NSTask *_task;
	NSFileHandle *_fileHandle;
	NSDocument *_document;
}

+ (TaskManager*) sharedTaskManager;

- (void) runDocument: (HaskellDocument*) document;
- (void) redirectOutputFrom: (NSTask*) task;
- (void) terminate;
- (BOOL) active;
@end
