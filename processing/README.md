processing

A test case which mimics some of the graphics environment
of the Processing.org application.  There are two test cases

test_processing.lua
Puts up a window, and makes some graphics drawing calls

test_RenderGdi.lua
Draws to the GDI port associated with the workstation screen

To execute the test case, cd into the 'test' directory, and type:

tinn test_processing.lua

You should see a window on the screen with a white background, 
and a few graphics primitives (triangle, ellipse, rectangle, text)