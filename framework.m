classdef framework < handle
  %framework Provide a class for a easy configurable gui 
  %
  properties
    
    hMainWindow;
    packageName;

  end
  
  
  methods(Access = public)

    function this = framework(config, packageName)
    %FRAMEWORK initiate the GUI and parse the config file
    %  arguments: - config: name of the configuration file (string)
    %             - packageName: the name for the preconfigured gui, '' 
    %               for placing the callbacks in the main dir (string)
      
      % surpress uitabgroup warning
      s = warning('off', 'MATLAB:uitabgroup:OldVersion');
      
      % set package name
      this.packageName = packageName;
      
      % parse config file      
      this.parseConfig(config);
      
      % restore warning settings
      warning(s);
                                                   
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
      
      handle = this.getHandle(name);
      
      if strcmp(format,'numeric')
        text = str2double(get(handle,'String'));
      else
        text = get(handle,'String');
      end
 
    end
    
    function showGui(this)
    %SHOWGUI show the gui
    
      set(this.hMainWindow,'Visible','on');
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
                      'Parent', parent, 'ButtonDownFcn', @(src,event)hFunction(this));
        
      else
        
        handle = axes('Units', 'pixel', ...
                      'Position', [position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size],...
                      'Parent', parent);
        
      end
      
      
         
      setappdata(this.hMainWindow, name, handle);
      
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
                         'Callback', @(src,event)hFunction(this), ...
                         'Parent', parent);
                       
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
        handle = uimenu(parent, 'Label',string, 'Callback', @(src,event)hFunction(this));
      else
        handle = uimenu(parent, 'Label',string);
      end
      
      setappdata(this.hMainWindow, name, handle);
      
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
                       
    end
    
    function window(this, name, size, string)
    %WINDOW config object for a gui window
    %  arguments: - name: name of the window
    %             - size: 2 dimensional vector with the wide and hight of
    %             the window 
    %             - string: label for the window   
    
      handle = figure('tag',name,...
                             'NumberTitle','off', ...
                             'Visible','off', ...
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
                           
      movegui(this.hMainWindow,'center'); 
      
    end
  
    
      
  end
  
  
end