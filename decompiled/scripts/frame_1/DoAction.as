function init()
{
   createLineArrays();
   makeSpectrum();
}
function typeChange()
{
   makeSpectrum();
}
function classChange()
{
   numlumClass = classGroup.getValue();
   if(numlumClass == 1)
   {
      lineThickness = 1;
   }
   else if(numlumClass == 3)
   {
      lineThickness = 2;
   }
   else if(numlumClass == 5)
   {
      lineThickness = 3;
   }
   makeSpectrum();
}
function changeChecks()
{
   createArrays();
   makeSpectrum();
}
function changeSpectralType()
{
   createArrays();
   makeSpectrum();
}
function checkState(state)
{
   ihelium_check.setEnabled(state);
   helium_check.setEnabled(state);
   hydrogen_check.setEnabled(state);
   imetals_check.setEnabled(state);
   metals_check.setEnabled(state);
   molecules_check.setEnabled(state);
}
function radioState(state)
{
   class1_radio.setEnabled(state);
   class3_radio.setEnabled(state);
   class5_radio.setEnabled(state);
}
function tempState(state)
{
   if(state == true)
   {
      spectralTypeSlider._visible = true;
      tempLabel._visible = true;
      temperature._visible = true;
   }
   else
   {
      spectralTypeSlider._visible = false;
      tempLabel._visible = false;
      temperature._visible = false;
   }
}
function makeSpectrum()
{
   mySpectra.deleteSpectra();
   mySpectra.createSpectra(0,0);
   if(continuous_radio.getState() == true)
   {
      checkState(false);
      radioState(false);
      tempState(false);
      mySpectra.drawContinuous();
   }
   else if(emission_radio.getState() == true)
   {
      checkState(true);
      radioState(false);
      tempState(false);
      createArrays();
      mySpectra.drawEmission();
      mySpectra.drawColorSet(elementArray,alphaArray,colorArray);
   }
   else
   {
      checkState(true);
      radioState(true);
      tempState(true);
      createArrays();
      mySpectra.drawContinuous();
      mySpectra.drawColorSet(elementArray,alphaArray,colorArray);
   }
}
function createLineArrays()
{
   i = 0;
   while(i < 70)
   {
      if(i < 8)
      {
         iHeLineArray[i] = Math.floor(-12.5 * i + 100);
      }
      else
      {
         iHeLineArray[i] = 0;
      }
      i++;
   }
   i = 0;
   while(i < 70)
   {
      if(i < 8)
      {
         HeLineArray[i] = Math.floor(3.75 * i + 70);
      }
      else if(i < 21)
      {
         HeLineArray[i] = Math.floor(-7.7 * i + 161.7);
      }
      else
      {
         HeLineArray[i] = 0;
      }
      i++;
   }
   i = 0;
   while(i < 70)
   {
      if(i < 7)
      {
         HLineArray[i] = 0;
      }
      else if(i < 20)
      {
         HLineArray[i] = Math.floor(7.7 * i - 53.9);
      }
      else if(i < 54)
      {
         HLineArray[i] = Math.floor(-2.94 * i + 158.7);
      }
      else
      {
         HLineArray[i] = 0;
      }
      i++;
   }
   i = 0;
   while(i < 70)
   {
      if(i < 11)
      {
         imetLineArray[i] = 0;
      }
      else if(i < 38)
      {
         imetLineArray[i] = Math.floor(3.7 * i - 40.7);
      }
      else if(i < 52)
      {
         imetLineArray[i] = Math.floor(-7.14 * i + 371.3);
      }
      else
      {
         imetLineArray[i] = 0;
      }
      i++;
   }
   i = 0;
   while(i < 70)
   {
      if(i < 30)
      {
         metLineArray[i] = 0;
      }
      else if(i < 49)
      {
         metLineArray[i] = Math.floor(5.26 * i - 157.8);
      }
      else if(i < 62)
      {
         metLineArray[i] = Math.floor(-7.7 * i + 477.4);
      }
      else
      {
         metLineArray[i] = 0;
      }
      i++;
   }
   i = 0;
   while(i < 70)
   {
      if(i < 50)
      {
         molLineArray[i] = 0;
      }
      else
      {
         molLineArray[i] = Math.floor(5.26 * i - 263.16);
      }
      i++;
   }
}
function createArrays()
{
   changeTemp(tempSlider.value);
   i = 0;
   while(i < elementArray.length)
   {
      delete elementArray[i];
      delete alphaArray[i];
      delete colorArray[i];
      i++;
   }
   var lineArray = new Array();
   numlumClass = classGroup.getValue();
   if(numlumClass == 1)
   {
      lumClass = "I";
   }
   else if(numlumClass == 3)
   {
      lumClass = "III";
   }
   else if(numlumClass == 5)
   {
      lumClass = "V";
   }
   spectralTypeNumber = spectralTypeSlider.getValue();
   var base = Math.floor(spectralTypeNumber / 10);
   var excess = spectralTypeNumber - 10 * base;
   switch(base)
   {
      case 0:
         type = "O";
         break;
      case 1:
         type = "B";
         break;
      case 2:
         type = "A";
         break;
      case 3:
         type = "F";
         break;
      case 4:
         type = "G";
         break;
      case 5:
         type = "K";
         break;
      case 6:
         type = "M";
         break;
      default:
         return null;
   }
   spectralType = type + String(excess) + String(lumclass);
   temp = getTempFromSpectralType(spectralType);
   temperature.text = String(Math.floor(temp)) + " K";
   if(ihelium_check.getValue())
   {
      iheliumArray = new Array(433.9,454.2,468.6);
      i = 0;
      while(i < iheliumArray.length)
      {
         elementArray.push(iheliumArray[i]);
         if(emission_radio.getState())
         {
            colorArray.push(mySpectra.colorFromLength(iheliumArray[i]));
         }
         else
         {
            colorArray.push(0);
         }
         if(emission_radio.getState() == true)
         {
            alphaArray.push(100);
         }
         else
         {
            alphaArray.push(iHeLineArray[spectralTypeNumber]);
         }
         i++;
      }
   }
   if(helium_check.getValue())
   {
      heliumArray = new Array(402.6,438.8,447.1,706.5);
      i = 0;
      while(i < heliumArray.length)
      {
         elementArray.push(heliumArray[i]);
         if(emission_radio.getState())
         {
            colorArray.push(mySpectra.colorFromLength(heliumArray[i]));
         }
         else
         {
            colorArray.push(0);
         }
         if(emission_radio.getState() == true)
         {
            alphaArray.push(100);
         }
         else
         {
            alphaArray.push(HeLineArray[spectralTypeNumber]);
         }
         i++;
      }
   }
   if(hydrogen_check.getValue())
   {
      hydrogenArray = new Array(397,410.1,434,486.1,656.3);
      i = 0;
      while(i < hydrogenArray.length)
      {
         elementArray.push(hydrogenArray[i]);
         if(emission_radio.getState())
         {
            colorArray.push(mySpectra.colorFromLength(hydrogenArray[i]));
         }
         else
         {
            colorArray.push(0);
         }
         if(emission_radio.getState() == true)
         {
            alphaArray.push(100);
         }
         else
         {
            alphaArray.push(HLineArray[spectralTypeNumber]);
         }
         i++;
      }
   }
   if(imetals_check.getValue())
   {
      imetalsArray = new Array(393.3,396.8,407.7,417.5,421.5,423.3,424.6,426.7,430,444.4,448.1);
      i = 0;
      while(i < imetalsArray.length)
      {
         elementArray.push(imetalsArray[i]);
         if(emission_radio.getState())
         {
            colorArray.push(mySpectra.colorFromLength(imetalsArray[i]));
         }
         else
         {
            colorArray.push(0);
         }
         if(emission_radio.getState() == true)
         {
            alphaArray.push(100);
         }
         else
         {
            alphaArray.push(imetLineArray[spectralTypeNumber]);
         }
         i++;
      }
   }
   if(metals_check.getValue())
   {
      metalsArray = new Array(403.2,404.5,432.5,422.6,589);
      i = 0;
      while(i < metalsArray.length)
      {
         elementArray.push(metalsArray[i]);
         if(emission_radio.getState())
         {
            colorArray.push(mySpectra.colorFromLength(metalsArray[i]));
         }
         else
         {
            colorArray.push(0);
         }
         if(emission_radio.getState() == true)
         {
            alphaArray.push(100);
         }
         else
         {
            alphaArray.push(metLineArray[spectralTypeNumber]);
         }
         i++;
      }
   }
   if(molecules_check.getValue())
   {
      moleculesArray = new Array(421.5,430,458.4,462.5,467,469.7,467,478);
      i = 0;
      while(i < moleculesArray.length)
      {
         elementArray.push(moleculesArray[i]);
         if(emission_radio.getState())
         {
            colorArray.push(mySpectra.colorFromLength(moleculesArray[i]));
         }
         else
         {
            colorArray.push(0);
         }
         if(emission_radio.getState() == true)
         {
            alphaArray.push(100);
         }
         else
         {
            alphaArray.push(molLineArray[spectralTypeNumber]);
         }
         i++;
      }
   }
}
function getTempFromSpectralType(type)
{
   spectralTypesAndTemps = {v:[{type:7,teff:38000},{type:9,teff:33200},{type:9.5,teff:31450},{type:10,teff:29700},{type:11,teff:25600},{type:12,teff:22300},{type:13,teff:19000},{type:14,teff:17200},{type:15,teff:15400},{type:16,teff:14100},{type:17,teff:13000},{type:18,teff:11800},{type:19,teff:10700},{type:20,teff:9480},{type:22,teff:8810},{type:25,teff:8160},{type:27,teff:7930},{type:30,teff:7020},{type:32,teff:6750},{type:35,teff:6530},{type:37,teff:6240},{type:40,teff:5930},{type:42,teff:5830},{type:44,teff:5740},{type:46,teff:5620},{type:50,teff:5240},{type:52,teff:5010},{type:54,teff:4560},{type:55,teff:4340},{type:57,teff:4040},{type:60,teff:3800},{type:61,teff:3680},{type:62,teff:3530},{type:63,teff:3380},{type:64,teff:3180},{type:65,teff:3030},{type:66,teff:2850}],iii:[{type:40,teff:5910},{type:44,teff:5190},{type:46,teff:5050},{type:48,teff:4960},{type:50,teff:4810},{type:51,teff:4610},{type:52,teff:4500},{type:53,teff:4320},{type:54,teff:4080},{type:55,teff:3980},{type:60,teff:3820},{type:61,teff:3780},{type:62,teff:3710},{type:63,teff:3630},{type:64,teff:3560},{type:65,teff:3420},{type:66,teff:3250}],i:[{type:9,teff:32500},{type:10,teff:26000},{type:11,teff:20700},{type:12,teff:17800},{type:13,teff:15600},{type:14,teff:13900},{type:15,teff:13400},{type:16,teff:12700},{type:17,teff:12000},{type:18,teff:11200},{type:19,teff:10500},{type:20,teff:9730},{type:21,teff:9230},{type:22,teff:9080},{type:25,teff:8510},{type:30,teff:7700},{type:32,teff:7170},{type:35,teff:6640},{type:38,teff:6100},{type:40,teff:5510},{type:43,teff:4980},{type:48,teff:4590},{type:50,teff:4420},{type:51,teff:4330},{type:52,teff:4260},{type:53,teff:4130},{type:55,teff:3850},{type:60,teff:3650},{type:61,teff:3550},{type:62,teff:3450},{type:63,teff:3200},{type:64,teff:2980}]};
   var parts = type.split(" ");
   var fullString = parts[0];
   var i = 1;
   while(i < parts.length)
   {
      fullString += parts[i];
      i++;
   }
   fullString = fullString.toLowerCase();
   var type = fullString.charAt(0);
   if(type == "o")
   {
      var spectralTypeNumber = 0;
   }
   else if(type == "b")
   {
      var spectralTypeNumber = 10;
   }
   else if(type == "a")
   {
      var spectralTypeNumber = 20;
   }
   else if(type == "f")
   {
      var spectralTypeNumber = 30;
   }
   else if(type == "g")
   {
      var spectralTypeNumber = 40;
   }
   else if(type == "k")
   {
      var spectralTypeNumber = 50;
   }
   else
   {
      if(type != "m")
      {
         return null;
      }
      var spectralTypeNumber = 60;
   }
   var firstNumberIndex = Infinity;
   var i = 0;
   while(i < 10)
   {
      var tmp = fullString.indexOf(String(i));
      if(tmp != -1)
      {
         if(tmp < firstNumberIndex)
         {
            firstNumberIndex = tmp;
         }
      }
      i++;
   }
   if(firstNumberIndex == Infinity)
   {
      spectralTypeNumber += 5;
      var §class§ = fullString.slice(1);
   }
   else
   {
      var lastNumberIndex = firstNumberIndex;
      var i = 0;
      while(i < 10)
      {
         var tmp = fullString.lastIndexOf(String(i));
         if(tmp > lastNumberIndex)
         {
            lastNumberIndex = tmp;
         }
         i++;
      }
      var num = parseFloat(fullString.slice(firstNumberIndex,lastNumberIndex + 1));
      if(num < 0 || num >= 10 || isNaN(num) || !isFinite(num))
      {
         return null;
      }
      spectralTypeNumber += num;
      var §class§ = fullString.slice(lastNumberIndex + 1);
   }
   if(eval("class") == "")
   {
      set("class","v");
   }
   var aIndex = eval("class").indexOf("a");
   if(aIndex > 0)
   {
      set("class",eval("class").slice(0,aIndex));
   }
   var bIndex = eval("class").indexOf("b");
   if(bIndex > 0)
   {
      set("class",eval("class").slice(0,bIndex));
   }
   if(eval("class") == "iv")
   {
      set("class","v");
   }
   else if(eval("class") == "ii")
   {
      set("class","i");
   }
   else if(eval("class") == "iii" && spectralTypeNumber < 40)
   {
      set("class","v");
   }
   var tempsArray = spectralTypesAndTemps[eval("class")];
   if(tempsArray == undefined)
   {
      return null;
   }
   var len = tempsArray.length;
   var i = 0;
   while(i < len)
   {
      if(spectralTypeNumber < tempsArray[i].type)
      {
         break;
      }
      i++;
   }
   if(i == 0)
   {
      var i1 = 0;
      var i2 = 1;
   }
   else if(i == len)
   {
      var i1 = len - 2;
      var i2 = len - 1;
   }
   else
   {
      var i1 = i - 1;
      var i2 = i;
   }
   var m = (tempsArray[i2].teff - tempsArray[i1].teff) / (tempsArray[i2].type - tempsArray[i1].type);
   var b = tempsArray[i1].teff - m * tempsArray[i1].type;
   temp = m * spectralTypeNumber + b;
   return temp;
}
var elementArray = new Array();
var alphaArray = new Array();
var colorArray = new Array();
var iHeLineArray = new Array();
var HeLineArray = new Array();
var HLineArray = new Array();
var imetLineArray = new Array();
var metLineArray = new Array();
var molLineArray = new Array();
var lineThickness = 3;
init();
stop();
