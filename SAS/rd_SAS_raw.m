function ins = rd_SAS_raw(infile)
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
    
    pix_start = find(strcmp(labels,sprintf('Px_%d',ins.pix_range(1))));
    pixels = length(labels)-pix_start+1;
    for p = 1:pixels
        ins.spec(:,p) = txt{pix_start +p-1};
    end
    for r = 7:pix_start-1
        ins.(labels{r}) = txt{r};
    end
    if ins.lambda(1)>ins.lambda(2)
       ins.lambda = fliplr(ins.lambda);
%        ins.spec = fliplr(ins.spec);
    end
%     figure(1000); plot(ins.lambda, mean(ins.spec(ins.Shutter_open_TF==1,:))-mean(ins.spec(ins.Shutter_open_TF==0,:)),'-'); 
%     title(fname, 'interp','none'); [rows,cols] = size(ins.spec(ins.Shutter_open_TF==1,:));
%     
%         figure(1001); these = plot(ins.lambda, ins.spec(ins.Shutter_open_TF==1,:)-ones([rows,1])*mean(ins.spec(ins.Shutter_open_TF==0,:)),'-'); 
%         recolor(these,[1:rows])
% figure; plot([1:rows], ins.spec(ins.Shutter_open_TF==1,600),'o-')
% figure; plot(ins.lambda, (ins.spec(ins.Shutter_open_TF==1,:)),'-',ins.lambda, (ins.spec(ins.Shutter_open_TF~=1,:)),'r-' ); 
[maxes, max_pix] = max(ins.spec(:,1:1142),[],2);
good = false(size(max_pix));
good(2:end) = (max_pix(1:end-1) == max_pix(2:end)) & (abs(maxes(2:end)-maxes(1:end-1))./maxes(2:end))<.05;
good_ii = find(good);
good = good(good);
figure; plot(ins.lambda, ins.spec(good,:),'-')

darks = sort(ins.spec); darks = mean(darks(1:200,:));
peak_locations = unique(max_pix(good_ii));
monoscan.nm = ins.lambda;
monoscan.peak_locations = peak_locations;
for p = length(peak_locations):-1:1
    monoscan.spec(p,:) = mean(ins.spec(max_pix==peak_locations(p),:))-darks;
    monoscan.peak(p) = max(monoscan.spec(p,:));
    monoscan.norm(p,:) = monoscan.spec(p,:)./monoscan.peak(p);
    nm_ = monoscan.norm(p,:)>0.075 & monoscan.norm(p,:)<0.99 & abs(monoscan.nm-monoscan.nm(peak_locations(p)))<20;
    [monoscan.sigma(p),monoscan.mu(p),monoscan.A(p),monoscan.FWHM(p),monoscan.peak(p)]=mygaussfit(monoscan.nm(nm_),monoscan.spec(p,nm_),0);
end
figure; plot(monoscan.nm(monoscan.peak_locations), monoscan.FWHM,'o-')
end
%%

return
