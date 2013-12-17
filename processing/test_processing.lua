local Processing = require("Processing")

function setup()
	print("SETUP")
end

function draw()
	triangle(width/2/2,0, 0,height/2, width/2,height/2)
	rect((width/2)+1,0,(width/2)-2, height/2)
	ellipse((width/2/2), (height/2)+(height/4), width/2, height/2)
	text(width/2, height/2, string.format("Hello, World!: %s", frameCount))
end

begin();
