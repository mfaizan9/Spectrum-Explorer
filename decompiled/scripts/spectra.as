function spectraClass()
{
   this._lineCount = 0;
   this._spectX = 0;
   this._spectY = 0;
   this.fillType = "linear";
   this.colors = [16711680,16753920,16776960,65280,65535,255,8388736];
   this.alphas = [100,100,100,100,100,100,100];
   var purPos = this.spectPos(400);
   var bluPos = this.spectPos(445);
   var cynPos = this.spectPos(475);
   var grnPos = this.spectPos(510);
   var yelPos = this.spectPos(570);
   var orgPos = this.spectPos(590);
   var redPos = this.spectPos(700);
   this.ratios = [redPos,orgPos,yelPos,grnPos,cynPos,bluPos,purPos];
}
var p = spectraClass.prototype = new MovieClip();
Object.registerClass("spectra",spectraClass);
p.spectPos = function(wavelength)
{
   return 255 - (wavelength - 395) * 0.8225806451612904;
};
p.colorFromLength = function(wavelength)
{
   var clr = 0;
   if(wavelength < 430)
   {
      clr = 10485920;
   }
   else if(wavelength < 460)
   {
      clr = 255;
   }
   else if(wavelength < 495)
   {
      clr = 65535;
   }
   else if(wavelength < 540)
   {
      clr = 65280;
   }
   else if(wavelength < 580)
   {
      clr = 16776960;
   }
   else if(wavelength < 620)
   {
      clr = 16753920;
   }
   else
   {
      clr = 16711680;
   }
   return clr;
};
p.xPos = function(wavelength)
{
   return this.spectPos(wavelength) * 1.9607843137254901 + this.spectX;
};
p.deleteSpectra = function()
{
   this.removeMovieClip("spectraBox");
};
p.createSpectra = function(xPost, yPost)
{
   this.spectX = xPost;
   this.spectY = yPost;
   this.matrix = {matrixType:"box",x:this.spectX,y:this.spectY,w:500,h:50,r:0};
   this.createEmptyMovieClip("spectraBox",1);
};
p.drawContinuous = function()
{
   this.spectraBox.moveTo(this.spectX,this.spectY);
   this.spectraBox.beginGradientFill(this.fillType,this.colors,this.alphas,this.ratios,this.matrix);
   this.spectraBox.lineTo(this.spectX + 500,this.spectY);
   this.spectraBox.lineTo(this.spectX + 500,this.spectY + 50);
   this.spectraBox.lineTo(this.spectX,this.spectY + 50);
   this.spectraBox.lineTo(this.spectX,this.spectY);
   this.spectraBox.endFill();
};
p.drawEmission = function()
{
   this.spectraBox.moveTo(this.spectX,this.spectY);
   this.spectraBox.beginFill(0,100);
   this.spectraBox.lineTo(this.spectX + 500,this.spectY);
   this.spectraBox.lineTo(this.spectX + 500,this.spectY + 50);
   this.spectraBox.lineTo(this.spectX,this.spectY + 50);
   this.spectraBox.lineTo(this.spectX,this.spectY);
   this.spectraBox.endFill();
};
p.drawColorLineAt = function(wavelength, lineNum, alpha, color)
{
   this.SpectraBox.createEmptyMovieClip("spectLine",lineNum);
   var wavelgth;
   if(wavelength == "red")
   {
      wavelgth = 650;
   }
   else if(wavelength == "orange")
   {
      wavelgth = 590;
   }
   else if(wavelength == "yellow")
   {
      wavelgth = 570;
   }
   else if(wavelength == "green")
   {
      wavelgth = 510;
   }
   else if(wavelength == "blue")
   {
      wavelgth = 445;
   }
   else if(wavelength == "cyan")
   {
      wavelgth = 475;
   }
   else if(wavelength == "purple")
   {
      wavelgth = 400;
   }
   else if(wavelength >= 395 && wavelength <= 705)
   {
      wavelgth = wavelength;
   }
   else if(wavelength < 400)
   {
      wavelgth = 400;
   }
   else
   {
      wavelgth = 700;
   }
   this.SpectraBox.spectLine.moveTo(this.xPos(wavelgth),this.spectY);
   this.SpectraBox.spectLine.lineStyle(lineThickness,color,alpha);
   this.SpectraBox.spectLine.lineTo(this.xPos(wavelgth),this.spectY + 50);
};
p.drawColorSet = function(elementArray, alphaArray, colorArray)
{
   var lineCount = 1;
   i = 0;
   while(i < elementArray.length)
   {
      if(alphaArray[i] > 10)
      {
         lineCount++;
         this.drawColorLineAt(parseInt(elementArray[i]),lineCount,alphaArray[i],colorArray[i]);
      }
      i++;
   }
};
p.setX = function(arg)
{
   this._spectX = arg;
};
p.getX = function()
{
   return this._spectX;
};
p.setY = function(arg)
{
   this._spectY = arg;
};
p.getY = function()
{
   return this._spectY;
};
p.addProperty("spectX",p.getX,p.setX);
p.addProperty("spectY",p.getY,p.setY);
