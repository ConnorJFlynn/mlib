function ins = rd_SAS_resp(infile)
% Read SAS instrument-raw data
% outs = rd_raw_SAS(infile)

if ~exist('infile','var')
    infile= getfullname_('*.dat','sas_resp');
end
% [pname, fname,ext] = fileparts(infile);
% fname = [fname,ext];
fid = fopen(infile);
if fid>0
    [pname, fname,ext] = fileparts(infile);
    fname = [fname,ext];
    ins.fname{1} = fname;
    ins.pname = [pname,filesep];
    tmp = fgetl(fid);
    ins.header = {};
    r = 1;
    while strcmp(tmp(1),'%')
        ins.header(r,1) = {tmp};
        tmp = fgetl(fid);
        r = r+1;
    end
    %     labels = textscan(tmp,'%s','delimiter',',');
    labels = textscan(tmp,'%s');
    labels = labels{:};
    %     labels = strrep(labels,' ','');
    ins.labels = labels;
    
    %%
    fseek(fid,0,-1);
    txt = textscan(fid,(repmat('%f ',size(labels'))),'headerlines',r,'delimiter',',','treatAsEmpty','Infinity');
    if length(labels)~=length(txt)
        warning('The number of columns is different than the number of column headers.');
    end
    cols = min([length(labels),length(txt)]);
    
    
    for L = 1:cols
        ins.(labels{L}) = txt{L};
    end
    ins = rmfield(ins,'labels');
    %%
    
    for h = length(ins.header):-1:1
        test_str = 'Source_units:';
        str_ii = strfind(ins.header{h},test_str);
        if ~isempty(str_ii)
            tmp_str = ins.header{h};
            ins.resp_units = tmp_str(str_ii+length(test_str):end);;
        end
        
    end
    fclose(fid);
end
%%

return
