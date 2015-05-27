clear
pname = ['E:\case_studies\mega_xmfrx_reproc\sgpmfrsrC1.c1\summers\'];
mfr_files = dir([pname, filesep,'*.cdf']);
for f = 1:length(mfr_files)
    disp(['Processing ',mfr_files(f).name,': ',num2str(f),' of ',num2str(length(mfr_files))])
    nc = ancload([pname,filesep, mfr_files(f).name]);
    if f == 1
        [pname,fname] = fileparts(nc.fname);
        fname = strtok(fname,'.');
        pname = [pname, filesep];
    end
    fid1 = fopen([pname,fname,'.eps_lte_1en5.txt'],'a');
    fseek(fid1,0,1);
    fid2 = fopen([pname,fname,'.eps_lte_5en45.txt'],'a');
    fseek(fid2,0,1);
%     fid3 = fopen([pname,fname,'.eps_lte_1en3.txt'],'a');
%     fseek(fid3,0,1);
%     [aero, eps] = aod_screen(nc.time, nc.vars.aerosol_optical_depth_filter2.data);
%%
    qc.data = nc.vars.qc_aerosol_optical_depth_filter2.data;
    bad = zeros(['u',class(qc.data)]);
    bad = bitset(bad,1,1); bad = bitset(bad,2,1); bad = bitset(bad,4,1);    bad = bitset(bad,5,1);
    bad_times = bitand(bad .* uint32(ones(size(qc.data))),uint32(qc.data))>0;
    [aero,eps] = aod_screen(nc.time, nc.vars.aerosol_optical_depth_filter2.data,0,2.25,5, 2, 1e-2,5,10,.2);
    windowSize = 5;
    aero = filter(ones(1,windowSize)/windowSize,1,aero&~bad_times);
    aero = (aero==1);
    [nc1, nc2]= ancsift(nc, nc.dims.time, aero);
    if length(nc1.time)>0
    status = aod_output(nc1, fid1);
    end
    
    bad = zeros(['u',class(qc.data)]);
    bad = bitset(bad,1,1); bad = bitset(bad,2,1); bad = bitset(bad,4,1);    bad = bitset(bad,5,1);
    bad_times = bitand(bad .* uint32(ones(size(qc.data))),uint32(qc.data))>0;
    [aero,eps] = aod_screen(nc.time, nc.vars.aerosol_optical_depth_filter2.data,0,1.25,5, 6, 5e-5,5,10,.2);
    windowSize = 5;
    aero = filter(ones(1,windowSize)/windowSize,1,aero&~bad_times);
    aero = (aero==1);
    [nc1, nc2]= ancsift(nc, nc.dims.time, aero);
    if length(nc1.time)>0
    status = aod_output(nc1, fid2);
    end
% 
%     bad = zeros(['u',class(qc.data)]);
%     bad = bitset(bad,1,1); bad = bitset(bad,2,1); bad = bitset(bad,4,1);    bad = bitset(bad,5,1);
%     bad_times = bitand(bad .* uint32(ones(size(qc.data))),uint32(qc.data))>0;
%     [aero,eps] = aod_screen(nc.time, nc.vars.aerosol_optical_depth_filter2.data,0,1.25,5, 6, 1e-3,5,10,.2);
%     windowSize = 5;
%     aero = filter(ones(1,windowSize)/windowSize,1,aero&~bad_times);
%     aero = (aero==1);
%     [nc1, nc2]= ancsift(nc, nc.dims.time, aero);
%     if length(nc1.time)>0
%     status = aod_output(nc1, fid3);
%     end

    fclose(fid1);
    fclose(fid2);
%     fclose(fid3);
end
disp('Done with MFRSR C1...')
clear
pname = ['E:\case_studies\mega_xmfrx_reproc\sgpmfrsrE13.c1\summers\'];
mfr_files = dir([pname, filesep,'*.cdf']);
for f = 1:length(mfr_files)
    disp(['Processing ',mfr_files(f).name,': ',num2str(f),' of ',num2str(length(mfr_files))])
    nc = ancload([pname,filesep, mfr_files(f).name]);
    if f == 1
        [pname,fname] = fileparts(nc.fname);
        fname = strtok(fname,'.');
        pname = [pname, filesep];
    end
    fid1 = fopen([pname,fname,'.eps_lte_1en5.txt'],'a');
    fseek(fid1,0,1);
    fid2 = fopen([pname,fname,'.eps_lte_5en45.txt'],'a');
    fseek(fid2,0,1);
%     fid3 = fopen([pname,fname,'.eps_lte_1en3.txt'],'a');
%     fseek(fid3,0,1);
%     [aero, eps] = aod_screen(nc.time, nc.vars.aerosol_optical_depth_filter2.data);
%%
    qc.data = nc.vars.qc_aerosol_optical_depth_filter2.data;
    bad = zeros(['u',class(qc.data)]);
    bad = bitset(bad,1,1); bad = bitset(bad,2,1); bad = bitset(bad,4,1);    bad = bitset(bad,5,1);
    bad_times = bitand(bad .* uint32(ones(size(qc.data))),uint32(qc.data))>0;
    [aero,eps] = aod_screen(nc.time, nc.vars.aerosol_optical_depth_filter2.data,0,1.25,5, 6, 1e-5,5,10,.2);
    windowSize = 5;
    aero = filter(ones(1,windowSize)/windowSize,1,aero&~bad_times);
    aero = (aero==1);
    [nc1, nc2]= ancsift(nc, nc.dims.time, aero);
    if length(nc1.time)>0
    status = aod_output(nc1, fid1);
    end
    
    bad = zeros(['u',class(qc.data)]);
    bad = bitset(bad,1,1); bad = bitset(bad,2,1); bad = bitset(bad,4,1);    bad = bitset(bad,5,1);
    bad_times = bitand(bad .* uint32(ones(size(qc.data))),uint32(qc.data))>0;
    [aero,eps] = aod_screen(nc.time, nc.vars.aerosol_optical_depth_filter2.data,0,1.25,5, 6, 5e-5,5,10,.2);
    windowSize = 5;
    aero = filter(ones(1,windowSize)/windowSize,1,aero&~bad_times);
    aero = (aero==1);
    [nc1, nc2]= ancsift(nc, nc.dims.time, aero);
    if length(nc1.time)>0
    status = aod_output(nc1, fid2);
    end
% 
%     bad = zeros(['u',class(qc.data)]);
%     bad = bitset(bad,1,1); bad = bitset(bad,2,1); bad = bitset(bad,4,1);    bad = bitset(bad,5,1);
%     bad_times = bitand(bad .* uint32(ones(size(qc.data))),uint32(qc.data))>0;
%     [aero,eps] = aod_screen(nc.time, nc.vars.aerosol_optical_depth_filter2.data,0,1.25,5, 6, 1e-3,5,10,.2);
%     windowSize = 5;
%     aero = filter(ones(1,windowSize)/windowSize,1,aero&~bad_times);
%     aero = (aero==1);
%     [nc1, nc2]= ancsift(nc, nc.dims.time, aero);
%     if length(nc1.time)>0
%     status = aod_output(nc1, fid3);
%     end

    fclose(fid1);
    fclose(fid2);
%     fclose(fid3);
end
disp('Done with MFRSR E13...')
clear
pname = ['E:\case_studies\mega_xmfrx_reproc\sgpnimfrC1.c1\summers\'];
mfr_files = dir([pname, filesep,'*.cdf']);
for f = 1:length(mfr_files)
    disp(['Processing ',mfr_files(f).name,': ',num2str(f),' of ',num2str(length(mfr_files))])
    nc = ancload([pname,filesep, mfr_files(f).name]);
    if f == 1
        [pname,fname] = fileparts(nc.fname);
        fname = strtok(fname,'.');
        pname = [pname, filesep];
    end
    fid1 = fopen([pname,fname,'.eps_lte_1en5.txt'],'a');
    fseek(fid1,0,1);
    fid2 = fopen([pname,fname,'.eps_lte_5en45.txt'],'a');
    fseek(fid2,0,1);
%     fid3 = fopen([pname,fname,'.eps_lte_1en3.txt'],'a');
%     fseek(fid3,0,1);
%     [aero, eps] = aod_screen(nc.time, nc.vars.aerosol_optical_depth_filter2.data);
%%
    qc.data = nc.vars.qc_aerosol_optical_depth_filter2.data;
    bad = zeros(['u',class(qc.data)]);
    bad = bitset(bad,1,1); bad = bitset(bad,2,1); bad = bitset(bad,4,1);    bad = bitset(bad,5,1);
    bad_times = bitand(bad .* uint32(ones(size(qc.data))),uint32(qc.data))>0;
    [aero,eps] = aod_screen(nc.time, nc.vars.aerosol_optical_depth_filter2.data,0,1.25,5, 6, 1e-5,5,10,.2);
    windowSize = 5;
    aero = filter(ones(1,windowSize)/windowSize,1,aero&~bad_times);
    aero = (aero==1);
    [nc1, nc2]= ancsift(nc, nc.dims.time, aero);
    if length(nc1.time)>0
    status = aod_output(nc1, fid1);
    end
    
    bad = zeros(['u',class(qc.data)]);
    bad = bitset(bad,1,1); bad = bitset(bad,2,1); bad = bitset(bad,4,1);    bad = bitset(bad,5,1);
    bad_times = bitand(bad .* uint32(ones(size(qc.data))),uint32(qc.data))>0;
    [aero,eps] = aod_screen(nc.time, nc.vars.aerosol_optical_depth_filter2.data,0,1.25,5, 6, 5e-5,5,10,.2);
    windowSize = 5;
    aero = filter(ones(1,windowSize)/windowSize,1,aero&~bad_times);
    aero = (aero==1);
    [nc1, nc2]= ancsift(nc, nc.dims.time, aero);
    if length(nc1.time)>0
    status = aod_output(nc1, fid2);
    end
% 
%     bad = zeros(['u',class(qc.data)]);
%     bad = bitset(bad,1,1); bad = bitset(bad,2,1); bad = bitset(bad,4,1);    bad = bitset(bad,5,1);
%     bad_times = bitand(bad .* uint32(ones(size(qc.data))),uint32(qc.data))>0;
%     [aero,eps] = aod_screen(nc.time, nc.vars.aerosol_optical_depth_filter2.data,0,1.25,5, 6, 1e-3,5,10,.2);
%     windowSize = 5;
%     aero = filter(ones(1,windowSize)/windowSize,1,aero&~bad_times);
%     aero = (aero==1);
%     [nc1, nc2]= ancsift(nc, nc.dims.time, aero);
%     if length(nc1.time)>0
%     status = aod_output(nc1, fid3);
%     end

    fclose(fid1);
    fclose(fid2);
%     fclose(fid3);
end
disp('Done with NIMFR C1...')
