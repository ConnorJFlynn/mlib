function ins = rd_raw_SAS(infile)
% Read SAS instrument-raw data
% outs = rd_raw_SAS(infile)

if ~exist('infile','var')
    infile= getfullname('*.csv','ascii');
end
[pname, fname,ext] = fileparts(infile);
fname = [fname,ext];
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
    labels = textscan(tmp,'%s','delimiter',',');
    labels = labels{:};
    labels = strrep(labels,' ','');
    ins.labels = labels;
    
    %%
    fseek(fid,0,-1);
    txt = textscan(fid,(repmat('%f ',size(labels'))),'headerlines',r,'delimiter',',','treatAsEmpty','Infinity');
    %%
    ins.time = datenum([txt{1},txt{2},txt{3},txt{4},txt{5},txt{6}]);
    for h = 1:length(ins.header)
        test_str = '_coefs = [';
        str_ii = findstr(ins.header{h},test_str);
        if ~isempty(str_ii)
            tmp_str = ins.header{h};
            tmp_str = tmp_str(str_ii+length(test_str):end);
            ins.lambda_fit = textscan(tmp_str,'%f','delimiter',':');
            ins.lambda_fit = ins.lambda_fit{:};
        end
%         pix_range = findstr(ins.header{h},'Pixels [first:last]');
        test_str = '% Pixels [first:last] = [';
        str_ii = findstr(ins.header{h},test_str);
        if ~isempty(str_ii)
            tmp_str = ins.header{h};
            tmp_str = tmp_str(str_ii+length(test_str):end);
            ins.pix_range = textscan(tmp_str,'%f','delimiter',':');
            ins.pix_range = ins.pix_range{:};
        end
    end
    ins.lambda = polyval(flipud(ins.lambda_fit), (ins.pix_range(1):ins.pix_range(2)));
    if ins.lambda(2)<ins.lambda(1) 
        ins.lambda = fliplr(ins.lambda); 
    end
    pix_start = find(strcmp(labels,'Px_0'));
    pixels = length(labels)-pix_start+1;
    for p = pixels:-1:1
        ins.spec(:,p) = txt{pix_start +p-1};
    end
    for r = 7:pix_start-1
        ins.(labels{r}) = txt{r};
    end
%     figure_(1000); plot(ins.lambda, mean(ins.spec(ins.Shutter_open_TF==1,:))-mean(ins.spec(ins.Shutter_open_TF==0,:)),'-'); 
%     title(fname, 'interp','none'); 
[rows,cols] = size(ins.spec(ins.Shutter_open_TF==1,:));
%         
%     figure_(1001); these = plot(ins.lambda, ins.spec(ins.Shutter_open_TF==1,:)-ones([rows,1])*mean(ins.spec(ins.Shutter_open_TF==0,:)),'-'); 
%         recolor(these,[1:rows]);
% figure; plot([1:rows], ins.spec(ins.Shutter_open_TF==1,600),'o-')
% figure_(1002); plot(ins.lambda, (ins.spec(ins.Shutter_open_TF==1,:)),'-'); 
ins.sig = NaN(size(ins.spec));
ins.sig(ins.Shutter_open_TF==1,:) = ins.spec(ins.Shutter_open_TF==1,:)...
    - ones([rows,1]) * mean(ins.spec(ins.Shutter_open_TF==0,:));
ins.rate = ins.sig ./ (ins.t_int_ms * ones([1,cols]));
% figure_(1003); 
% these = plot(ins.lambda, meannonan(ins.rate),'ko',ins.lambda, ins.rate,'-');
% recolor(these, [1:length(ins.time)]);
end
%%
% ins = rmfield(ins,{'sig','rate'});
return
