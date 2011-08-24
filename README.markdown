
Hcode: The Haskell Editor
=========================

Hcode is meant to be a spartan editor for the purpose of editing 
Haskell source code for MacOS X.

It is written using Cocoa/Objective-C to give the best Mac experience 
I can envision. I have some vision of what I want to do with this editor,
and in preparation of this, I have done the minimal necessary to ensure this 
compiles with XCode 4 on Lion. In doing so, no new functionality has been
introduced, but going forward Lion will be required to run Hcode.

To compile Hcode as it is now, requires the latest XCode tools available
to paid developers, due to some technologies available now from clang.

What I intend to do, as time and ability permits, is to implement a single
window interface that allows some basic project management through opening
a folder and having a cabal file inside.

The ability to run and view the output of the Haskell program is very important. 
I must study the best way to do this.

The original code from 19 May 2010 said this:

    The initial README file for this program referenced the GPL. Because
    I have added BWToolkit (provides some modern UI elements) and have
    made use of a class from NoodleKit, and both of these are licensed 
    the same way; I have decided to license this code in the same way.

However, as part of the transition to XCode 4 and Lion, the BWToolkit will be removed
with a possible retention of a single class that I have used from it. BWToolkit is also 
not safe to use on the AppStore - which I believe Hcode would go for ease of finding 
if and when it becomes a usable product.

Release Notes:
--------------

    24 Aug 2011 No, this is not α3. This is a port to Lion and some other new compiler technology.

				This commit, is to enable this aging unfinished project 
				to compile on a more modern system. I have been thinking
				about some things going forward. See above for more details.
                

    19 May 2010	A week ago I released α2, and I am almost done α3.
	
				Just added the ability to run a command as a script
				using the Build/Build and Run menu item. It must have
				a #! on the first line to do anything.
				
				Also added is a console (Build/Show Console) that will
				receive the output from the program ran. It autoscrolls.
				
				As a sample program, try this:
				
					#!/usr/bin/env runhaskell

					import Control.Concurrent

					main :: IO ()
					main = do    
						putStrLn "This is a test"
						threadDelay 1000
						main
						
				Please try to break it. I would appreciate some input 
				from more experienced developers. Although the function
				that runs the script is very haphazard now, the 
				functionality isn't quite done – but the design is mostly
				there.
    


Requirements to Build
---------------------

Some of the controls are from the excellent BWToolkit, and to edit 
in Interface Builder, it requires a plugin. You can obtain it [here](http://brandonwalkin.com/bwtoolkit/).

To build, open the Xcode project 'Hcode.xcode' and select 
'Build and Run' from the toolbar.

License
-------

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.



	