classdef framework < handle
   
  properties
    
    hMainGui;
    packageName;

  end
  
  
  methods(Access = public)

    function this = framework(config, packageName)
      
      % surpress uitabgroup warning
      s = warning('off', 'MATLAB:uitabgroup:OldVersion');
      
      % check input parameter
      if nargin < 1
        config = 'example.cfg';
      end
      
      if nargin < 2
        packageName = '';
      end
      
      % set package name
      this.packageName = packageName;
      
      % parse config file      
      this.parseConfig(config);
      
      % show gui
      this.showGui();
      
      % restore warning settings
      warning(s);
                                                   
    end
    
    function handle = getHandle(this, name)
      handle = getappdata(this.hMainGui, name);
    end
    
    function text = getText(this, name, format)
      
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
    
  end
  
  methods(Access = private)
    
    function axes(this, name, size, position, parent)
     
      if nargin < 5
        parent = this.hMainGui;
      else
        parent = getappdata(this.hMainGui,parent);
      end
      
      % create button
      handle = axes('Units', 'pixel', ...
                    'Position', [position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size],...
                    'Parent', parent);
                  
      imshow(1);
         
      setappdata(this.hMainGui, name, handle);
      
    end
    
    function button(this, name, size, position, string, parent)
      
      % check input arguments
      if nargin < 6
        parent = this.hMainGui;
      else
        parent = getappdata(this.hMainGui,parent);
      end
      
      hFunction = this.createCallback(name, this.packageName);
      
      % create button
      handle = uicontrol('Style', 'pushbutton',...
                         'String', string, ...
                         'Units', 'pixel', ...
                         'Position', [position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size], ...
                         'Callback', @(src,event)hFunction(this), ...
                         'Parent', parent);
                       
      setappdata(this.hMainGui, name, handle);
      
    end
    
    function parseConfig(this, config)
      
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
      
      % check input arguments
      if nargin < 6
        parent = this.hMainGui;
      else
        parent = getappdata(this.hMainGui,parent);
      end
      
      handle = uipanel('Title',string, ...
                       'Parent',parent, ...
                       'Units', 'pixel', ...
                       'FontSize',12, ...
                       'Position',[position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size]);
      
      setappdata(this.hMainGui, name, handle);
      
    end
    
    function tab(this, name, string, parent)
      
      tabGroupName = [parent 'TabGroup'];
      
      if nargin < 4
        parent = this.hMainGui;
      else
        parent = getappdata(this.hMainGui,parent);
      end
      
      hTabGroup = getappdata(this.hMainGui, tabGroupName);
      
      if isempty(hTabGroup)
        hTabGroup = uitabgroup('Parent',parent);
        setappdata(this.hMainGui, tabGroupName, hTabGroup);
      end
      
      handle = uitab('Parent',hTabGroup, 'title',string ,'Units','pixel');
      
      setappdata(this.hMainGui, name, handle);
      
    end
    
    function text(this, name, string, size, position, style, parent)
      
      % check input arguments
      if nargin < 6
        parent = this.hMainGui;
      else
        parent = getappdata(this.hMainGui,parent);
      end
      
      if strcmp(style, 'static')
        style = 'text';
      end

      handle = uicontrol('Style', style,...
                         'String', string, ...
                         'Units', 'pixel', ...
                         'Position', [position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size], ...
                         'Parent', parent);
      
      setappdata(this.hMainGui, name, handle);
                       
    end
    
    function showGui(this)
      set(this.hMainGui,'Visible','on');
    end
    
    function window(this, name, size, string)
      
      handle = figure('tag',name,...
                             'NumberTitle','off', ...
                             'Visible','off',...
                             'Name', string,...
                             'MenuBar','none',...
                             'Resize','off',...
                             'Units','pixel',...
                             'position',[50, 50, size]);
            
      if isempty(this.hMainGui)
        this.hMainGui = handle;
      end
                           
      setappdata(this.hMainGui, name, handle);                   
                           
      movegui(this.hMainGui,'center'); 
      
    end
    
    end
  
  methods(Static)
      
    function hFunction = createCallback(name, packageName)
        
        % check if framework is inside a package
        if isempty(packageName)
        
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
          if ~(exist(['+' packageName '/+callbacks'],'dir') == 7)
            
            % if not create it
            mkdir(['+' packageName '/+callbacks'])
            
          end
          
          % create dummy callback function if non exists yet
          if ~(exist(['+' packageName '/+callbacks/', name, '.m'],'file') == 2)
            fcallback = fopen(['+' packageName '/+callbacks/', name, '.m'],'w');
            fprintf(fcallback, '%s\n', ['function ', name, '(this)']);
            fprintf(fcallback, '%s\n', ['  msgbox(''', name, ''',''Callback Test'',''help'');']);
            fprintf(fcallback, '%s\n\n', 'end');
            fclose(fcallback); 

            % wait until file is written
            while(~exist(['+' packageName '/+callbacks/', name, '.m'],'file'))
              pause(0.1)
            end

          end

          % create callback function
          hFunction = str2func([packageName '.callbacks.', name]);
          
          
          
        end
        
      end
      
  end
  
  
end