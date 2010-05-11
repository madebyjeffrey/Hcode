//
//  CodeView.h
//  Hcode/CodeView
//
//  Created by Jeffrey Drake on 10-04-17.
//  Copyright (c) 2010 by Jeffrey Drake. All rights reserved.
//
//	Some portions adapted from NoodleKit and are
//  Copyright (c) 2008 Noodlesoft, LLC. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
#import <Cocoa/Cocoa.h>


@interface CodeView : NSTextView {
    NSMutableArray      *_lineIndices;
}

- (NSUInteger) column;
- (NSUInteger) line;
- (NSUInteger) lineNumberForCharacterIndex:(NSUInteger)index;
- (NSArray*)   lineNumbersForRange: (NSRange)range;
- (NSUInteger) characterIndexForLine: (NSUInteger) line;

- (IBAction) shiftLeft: (id)sender;
- (IBAction) shiftRight: (id)sender;

@end
