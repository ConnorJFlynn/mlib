function [status, this] = bundlefnt(fnt)
% [status, this] = bundlefnt(fnt)
% Bundles a function for distribution
% 'fnt' is an optional string naming the function to be bundled for distribution
% Uses depfun to identify dependent functions
% Removes Matlab supplied functions
% Searches all included files for required .mat files, either by explicit
% name or by wildcard.
% Prompts user for location to place zipped file
% Author: CJF

if ~exist('fnt','var')
    fnt = input('Name of function to bundle? \n','s');
end
disp('Save the bundle as...')
[outname,outpath] = uiputfile([fnt,'.zip'],'Save the bundle as...');

this = depfun(fnt,'-quiet');
%screen out Matlab supplied scripts
for ln = length(this):-1:1
    [a,b,c] = fileparts(this{ln});
    if ~isempty(strfind(this{ln},[filesep,'toolbox',filesep,'matlab',filesep]))...
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
for it = this'
    tags = find_mats(char(it));
    if ~isempty(tags)
        all_tags =  [all_tags;tags];
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
status = length(this);


% Now, for each file in 'this' search for the data tag and accumulate a
% cell array of strings.
% Then for each unique string, check for wild-cards.
% If there is a wildcard in the tag then do a "dir" for the pattern and add each
% returned file to the list.  Next, cd to each directory in pathdef and do a
% "dir", adding returned files to the list.
% Then for each unique string, add the non-empty results of which to 'this'
disp('Creating zip file with paths stripped');
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
[~,A,B] =fileparts(outname);
disp('Creating zip file with relative paths preserved');
try
    zip(fullfile(outpath,[A,'.relpath',B]),this);
catch
    for ln = length(this):-1:1
        thisn = this{ln};
        thisn(end) = strrep(thisn(end), 'p','m');
        this{ln} = thisn;
    end
    disp('Creating zip file after replacing .p with .m');
    zip(fullfile(outpath,[A,'.relpath',B]),this);
end

return


% $DataFiles:


