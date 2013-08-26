%% Intitialize Graphical User Interface

  this = framework('example.cfg');

  % get handle from axes a1
  hAxes = this.getHandle('a1');
  
  % select axes a1
  axes(hAxes)
  
  % print matlab logo in axes a1
  membrane
  
  % save gui handle in roots (handle 0) appdata to make it accessible from
  % different places
  setappdata(0,'hGui',this);
  
  % restore gui handle from root
  hGui = getappdata(0,'hGui');
  
  % get handle from static text s1
  hS1 = hGui.getHandle('s1');
  
  % manipulate posititon and text of static text s1
  set(hS1,'String','this text has been changed','Position',[300 300 80 50]);
  
