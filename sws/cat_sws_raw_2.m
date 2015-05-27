function sws1 = cat_sws_raw_2(sws1,sws2);
% sw1 = cat_sws_raw(sws1,sws2);
% concatenates two raw sws files using unique to yield sorted order
if ~exist('sws1','var')|isempty(sws1)
    sws1 = read_sws_raw_2;
else
    if exist('sws2','var')
        [sws1.time, time_ind] = unique([sws1.time, sws2.time]);
        flds = fieldnames(sws1);
        for f = 1:length(flds)
            if ~strcmp(flds{f},'time')
                if any(length(sws2.time)==size(sws2.(flds{f})))
                    if size(sws2.(flds{f}),1)~=1
                        tmp = [sws1.(flds{f}),sws2.(flds{f})];
                        sws1.(flds{f})= tmp(:,time_ind);
                    else
                        tmp = [sws1.(flds{f}),sws2.(flds{f})];
                        sws1.(flds{f})= tmp(time_ind);
                    end
                end
            end
        end
    end
end

%%
% figure(98);
% plot([1:length(sws1.time)],serial2doy(sws1.time), 'o')
%%

return