classdef framework < handle
  %framework Provide a class for a easy configurable gui 
  %
  properties(Access = public)
    
    hMainWindow;
    hParent;
    packageName;
    handles;
    state;

  end
  
  
  methods(Access = public)

    % constructor
    function this = framework(config, packageName, hParent)
    %FRAMEWORK initiate the GUI and parse the config file
    %  arguments: - config: name of the configuration file (string)
    %             - packageName: the name for the preconfigured gui, '' 
    %               for placing the callbacks in the main dir (string)
      
      % surpress uitabgroup warning
      s = warning('off', 'MATLAB:uitabgroup:OldVersion');
      
      % initialize handles and state
      this.handles = {};
      this.state = [];
      
      % set package name
      this.packageName = packageName;
      
      % parse config file      
      this.parseConfig(config);
      
      % this.hideGui();
      this.hParent = hParent;
      
      % restore warning settings
      warning(s);
                                                   
    end

    
    % statusbar
    function changeStatus(this, name, string)
      
      handle = this.getHandle(name);
      set(handle, 'Text', string)
      
    end
    
    function disableGui(this)
      
      n = numel(this.handles);
      
      this.state = cell(n,1);
      
      for i = 1:n
        
        h = this.getHandle(this.handles{i});
        this.state{i} = get(h, 'Enable');
        set(h,'Enable','off');
        
      end
      
      
    end
    
    function enableGui(this)
      
      n = numel(this.handles);
      
      for i = 1:n
        
        h = this.getHandle(this.handles{i});
        set(h,'Enable',this.state{i});
        
      end
      
    end
    
    
    % tree
    function updateTree(this, name, file, path, data)
      
      % get handle
      tree = this.getHandle(name);
      
      % init
      newPath = 1;
      newFile = 1;

      % create pathObject
      pathObject = uitreenode('v0',handle(tree.handle),path,[],false); 

      % check for existens of pathObject
      if tree.root(1).getChildCount
        tempObject = root(1).getFirstChild;
      else
        tempObject = [];
      end
      
      % loop over node to determine if pathObject already exists
      while(~isempty(tempObject))
        if strcmp(tempObject.getName,pathObject.getName)
          pathObject = tempObject;
          newPath = 0;
          tempObject = [];
        else
          tempObject = root(1).getChildAfter(tempObject);
        end
      end
      
    end
    
    
    % getter
    function handle = getHandle(this, name)
    %GETHANDLE return the handle of a childobject of the the gui object
    %  arguments: - name: name of the gui object
    
      handle = getappdata(this.hMainWindow, name);
    end
    
    function text = getText(this, name, format)
    %GETTEXT return a string or a number of a text field
    %  arguments: - name: name of the text field
    %             - format: 'numeric' fot returning a number, every other
    %                       value for returning a string
      
      if nargin < 3
        format = 'string';
      end
    
      handle = this.getHandle(name);
      
      if strcmp(format,'numeric')
        text = str2double(get(handle,'String'));
      else
        text = get(handle,'String');
      end
 
    end
    
    function value = getValue(this, name)
      
      handle = this.getHandle(name);
      value = get(handle, 'Value');
      
    end
    
    
    % gui visibility
    function hideGui(this)
      
      set(allchild(this.hMainWindow),'Visible','off');
      set(this.hMainWindow,'Visible','off');
      
    end
    
    function showGui(this)
    %SHOWGUI show the gui
    
      set(allchild(this.hMainWindow),'Visible','on');
      set(this.hMainWindow,'Visible','on');
    end
    
    function hFunction = createCallback(this, name)
    %CREATECALLBACK create a callback
    %  arguments: - name: name of the callback
        
      % check if framework is inside a package
      if isempty(this.packageName)

        % check if callback dir exists
        if ~(exist('+callbacks','dir') == 7)

          % if not create it
          mkdir('+callbacks')

        end

        % create dummy callback function if non exists yet
        if ~(exist(['+callbacks/', name, '.m'],'file') == 2)
          fcallback = fopen(['+callbacks/', name, '.m'],'w');
          fprintf(fcallback, '%s\n', ['function ', name, '(this)']);
          fprintf(fcallback, '%s\n', ['  msgbox(''', name, ''',''Callback Test'',''help'');']);
          fprintf(fcallback, '%s\n\n', 'end');
          fclose(fcallback); 

          % wait until file is written
          while(~exist(['+callbacks/', name, '.m'],'file'))
            pause(0.1)
          end

        end

        % create callback function
        hFunction = str2func(['callbacks.', name]);

      else

        % check if callback dir exists
        if ~(exist(['+' this.packageName '/+callbacks'],'dir') == 7)

          % if not create it
          mkdir(['+' this.packageName '/+callbacks'])

        end

        % create dummy callback function if non exists yet
        if ~(exist(['+' this.packageName '/+callbacks/', name, '.m'],'file') == 2)
          fcallback = fopen(['+' this.packageName '/+callbacks/', name, '.m'],'w');
          fprintf(fcallback, '%s\n', ['function ', name, '(this)']);
          fprintf(fcallback, '%s\n', ['  msgbox(''', name, ''',''Callback Test'',''help'');']);
          fprintf(fcallback, '%s\n\n', 'end');
          fclose(fcallback); 

          % wait until file is written
          while(~exist(['+' this.packageName '/+callbacks/', name, '.m'],'file'))
            pause(0.1)
          end

        end

        % create callback function
        hFunction = str2func([this.packageName '.callbacks.', name]);



      end

    end
    
  end
  
  methods(Access = private)
    
    function axes(this, name, size, position, buttonDownFcn, parent)
    %AXES config object for an axes
    %  arguments: - name: name of the axis
    %             - size: 2 dimensional vector with the wide and hight of
    %             the axis
    %             - position: 2 dimensional vector with the position of
    %             the axis  
    %             - buttonDownFcn: enable or disable a button down function
    %             for the axis
    %             - parent: the parent object of the axis
    
      parent = getappdata(this.hMainWindow,parent);
      
      if buttonDownFcn
        
        hFunction = this.createCallback(name);
        
        handle = axes('Units', 'pixel', ...
                      'Position', [position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size],...
                      'Parent', parent, 'ButtonDownFcn', @(src,event)hFunction(this.hParent));
        
      else
        
        handle = axes('Units', 'pixel', ...
                      'Position', [position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size],...
                      'Parent', parent);
        
      end
      
      %imshow(1)
         
      setappdata(this.hMainWindow, name, handle);
      %this.handles{numel(this.handles) + 1} = name;
      
    end
    
    function button(this, name, size, position, style, string, parent)
    %BUTTON config object for a button
    %  arguments: - name: name of the button
    %             - size: 2 dimensional vector with the wide and hight of
    %             the button
    %             - position: 2 dimensional vector with the position of
    %             the button 
    %             - style:  toggle or push
    %             - string: label for the button
    %             - parent: the parent object of the button
      
      parent = getappdata(this.hMainWindow,parent);
      
      hFunction = this.createCallback(name);
      
      if strcmp(style, 'toggle')
        style = 'togglebutton';
      else
        style = 'pushbutton';
      end
      
      % create button
      handle = uicontrol('Style', style,...
                         'String', string, ...
                         'Units', 'pixel', ...
                         'Position', [position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size], ...
                         'Callback', @(src,event)hFunction(this.hParent), ...
                         'Parent', parent);
                       
      setappdata(this.hMainWindow, name, handle);
      this.handles{numel(this.handles) + 1} = name;
      
    end
    

    function checkbox(this, name, size, position, string, value, parent)
      
      parent = getappdata(this.hMainWindow,parent);
      
      %hFunction = this.createCallback(name);

      
      % create button
      handle = uicontrol('Style', 'checkbox',...
                         'String', string, ...
                         'Units', 'pixel', ...
                         'Position', [position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size], ...
                         'Value', value, ...
                         'Parent', parent);
                       
      setappdata(this.hMainWindow, name, handle);
      %this.handles{numel(this.handles) + 1} = name;
      
    end
    
    
    
    function list(this, name, size, position, callback, parent)
      
      parent = getappdata(this.hMainWindow,parent);
      
      if callback
        hFunction = this.createCallback(name);
        
        handle = uicontrol('Style', 'listbox',...
                           'Units', 'pixel', ...
                           'Position', [position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size], ...
                           'Callback', @(src,event)hFunction(this.hParent), ...
                           'Parent', parent);
      else

        
        handle = uicontrol('Style', 'listbox',...
                           'Units', 'pixel', ...
                           'Position', [position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size], ...
                           'Parent', parent);
                       
      end
                       
      setappdata(this.hMainWindow, name, handle);  
      
    end
    

    function menu(this, name, string, callback, parent)
    %MENU config object for a dropdown menu
    %  arguments: - name: name of the menu
    %  TODO ... you need here different functions for creating and
    %  expanding a menu
      
      parent = getappdata(this.hMainWindow,parent);
      
      if callback
        hFunction = this.createCallback(name);
        handle = uimenu(parent, 'Label',string, 'Callback', @(src,event)hFunction(this.hParent));
      else
        handle = uimenu(parent, 'Label',string);
      end
      
      setappdata(this.hMainWindow, name, handle);
      this.handles{numel(this.handles) + 1} = name;
      
    end
    
    function parseConfig(this, config) %#ok<INUSL>
    %PARSECONFIG actual config parser
    %  arguments: - config: name of the gui configuration
      
      % check if config file exsists 
      if exist(config, 'file') == 2
        
        % open config file
        fconfig = fopen(config);
        
        % read in first line
        line = fgetl(fconfig);
        
         while(~isnumeric(line))
           
          if ~isempty(line) && line(1) ~= '#'
            % write current line in init file
            eval(['this.' line ';'])
          end
          
          % get next line
          line = fgetl(fconfig);
          
        end

      else
        
        % error msg if config file does not exsist
        msgbox('test','ERROR','error');        
      end
      

    end
    
    function panel(this, name, string, size, position, parent)
    %PANEL config object for a panel
    %  arguments: - name: name of the panel
    %             - string: label for the panel    
    %             - size: 2 dimensional vector with the wide and hight of
    %             the panel
    %             - position: 2 dimensional vector with the position of
    %             the panel
    %             - parent: the parent object of the panel
    
      parent = getappdata(this.hMainWindow,parent);
      
      handle = uipanel('Title',string, ...
                       'Parent',parent, ...
                       'Units', 'pixel', ...
                       'FontSize',12, ...
                       'Position',[position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size]);
      
      setappdata(this.hMainWindow, name, handle);
      %this.handles{numel(this.handles) + 1} = name;
      
    end
    
    function slider(this, name, size, position, minValue, maxValue, step, parent)
    %SLIDER config object for a button
    %  arguments: - name: name of the button
    %             - size: 2 dimensional vector with the wide and hight of
    %                     the slider
    %             - position: 2 dimensional vector with the position of
    %                         the slider 
    %             - minValue: minimal feasiable value
    %             - maxValue: maximal feasiable value
    %             - step: increment steo
    %             - parent: the parent object of the slider
      
      parent = getappdata(this.hMainWindow,parent);
      
      hFunction = this.createCallback(name);
      
      sliderStep = step / (maxValue - minValue); % calculate slider step 
      
      % create slider
      handle = uicontrol('Style', 'slider',...
                         'Units', 'pixel', ...
                         'Position', [position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size], ...
                         'Min', minValue, 'Max', maxValue, ...
                         'SliderStep', sliderStep, 'Value', minValue, ...
                         'Callback', @(src,event)hFunction(this.hParent), ...
                         'Parent', parent);
                       
      setappdata(this.hMainWindow, name, handle);  
      this.handles{numel(this.handles) + 1} = name;
    end
    
    function status(this, name, string, parent)
      
      parent = getappdata(this.hMainWindow,parent);
      
      this.showGui();
      handle = this.statusbar(parent, string);
      
      setappdata(this.hMainWindow, name, handle); 
      %this.handles{numel(this.handles) + 1} = name;
      
    end
    
    function tab(this, name, string, parent)
    %TAP config object for a tap
    %  arguments: - name: name of the tap
    %             - string: label for the tap
    %             - parent: the parent object of the tap
      tabGroupName = [parent 'TabGroup'];
      
      parent = getappdata(this.hMainWindow,parent);
      
      hTabGroup = getappdata(this.hMainWindow, tabGroupName);
      
      if isempty(hTabGroup)
        hTabGroup = uitabgroup('Parent',parent);
        setappdata(this.hMainWindow, tabGroupName, hTabGroup);
      end
      
      handle = uitab('Parent',hTabGroup, 'title',string ,'Units','pixel');
      
      setappdata(this.hMainWindow, name, handle);
      %this.handles{numel(this.handles) + 1} = name;
      
    end
    
    function text(this, name, string, size, position, style, parent)
    %TEXT config object for a textbox
    %  arguments: - name: name of the textbox
    %             - string: label for the textbox   
    %             - size: 2 dimensional vector with the wide and hight of
    %             the textbox
    %             - position: 2 dimensional vector with the position of
    %             the textbox
    %             - style: chose the style of the textbox. Possible are:
    %               - static:
    %               - edit: 
    %             - parent: the parent object of the textbox
      
      parent = getappdata(this.hMainWindow,parent);
      
      if strcmp(style, 'static')
        style = 'text';
      end

      handle = uicontrol('Style', style,...
                         'String', string, ...
                         'Units', 'pixel', ...
                         'Position', [position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size], ...
                         'Parent', parent);
      
      setappdata(this.hMainWindow, name, handle);
      %this.handles{numel(this.handles) + 1} = name;
                       
    end
    
    function tree(this, name, string, multipleSelection, parent)
      
      parent = getappdata(this.hMainWindow,parent);
      
      handle = gui.tree(string, parent);
      
      if multipleSelection
        handle.enableMultipleSelection();
      end

      setappdata(this.hMainWindow, name, handle);
      %this.handles{numel(this.handles) + 1} = name;

    end
    
    function window(this, name, size, string)
    %WINDOW config object for a gui window
    %  arguments: - name: name of the window
    %             - size: 2 dimensional vector with the wide and hight of
    %             the window 
    %             - string: label for the window   
    
      handle = figure('tag',name,...
                             'NumberTitle','off', ...
                             'Name', string, ...
                             'MenuBar','none', ...
                             'Resize','off', ...
                             'Units','pixel', ...
                             'DockControls','off', ...
                             'position',[50, 50, size]);
            
      if isempty(this.hMainWindow)
        this.hMainWindow = handle;
      end
                           
      setappdata(this.hMainWindow, name, handle);     
      %this.handles{numel(this.handles) + 1} = name;
                           
      movegui(this.hMainWindow,'center'); 
      
    end
  
  end
  
  methods(Static)
    
    statusbarHandles = statusbar(varargin);
    
  end
        
end
