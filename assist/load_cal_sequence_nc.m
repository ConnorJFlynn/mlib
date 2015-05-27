function assist = load_cal_sequence_nc(pname, dstem)
% assist = load_cal_sequence_nc(pname, dstem)
% loads files from a selected directory and groups them according to 
% complete calibration sequences.  Populates "logi" with logical states.
for ds = 1:length(dstem)
    ann_ls = dir([pname, dstem{ds},'*ann*.*']);
    chA_ls = dir([pname, dstem{ds},'*chA_*.nc']);
    chB_ls = dir([pname, dstem{ds},'*chB_*.nc']);
    for a = length(ann_ls):-1:1
        fname = ann_ls(a).name;
        if ~isempty(strfind(fname,'.xls'))
            [xl_num, xl_txt]= xlsread([pname, fname]);
            xl_len = min([length(xl_txt(2,:)),length(xl_num(2,:))]);
            for n = xl_len:-1:1
                if any(isnumeric(xl_num(:,n)))
                    lab = legalize(xl_txt{2,n});
                    ann.(lab) = xl_num(:,n);
                end
            end
        else
            ann = rd_ann_csv([pname, fname]);
        end
        if ~exist('assist','var')
            assist.ann = ann;
        else
            [scan_nm, ii] = sort([assist.ann.ScanNumber;ann.ScanNumber]);
            ann_fields = (fieldnames(assist.ann));
            for f = length(ann_fields):-1:3
                try
                X = [assist.ann.(ann_fields{f});ann.(ann_fields{f})];
                assist.ann.(ann_fields{f}) = X(ii);
                catch
                    disp(['Problem with ', ann_fields{f}])
                end
            end
        end
        
        fname = chA_ls(a).name;
        edgar_nc = anc_load([pname, fname]);
        %         edgar_mat = loadinto([pname,fname]);
        flynn_mat = repack_edgar_nc(edgar_nc);
        if ~isempty(strfind(fname,'_HC.nc'))
            flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 5,true);% bit 5 is HBB
            flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 6,true); % bit 6 is ABB
        end
        if ~isempty(strfind(fname,'_CH.nc'))
            flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 6,true);
            flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 5,true);
        end
        if ~exist('assist','var')||~isfield(assist,'chA')
            assist.chA = flynn_mat;
        else
            assist.chA = stitch_mats(assist.chA,flynn_mat);
        end
        
        fname = chB_ls(a).name;
        edgar_nc = anc_load([pname,fname]);
        flynn_mat = repack_edgar_nc(edgar_nc);
        if ~isempty(strfind(fname,'_HC.nc'))
            flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 5,true);
            flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 6,true);
        end
        if ~isempty(strfind(fname,'_CH.nc'))
            flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 6,true);
            flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 5,true);
        end
        if ~isfield(assist,'chB')
            assist.chB = flynn_mat;
        else
            assist.chB = stitch_mats(assist.chB,flynn_mat);
        end
    end % next "a"
end %next "ds"
logi.F = bitget(assist.chA.flags,2)>0;
logi.R = bitget(assist.chA.flags,3)>0;
logi.H = bitget(assist.chA.flags,5)>0;
logi.A = bitget(assist.chA.flags,6)>0;
logi.Sky = ~(logi.H|logi.A);
sky_ii = find(logi.Sky);
logi.HBB_F = bitget(assist.chA.flags,2)&bitget(assist.chA.flags,5);
logi.HBB_R = bitget(assist.chA.flags,3)&bitget(assist.chA.flags,5);
logi.ABB_F = bitget(assist.chA.flags,2)&bitget(assist.chA.flags,6);
logi.ABB_R = bitget(assist.chA.flags,3)&bitget(assist.chA.flags,6);
logi.Sky_F = bitget(assist.chA.flags,2)& ~(bitget(assist.chA.flags,5)|bitget(assist.chA.flags,6));
logi.Sky_R = bitget(assist.chA.flags,3)& ~(bitget(assist.chA.flags,5)|bitget(assist.chA.flags,6));

assist.logi = logi;
assist.time = assist.chA.time;

return
function lab = legalize(lab)
lab = strrep(lab,' ','');
lab = strrep(lab,'-','');
lab = strrep(lab,'.','');
lab = strrep(lab,'(°)','');
return