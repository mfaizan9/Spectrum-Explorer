function FRadioButtonClass()
{
   this.init();
}
function FRadioButtonGroupClass()
{
   this.radioInstances = new Array();
}
FRadioButtonClass.prototype = new FUIComponentClass();
FRadioButtonGroupClass.prototype = new FUIComponentClass();
Object.registerClass("FRadioButtonSymbol",FRadioButtonClass);
FRadioButtonClass.prototype.init = function()
{
   if(this.initialState == undefined)
   {
      this.selected = false;
   }
   else
   {
      this.selected = this.initialState;
   }
   super.setSize(this._width,this._height);
   this.boundingBox_mc.unloadMovie();
   this.boundingBox_mc._width = 0;
   this.boundingBox_mc._height = 0;
   this.attachMovie("frb_hitArea","frb_hitArea_mc",1);
   this.attachMovie("frb_states","frb_states_mc",2);
   this.attachMovie("FLabelSymbol","fLabel_mc",3);
   super.init();
   this._xscale = 100;
   this._yscale = 100;
   this.setSize(this.width,this.height);
   this.setChangeHandler(this.changeHandler);
   if(this.label != undefined)
   {
      this.setLabel(this.label);
   }
   if(this.initialState == undefined)
   {
      this.setValue(false);
   }
   else
   {
      this.setValue(this.initialState);
   }
   if(this.data == "")
   {
      this.data = undefined;
   }
   else
   {
      this.setData(this.data);
   }
   this.addToRadioGroup();
   this.ROLE_SYSTEM_RADIOBUTTON = 45;
   this.STATE_SYSTEM_SELECTED = 16;
   this.EVENT_OBJECT_STATECHANGE = 32778;
   this.EVENT_OBJECT_NAMECHANGE = 32780;
   this._accImpl.master = this;
   this._accImpl.stub = false;
   this._accImpl.get_accRole = this.get_accRole;
   this._accImpl.get_accName = this.get_accName;
   this._accImpl.get_accState = this.get_accState;
   this._accImpl.get_accDefaultAction = this.get_accDefaultAction;
   this._accImpl.accDoDefaultAction = this.accDoDefaultAction;
};
FRadioButtonClass.prototype.setHitArea = function(w, h)
{
   var hit = this.frb_hitArea_mc;
   this.hitArea = hit;
   if(this.frb_states_mc._width > w)
   {
      hit._width = this.frb_states_mc._width;
   }
   else
   {
      hit._width = w;
   }
   hit._visible = false;
   if(arguments.length > 1)
   {
      hit._height = h;
   }
};
FRadioButtonClass.prototype.txtFormat = function(pos)
{
   var txtS = this.textStyle;
   var sTbl = this.styleTable;
   txtS.align = sTbl.textAlign.value != undefined ? undefined : (txtS.align = pos);
   txtS.leftMargin = sTbl.textLeftMargin.value != undefined ? undefined : (txtS.leftMargin = 0);
   txtS.rightMargin = sTbl.textRightMargin.value != undefined ? undefined : (txtS.rightMargin = 0);
   if(this.flabel_mc._height > this.height)
   {
      super.setSize(this.width,this.flabel_mc._height);
   }
   else
   {
      super.setSize(this.width,this.height);
   }
   this.setEnabled(this.enable);
};
FRadioButtonClass.prototype.setSize = function(w, h)
{
   this.setLabel(this.getLabel());
   this.setLabelPlacement(this.labelPlacement);
   if(this.frb_states_mc._height < this.flabel_mc.labelField._height)
   {
      super.setSize(w,this.flabel_mc.labelField._height);
   }
   this.setHitArea(this.width,this.height);
   this.setLabelPlacement(this.labelPlacement);
};
FRadioButtonClass.prototype.setLabelPlacement = function(pos)
{
   this.setLabel(this.getLabel());
   this.txtFormat(pos);
   var halfLabelH = this.fLabel_mc._height / 2;
   var halfFrameH = this.frb_states_mc._height / 2;
   var vertCenter = halfFrameH - halfLabelH;
   var radioWidth = this.frb_states_mc._width;
   var frame = this.frb_states_mc;
   var label = this.fLabel_mc;
   var w = this.width - frame._width;
   if(frame._width > this.width)
   {
      w = 0;
   }
   else
   {
      w = this.width - frame._width;
   }
   this.fLabel_mc.setSize(w);
   if(pos == "right" || pos == undefined)
   {
      this.labelPlacement = "right";
      this.frb_states_mc._x = 0;
      this.fLabel_mc._x = radioWidth;
      this.txtFormat("left");
   }
   else if(pos == "left")
   {
      this.labelPlacement = "left";
      this.fLabel_mc._x = 0;
      this.frb_states_mc._x = this.width - radioWidth;
      this.txtFormat("right");
   }
   this.fLabel_mc._y = vertCenter;
   this.frb_hitArea_mc._y = vertCenter;
   this.setLabel(this.getLabel());
};
FRadioButtonClass.prototype.setData = function(dataValue)
{
   this.data = dataValue;
};
FRadioButtonClass.prototype.getData = function()
{
   return this.data;
};
FRadioButtonClass.prototype.getState = function()
{
   return this.selected;
};
FRadioButtonClass.prototype.getSize = function()
{
   return this.width;
};
FRadioButtonClass.prototype.getGroupName = function()
{
   return this.groupName;
};
FRadioButtonClass.prototype.setGroupName = function(groupName)
{
   var i = 0;
   while(i < this._parent[this.groupName].radioInstances.length)
   {
      if(this._parent[this.groupName].radioInstances[i] == this)
      {
         delete this._parent[this.groupName].radioInstances[i];
      }
      i++;
   }
   this.groupName = groupName;
   this.addToRadioGroup();
};
FRadioButtonClass.prototype.addToRadioGroup = function()
{
   if(this._parent[this.groupName] == undefined)
   {
      this._parent[this.groupName] = new FRadioButtonGroupClass();
   }
   this._parent[this.groupName].addRadioInstance(this);
};
FRadioButtonClass.prototype.setValue = function(selected)
{
   if(selected || selected == undefined)
   {
      this.setState(true);
      this.focusRect.removeMovieClip();
      this.executeCallBack();
   }
   else if(selected == false)
   {
      this.setState(false);
   }
};
FRadioButtonClass.prototype.setTabState = function(selected)
{
   Selection.setFocus(this);
   this.setState(selected);
   this.drawFocusRect();
   this.executeCallBack();
};
FRadioButtonClass.prototype.setState = function(selected)
{
   if(selected || selected == undefined)
   {
      this.tabEnabled = true;
      for(var i in this._parent)
      {
         if(this != this._parent[i] && this._parent[i].groupName == this.groupName)
         {
            this._parent[i].setState(false);
            this._parent[i].tabEnabled = false;
         }
      }
   }
   if(this.enable)
   {
      this.flabel_mc.setEnabled(true);
      if(selected || selected == undefined)
      {
         this.frb_states_mc.gotoAndStop("selectedEnabled");
         this.enabled = false;
         this.selected = true;
         this.tabEnabled = true;
         this.tabFocused = true;
      }
      else
      {
         this.frb_states_mc.gotoAndStop("unselectedEnabled");
         this.enabled = true;
         this.selected = false;
         this.tabEnabled = false;
         var enabTrue = this._parent[this.groupName].getEnabled();
         var noneSelect = this._parent[this.groupName].getValue() == undefined;
         if(enabTrue && noneSelect)
         {
            this._parent[this.groupName].radioInstances[0].tabEnabled = true;
         }
      }
   }
   else
   {
      this.flabel_mc.setEnabled(false);
      if(selected || selected == undefined)
      {
         this.frb_states_mc.gotoAndStop("selectedDisabled");
         this.enabled = false;
         this.selected = true;
         this.tabEnabled = false;
      }
      else
      {
         this.frb_states_mc.gotoAndStop("unselectedDisabled");
         this.enabled = false;
         this.selected = false;
         this.tabEnabled = false;
      }
   }
   if(Accessibility.isActive())
   {
      Accessibility.sendEvent(this,0,this.EVENT_OBJECT_STATECHANGE,true);
   }
};
FRadioButtonClass.prototype.getValue = function()
{
   if(this.selected)
   {
      if(this.data == "" || this.data == undefined)
      {
         return this.getLabel();
      }
      return this.data;
   }
};
FRadioButtonClass.prototype.setEnabled = function(enable)
{
   if(enable == true || enable == undefined)
   {
      this.enable = true;
      super.setEnabled(true);
   }
   else
   {
      this.enable = false;
      super.setEnabled(false);
   }
   this.setState(this.selected);
   var cgn = this._parent[this.groupName].getEnabled() == undefined;
   var cgnez = this._parent[this.groupName].radioInstances[0].getEnabled() == false;
   if(cgn && cgnez)
   {
      var i = 0;
      while(i < this._parent[this.groupName].radioInstances.length)
      {
         if(this._parent[this.groupName].radioInstances[i].getEnabled() == true)
         {
            this._parent[this.groupName].radioInstances[i].tabEnabled = true;
            return undefined;
         }
         i++;
      }
   }
};
FRadioButtonClass.prototype.getEnabled = function()
{
   return this.enable;
};
FRadioButtonClass.prototype.setLabel = function(label)
{
   this.fLabel_mc.setLabel(label);
   this.txtFormat();
   if(Accessibility.isActive())
   {
      Accessibility.sendEvent(this,0,this.EVENT_OBJECT_NAMECHANGE);
   }
};
FRadioButtonClass.prototype.getLabel = function()
{
   return this.fLabel_mc.getLabel();
};
FRadioButtonClass.prototype.onPress = function()
{
   this.pressFocus();
   this.frb_states_mc.gotoAndStop("press");
};
FRadioButtonClass.prototype.onRelease = function()
{
   this.frb_states_mc.gotoAndStop("unselectedDisabled");
   this.setValue(!this.selected);
};
FRadioButtonClass.prototype.onReleaseOutside = function()
{
   this.frb_states_mc.gotoAndStop("unselectedEnabled");
};
FRadioButtonClass.prototype.onDragOut = function()
{
   this.frb_states_mc.gotoAndStop("unselectedEnabled");
};
FRadioButtonClass.prototype.onDragOver = function()
{
   this.frb_states_mc.gotoAndStop("press");
};
FRadioButtonClass.prototype.executeCallBack = function()
{
   this.handlerObj[this.changeHandler](this._parent[this.groupName]);
};
FRadioButtonGroupClass.prototype.addRadioInstance = function(instance)
{
   this.radioInstances.push(instance);
   this.radioInstances[0].tabEnabled = true;
};
FRadioButtonGroupClass.prototype.setEnabled = function(enableFlag)
{
   var i = 0;
   while(i < this.radioInstances.length)
   {
      this.radioInstances[i].setEnabled(enableFlag);
      i++;
   }
};
FRadioButtonGroupClass.prototype.getEnabled = function()
{
   var i = 0;
   while(i < this.radioInstances.length)
   {
      if(this.radioInstances[i].getEnabled() != this.radioInstances[0].getEnabled())
      {
         return undefined;
      }
      i++;
   }
   return this.radioInstances[0].getEnabled();
};
FRadioButtonGroupClass.prototype.setChangeHandler = function(changeHandler, obj)
{
   var i = 0;
   while(i < this.radioInstances.length)
   {
      this.radioInstances[i].setChangeHandler(changeHandler,obj);
      i++;
   }
};
FRadioButtonGroupClass.prototype.getValue = function()
{
   var i = 0;
   while(i < this.radioInstances.length)
   {
      if(this.radioInstances[i].selected == true)
      {
         if(this.radioInstances[i].data == "" || this.radioInstances[i].data == undefined)
         {
            return this.radioInstances[i].getLabel();
         }
         return this.radioInstances[i].data;
      }
      i++;
   }
};
FRadioButtonGroupClass.prototype.getData = function()
{
   var i = 0;
   while(i < this.radioInstances.length)
   {
      if(this.radioInstances[i].selected)
      {
         return this.radioInstances[i].getData();
      }
      i++;
   }
};
FRadioButtonGroupClass.prototype.getInstance = function()
{
   var i = 0;
   while(i < this.radioInstances.length)
   {
      if(this.radioInstances[i].selected == true)
      {
         return i;
      }
      undefined;
      i++;
   }
};
FRadioButtonGroupClass.prototype.setValue = function(dataValue)
{
   var i = 0;
   while(i < this.radioInstances.length)
   {
      if(this.radioInstances[i].data == dataValue)
      {
         this.radioInstances[i].setValue(true);
         return undefined;
      }
      i++;
   }
   var i = 0;
   while(i < this.radioInstances.length)
   {
      if(this.radioInstances[i].getLabel() == dataValue)
      {
         this.radioInstances[i].setValue(true);
      }
      i++;
   }
};
FRadioButtonGroupClass.prototype.setSize = function(w)
{
   var i = 0;
   while(i < this.radioInstances.length)
   {
      this.radioInstances[i].setSize(w);
      i++;
   }
};
FRadioButtonGroupClass.prototype.getSize = function()
{
   var widestRadio = 0;
   var i = 0;
   while(i < this.radioInstances.length)
   {
      if(this.radioInstances[i].width >= widestRadio)
      {
         widestRadio = this.radioInstances[i].width;
      }
      i++;
   }
   return widestRadio;
};
FRadioButtonGroupClass.prototype.setGroupName = function(groupName)
{
   this.oldGroupName = this.radioInstances[0].groupName;
   var i = 0;
   while(i < this.radioInstances.length)
   {
      this.radioInstances[i].groupName = groupName;
      this.radioInstances[i].addToRadioGroup();
      i++;
   }
   delete this._parent[this.oldGroupName];
};
FRadioButtonGroupClass.prototype.getGroupName = function()
{
   return this.radioInstances[0].groupName;
};
FRadioButtonGroupClass.prototype.setLabelPlacement = function(pos)
{
   var i = 0;
   while(i < this.radioInstances.length)
   {
      this.radioInstances[i].setLabelPlacement(pos);
      i++;
   }
};
FRadioButtonGroupClass.prototype.setStyleProperty = function(propName, value, isGlobal)
{
   var i = 0;
   while(i < this.radioInstances.length)
   {
      this.radioInstances[i].setStyleProperty(propName,value,isGlobal);
      i++;
   }
};
FRadioButtonGroupClass.prototype.addListener = function()
{
   var i = 0;
   while(i < this.radioInstances.length)
   {
      this.radioInstances[i].addListener();
      i++;
   }
};
FRadioButtonGroupClass.prototype.applyChanges = function()
{
   var i = 0;
   while(i < this.radioInstances.length)
   {
      this.radioInstances[i].applyChanges();
      i++;
   }
};
FRadioButtonGroupClass.prototype.removeListener = function(component)
{
   var i = 0;
   while(i < this.radioInstances.length)
   {
      this.radioInstances[i].removeListener(component);
      i++;
   }
};
FRadioButtonClass.prototype.drawFocusRect = function()
{
   this.drawRect(-2,-2,this._width + 6,this._height - 3);
};
FRadioButtonClass.prototype.myOnKillFocus = function()
{
   Key.removeListener(this.keyListener);
   this.focused = false;
   this.focusRect.removeMovieClip();
   this._parent[this.groupName].foobar = 0;
};
FRadioButtonClass.prototype.myOnKeyDown = function()
{
   if(Key.getCode() == 32 && this._parent[this.groupName].getValue() == undefined)
   {
      if(this._parent[this.groupName].radioInstances[0] == this)
      {
         this.setTabState(true);
      }
   }
   if(Key.getCode() == 40 && this.pressOnce == undefined)
   {
      this.foobar = this._parent[this.groupName].getInstance();
      var i = this.foobar;
      while(i < this._parent[this.groupName].radioInstances.length)
      {
         var inc = i + 1;
         if(this._parent[this.groupName].radioInstances[inc].getEnabled())
         {
            this._parent[this.groupName].radioInstances[inc].setTabState(true);
            return undefined;
         }
         i++;
      }
   }
   if(Key.getCode() == 38 && this.pressOnce == undefined)
   {
      this.foobar = this._parent[this.groupName].getInstance();
      var i = this.foobar;
      while(i >= 0)
      {
         var inc = i - 1;
         if(this._parent[this.groupName].radioInstances[inc].getEnabled())
         {
            this._parent[this.groupName].radioInstances[inc].setTabState(true);
            return undefined;
         }
         i--;
      }
   }
};
FRadioButtonClass.prototype.get_accRole = function(childId)
{
   return this.master.ROLE_SYSTEM_RADIOBUTTON;
};
FRadioButtonClass.prototype.get_accName = function(childId)
{
   return this.master.getLabel();
};
FRadioButtonClass.prototype.get_accState = function(childId)
{
   if(this.master.getState())
   {
      return this.master.STATE_SYSTEM_SELECTED;
   }
   return 0;
};
FRadioButtonClass.prototype.get_accDefaultAction = function(childId)
{
   if(this.master.getState())
   {
      return "UnCheck";
   }
   return "Check";
};
FRadioButtonClass.prototype.accDoDefaultAction = function(childId)
{
   this.master.setValue(!this.master.getValue());
};
