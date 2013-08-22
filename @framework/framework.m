classdef framework < handle
   
  properties
    hMainGui; 
    hButton;
  end
  
  
  methods(Access = public)

    function this = framework(config)
      
      % check input parameter
      if nargin < 1
        config = 'example.cfg';
      end
      
      % parse config file      
      this.parseConfig(config);
      
      % save gui handle
      setappdata(0, 'hMainGui', this.hMainGui);
      
      % show gui
      this.showGui();
                                                   
    end
    
  end
  
  methods(Access = private)
    
    function mainWindow(this, name, size)
      
      this.hMainGui = figure('tag',name,...
                       'Visible','off',...
                       'Name', name,...
                       'MenuBar','none',...
                       'Resize','off',...
                       'Units','pixel',...
                       'Position',[50, 50, size]);
                     
      movegui(this.hMainGui,'center'); 
      
    end
    
    function button(this, name, size, position, string, parent)
      
      % check input parameters
      if nargin < 6
        parent = this.hMainGui;
      end
      
      if ~(exist('+callbacks','dir') == 7)
        mkdir('+callbacks')
      end
      
      
      if ~(exist(['+callbacks/button_', name, '.m'],'file') == 2)
        fcallback = fopen(['+callbacks/button_', name, '.m'],'w');
        fprintf(fcallback, '%s\n', ['function button_', name, '(this)']);
        fprintf(fcallback, '%s\n', ['  msgbox(''button_', name, ''',''Callback Test'',''help'');']);
        fprintf(fcallback, '%s\n\n', 'end');
        fclose(fcallback); 
        
        while(~exist(['+callbacks/button_', name, '.m'],'file'))
          pause(0.1)
        end
        
      end
      
      % create callback function
      func = str2func(['callbacks.button_', name]);
      
      % create button
      uicontrol('Style', 'pushbutton',...
                'String', string,...
                'Position', [position(1) - 0.5 * size(1), position(2) - 0.5 * size(2), size],...
                'Callback', @(src,event)func(this), ...
                'Parent', parent);
      
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
    
    function showGui(this)
      set(this.hMainGui,'Visible','on');
    end
    
    guiInit(this)
    
  end
  
  
end