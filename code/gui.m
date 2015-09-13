


%%
%% This file provides a GUI to 
%% input possebility p(j,r,i)
%% j =1..J criteria (or experts; 
%% some experts invoke some criteria, with a max dim = NumCrit * NumExperts
%% i =1..I projects 
function gui


% Initial values %

 global I;  
 global J;  
 global R;  
 I = 20;     %technologies
 J = 16;     %criteria
 R = 10;    %points

 
 % p is a set of I matrices J*R
 % where each row is p(r), r=1..R for given j=1..J
 % FUTURE: 2d set I*E (number of experts) of matrices J*R
 global p;

 p = zeros(J,R,I); % initial possib. uncertain

% Window %

f = figure('Position',[250 250 800 560],...
    'MenuBar','none','NumberTitle','off',...
    'Resize', 'off',...
    'Name', 'Possibility Expert Interface');

handles = guihandles(f);
% UI controls %

handles.sliders = [];
for r=1:R 
   handles.sliders  = [handles.sliders;  ...
            uicontrol('UserData', r, 'Style', 'slider',...
            'Min',0,'Max',1,'SliderStep',[1.0,0.1],'Value',0,...
         'SliderStep', [0.1 0.2],...
         'Position', [50+400/(R+0.5)*r 50 250/(R+0.5) 310], 'Callback', @StorePdata) ];
     uicontrol('Style','text', 'Position',[50+400/(R+0.5)*r 30 250/(R+0.5) 15],...
        'String', num2str(r));
end

    uicontrol('Style','text', 'Position',[40,30,40,15],'String','Баллы');
   
    uicontrol('Style','text', 'Position',[65,60,15,15],'String','0');
    uicontrol('Style','text', 'Position',[65,330,15,15],'String','1');
    
    
    uicontrol('Style','text', 'Position',[10,360,90,15],'String','Возможность');    
    
    pro_items =[];
    for i=1:I
        pro_items = [pro_items; sprintf('Object #%03i', i)];
    end  
    handles.listboxI = uicontrol('Style', 'listbox', ...
        'Position', [40 385 240 160], 'String', cellstr(pro_items),...
        'Value', 1, 'Callback', @Select);
    
       button_load_p = uicontrol('Style', 'pushbutton', ...
        'Position', [500 230 150 45], 'String', 'Save to file..', 'Callback', @SaveFileClick);
     button_save_p = uicontrol('Style', 'pushbutton', ...
        'Position', [500 280 150 45], 'String', 'Load from file..', 'Callback', @LoadFileClick);

     handles.check_norm = uicontrol('Style', 'checkbox', ...
        'Position', [500 200 170 15], 'String', 'Auto max(p)=1 on Save', 'Value',1);

    % items of listbox as string array 
    crit_items =[];
    for j=1:J
        crit_items = [crit_items; sprintf('Criterium #%02i', j)];
    end
    
    % detailed criterium descriptions 
    % alter or encomment if needed
  %   crit_items = {'Научно-технический уровень'; 'Уровень кадрового обеспечения';...
  %      'Конкурентоспособность технологии';'Востребованность технологии';...
  %      'Потенциал дальнейшего развития';'Нефункциональные эффекты'; ...
  %      'Научно-технические риски';'Имеющаяся лабораторно-производственная база';...
  %      'Требования к производственной базе';'Потенциал развития инфраструктуры';...
  %      'Технологические риски';'Ожидаемый доход и жизненный цикл';...
  %      'Затраты на внедрение';'Эксплуатационные затраты';...
  %      'Коммерческие и социально-бытовые риски'; 'Правовая чистота технологии';...
  %      'Зарегистрированная интеллектуальная собственность';...
  %      'Потенциал интеллектуальной собственности';'Предполагаемые формы передачи технологии';...
  %      'Правовые риски'};
        
        
        
    handles.listboxJ = uicontrol('Style','listbox','Position', [300 385 400 160], 'String',...
        cellstr(crit_items),... %convert string array into cell array
        'Value', 1, 'Callback', @Select);
    
    guidata(f, handles);
%eth = uicontrol(f, 'Style', 'text',...
%    'String', [num2str(get(sh, 'Value')) 'Hz'],...
%    'Position', [545 420 50 20]);

end

function Select(hObject, eventdata)

    global p;
     
    handles = guidata(gcbo);

    i = get(handles.listboxI, 'Value');
    j = get(handles.listboxJ, 'Value');
    
    for r=1:size(handles.sliders)
    	set( handles.sliders(r), 'Value', p(j,r,i));
    end

end

function StorePdata(hObject, eventdata)

    global p;
     
    handles = guidata(gcbo);

    i = get(handles.listboxI, 'Value');
    j = get(handles.listboxJ, 'Value');
    
    for r=1:size(handles.sliders)
         p_t = get( handles.sliders(r), 'Value' );
         p_t = round(p_t*10)/10;
         p(j,r,i) =	p_t;
         set( handles.sliders(r), 'Value', p_t);
    end

end


function SaveFileClick(hObject, eventdata)

global p; global R;

    % save dialog
    [FileName,PathName]  = uiputfile('expert_possib.txt','Save P-data');
    handles = guidata(gcbo);
    % normalize to max[i,j](p(i,j,r)) = 1
        % max_pR = max( p() );
    % normalize to max[i,j](p(j,r,i)) = 1
        % max 3,1 wokrs 1.3 times faster than max 1,3
        % max_pR = max( max( p, [], 3 ), [], 1 ); 
    
    % normalize to max[r](p(j,r,i)) = 1
    % 1. find maximum in each row. running column index r. => column
    % 2. tile R columns to reach size(p)
    % 3. p / max_pR. for each row, max[r]p(r) = 1 
    % write as comma-delimited single text array
    if get( handles.check_norm, 'Value' ) == 1
        max_pR = repmat(max(p, [], 2), 1, R); 
        p_norm = p ./ max_pR;
        p_norm( isnan(p_norm) ) = 1; %switch Nan==0/0 to 1
        
        save_p( fullfile(PathName, FileName), p_norm );
    else
        save_p( fullfile(PathName, FileName), p );
    end  
   
end

function LoadFileClick(hObject, eventdata)
 
    global p;
    global I; global J; global R;
    
    % open dialog
   [FileName,PathName] = uigetfile('*.txt','Select text file with P-data');
   
   % make array of matrices from single array
   p = load_p( fullfile(PathName, FileName) );
   
   % make the selection 
   Select(hObject, eventdata);
end



