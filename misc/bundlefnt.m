function [status, this] = bundlefnt(fnt, skip_mats)
% [status, this] = bundlefnt(fnt,skip_mats)
% Bundles a function for distribution
% 'fnt' is an optional string naming the function to be bundled for distribution
% Uses depfun to identify dependent functions
% Removes Matlab supplied functions
% Searches all included files for required .mat files, either by explicit
% name or by wildcard.
% Prompts user for location to place zipped file
% Author: CJF
% 2017-03-21: modified to strip out numerous files Matlab keeps adding for
% no apparent reason.
if isempty(who('fnt'))
    fnt = input('Name of function to bundle? \n','s');
end
if isempty(who('skip_mats'))||~islogical(skip_mats)
    skip_mats = true;
end
disp('Save the bundle as...')
[outname,outpath] = uiputfile([getnamedpath('bundles','Save zipped bundle:'),fnt,'.zip'],'Save the bundle as...');
if isadir(outpath) && ~strcmp(outpath, getnamedpath('bundles'))
   setnamedpath('bundles',outpath);
end
% use matlab.codetools.requiredFilesAndProducts if it exists, else depfun
if isempty(which('matlab.codetools.requiredFilesAndProducts'))
  this = depfun(fnt,'-quiet');
else
  this = matlab.codetools.requiredFilesAndProducts(fnt);
end
supplied = fileparts(which('imagedemo')); 
[~,supplied] = strtok(fliplr(supplied),filesep); 
supplied = fliplr(supplied);
%screen out Matlab supplied scripts
for ln = length(this):-1:1
    [~,b,c] = fileparts(this{ln});
    if ~isempty(strfind(this{ln},[filesep,'toolbox',filesep,'matlab',filesep]))...
    ||~isempty(strfind(this{ln},supplied))...      
    ||~isempty(strfind(this{ln},[filesep,'toolbox',filesep,'optim',filesep]))...
    ||~isempty(strfind(this{ln},[filesep,'toolbox',filesep,'matlab',filesep]))...
    ||~isempty(strfind(this{ln},[filesep,'toolbox',filesep,'stats',filesep]))...
    ||~isempty(strfind(this{ln},[filesep,'toolbox',filesep,'images',filesep]))...
    ||~isempty(strfind(this{ln},[filesep,'toolbox',filesep,'stats',filesep]))...    
    ||~isempty(strfind(this{ln},[filesep,'toolbox',filesep,'compiler',filesep]))...
            ||~isempty(strfind(this{ln},[filesep,'printopt.m']))...
            ||~isempty(strfind(this{ln},[filesep,'ncviewer',filesep,'used',filesep,'msgbox.m']))...
            ||~strcmp(which(b),this{ln})||isempty(c)
        %     if ~isempty(strfind(this{ln},'\toolbox\matlab\'))...
        %             ||~isempty(strfind(this{ln},'\toolbox\compiler\'))...
        %             ||~isempty(strfind(this{ln},'\printopt.m'))...
        %             ||~isempty(strfind(this{ln},'\ncviewer\used\msgbox.m'))...
        %             ||~strcmp(which(b),this{ln})
        this(ln) = [];
    end
end
% status = length(this);

all_tags = {};
if ~skip_mats
for it = this'
    tags = find_mats(char(it));
    if ~isempty(tags)
        all_tags =  [all_tags;tags];
    end
end
end
all_tags = unique(all_tags);
wild_tags = all_tags;
% no_wilds = all_tags;
for a = length(all_tags):-1:1
    if isempty(strfind(all_tags{a},'*'))&&isempty(strfind(all_tags{a},'?'))&&isempty(strfind(all_tags{a},'%'))
        %         this = {this{:},all_tags{a}}';
        %     this(end+1) = {which(all_tags{a})};
        that = which(all_tags{a});
        if ~isempty(that)
            this = [this; {which(all_tags{a})}];
        end
        wild_tags(a) = [];
        %     else
        %         no_wilds(a) = [];
    end
end
if ~isempty(wild_tags)
    A = textscan(pathdef,'%s','delimiter',pathsep);
    A = A{:};
    A = [{'.'};A];
    for aa = char(A)'
        aa = [deblank(aa'), filesep];
        for it = wild_tags'
            it = it{:};
            found = dir([aa, it]);
            if ~isempty(found)
                for f = 1:length(found)
                    %                   no_wilds = [no_wilds;{found(f).name}];
                    this = [this; {which(found(f).name)}];
                end
            end
        end
    end
    %     no_wilds = unique(no_wilds)
end
% for it = no_wilds'
%     this = [this,{which(it)}];
% end
this = unique(this);

%screen out Matlab supplied scripts
for ln = length(this):-1:1
%     [a,b,c] = fileparts(this{ln});
    if ~isempty(strfind(this{ln},[filesep,'toolbox',filesep,'matlab',filesep]))...
            ||~isempty(strfind(this{ln},matlabroot))...
            ||~isempty(strfind(this{ln},'lastpath.mat'))
        this(ln) = [];
    end
end
status = length(this)

%screen out scripts Matlab keeps including for no apparent reason.
for ln = length(this):-1:1
%    disp(['ln = ',num2str(ln)])
   % For each file, check if any of the other functions are used by it, or
   % if it is called by any of the other functions.  If not, delete it.
   full = this{ln}; [~,fun_name,~] = fileparts(full);
   fun_id = fopen(full); fun_text = fread(fun_id,'uint8=>char')'; fclose(fun_id);
   used = false; id = length(this);
   while ~used && id>=1
     if id~=ln
        [~, test_name, ~] = fileparts(this{id});
        fun_id = fopen(full);
        while ~feof(fun_id)&&~used
           fun_line = fgetl(fun_id);
           found_fun = strfind(fun_line,test_name ); found_comment = strfind(fun_line,'%');
           if isempty(found_comment)
              found_comment = inf;
           end
           % if function name is found before any comment marker, then it
           % is actually used.
           if ~isempty(found_fun) && min(found_fun)<min(found_comment)
              used = true;
           end
        end
        fclose(fun_id);

        if ~used
            test_id = fopen(this{id});
            while ~feof(test_id)&&~used
               test_text = fgetl(test_id);
               found_fun = strfind(test_text, fun_name); found_comment = strfind(test_text, '%');
               if isempty(found_comment)
                  found_comment = inf;
               end
               % if function name is found before any comment marker, then it
               % is actually used.               
               if ~isempty(found_fun) && min(found_fun)<min(found_comment)
                  used = true;
               end
            end
            fclose(test_id);            
        end
     end
     id = id -1;
   end
   if ~used
      this(ln) = []; disp(['length(this)=',num2str(length(this))])
   end
   disp(['Working down, ln = ',num2str(ln)])
end
        
status = length(this);

% Now, for each file in 'this' search for the data tag and accumulate a
% cell array of strings.
% Then for each unique string, check for wild-cards.
% If there is a wildcard in the tag then do a "dir" for the pattern and add each
% returned file to the list.  Next, cd to each directory in pathdef and do a
% "dir", adding returned files to the list.
% Then for each unique string, add the non-empty results of which to 'this'
disp(['Creating zip file: ',fullfile(outpath,outname)]);
zip(fullfile(outpath,outname),this);
for ln = length(this):-1:1
    thisn = this{ln};
    if strcmp(thisn(2),':')
        this{ln} = thisn(4:end);
    end
    while strcmp(thisn(1),filesep)
        this{ln} = thisn(2:end);
    end
end

return


% $DataFiles:


