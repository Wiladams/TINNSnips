//*** Rock Object Prototype

function Rock(scale, type) {
	
	//scale
	//1=large
	//2=medium
	//3=small
	//these will be used as the devisor for the new size
	//50/1=50
	//50/2=25
	//50/3=16
	
	this.scale=scale;
	if (this.scale <1 || this.scale >3){
		this.scale=1;
	}
	this.type = type;
	this.dx=0;
	this.dy=0;
	this.x=0;
	this.y=0;
	this.rotation=0;
	this.rotationInc=0;
	this.scoreValue=0;
	
	//ConsoleLog.log("create rock. Scale=" + this.scale);
	switch(this.scale){
		
		case 1:
			this.width=50;
			this.height=50;
			break;
		case 2:
			this.width=25;
			this.height=25;
			break;
		case 3:
			this.width=16;
			this.height=16;
			break;
	}
	
}


Rock.prototype.update=function(xmin,xmax,ymin,ymax) {
	this.x+=this.dx;
	this.y+=this.dy;
	this.rotation+=this.rotationInc;
	if (this.x > xmax) {
		this.x=xmin-this.width;
	}else if (this.x<xmin-this.width){
		this.x=xmax;
	}
	
	if (this.y > ymax) {
		this.y=ymin-this.width;
	}else if (this.y<ymin-this.width){
		this.y=ymax;
	}
}

Rock.prototype.draw=function(context) {
	
	
	var angleInRadians = this.rotation * Math.PI / 180;
	var halfWidth=Math.floor(this.width*.5); //used to find center of object
	var halfHeight=Math.floor(this.height*.5)// used to find center of object
	context.save(); //save current state in stack 
	context.setTransform(1,0,0,1,0,0); // reset to identity
	
	//translate the canvas origin to the center of the player
	context.translate(this.x+halfWidth,this.y+halfHeight);
	context.rotate(angleInRadians);
	context.strokeStyle = '#ffffff';
	
	context.beginPath();
	
	//draw everything offset by 1/2. Zero Relative 1/2 is if .5*width -1. Same for height
	
	context.moveTo(-(halfWidth-1),-(halfHeight-1)); 
	context.lineTo((halfWidth-1),-(halfHeight-1));
	context.lineTo((halfWidth-1),(halfHeight-1));
	context.lineTo(-(halfWidth-1),(halfHeight-1));
	context.lineTo(-(halfWidth-1),-(halfHeight-1));
	
	context.stroke();
	context.closePath();
	context.restore(); //pop old state on to screen
	
}


//*** end Rock Class