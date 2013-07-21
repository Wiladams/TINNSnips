function TextButton(x,y,text, width, height, backColor, strokeColor, overColor, textColor){
    this.x=x;
    this.y=y;
    this.text=text;
    this.width=width;
    this.height=height;
    this.backColor=backColor;
    this.strokeColor=strokeColor;
    this.overColor=overColor;
    this.textColor=textColor;
    this.press=false;
}

TextButton.prototype.pressDown=function() {
    if (this.press==true){
        this.press=false;
    }else{
        this.press=true;
    }
}

TextButton.prototype.draw=function(context){
    
    context.save();
    context.setTransform(1,0,0,1,0,0); // reset to identity
    context.translate(this.x, this.y);
  
    context.shadowOffsetX=3;
    context.shadowOffsetY=3;
    context.shadowBlur=3;
    context.shadowColor="#222222";
    
    context.lineWidth=4;
    context.lineJoin='round';
    context.strokeStyle=this.strokeColor;
    
    if (this.press==true){
        context.fillStyle=this.overColor;
    }else{
       context.fillStyle=this.backColor;
    }
    
    context.strokeRect(0, 0, this.width,this.height);
    context.fillRect(0, 0, this.width,this.height);
    
    
    //text
    context.shadowOffsetX=1;
    context.shadowOffsetY=1;
    context.shadowBlur=1;
    context.shadowColor="#ffffff";
    context.font =  "14px serif" 
    context.fillStyle    = this.textColor;
    context.textAlign="center";
    context.textBaseline="middle";
    var metrics = context.measureText(this.text)
    var textWidth = metrics.width;
    var xPosition =  this.width/2;
    var yPosition = (this.height/2);
    
    var splitText=this.text.split('\n');
    var verticalSpacing=14;
    console.log("text=" + this.text)
    console.log("text split length=" + splitText.length)
    
    for (var ctr1=0; ctr1<splitText.length;ctr1++) {
        context.fillText  ( splitText[ctr1],  xPosition, yPosition+ (ctr1*verticalSpacing));
    }
    
    
   
    
    context.restore();
    
}



