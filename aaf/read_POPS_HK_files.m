function read_POPS_HK_files(rawdata_dir)%
close all;
%*** get Dp from each instruments ****
POPS_num=269;
plot_option=1;
% ts0=datenum(2020,11,13,1,21,0)-datenum(2000,1,1,11,0,0);
ts0=0;
camp_name='SGP';%'PUR';
% site='sgp';
switch POPS_num  
    case 99
        nbin=12;  % POPS size bin, default for UAV, nbin=100; for TBS, nbin=12
        st_idx=28;
    case {269}
        nbin=100;  % POPS size bin, default for UAV, nbin=100; for TBS, nbin=12
        st_idx=34;
        idx_popsQ=16; idx_Temp=21; idx_LDTB=18; idx_P=11; idx_N=6; % for new version, total=28+nbin 
    case {40,9}
        nbin=100;
        idx_popsQ=9; idx_Temp=14; idx_LDTB=11; idx_P=7; idx_N=3; % for new version, total=28+nbin 
        st_idx=28;
end
    
switch nbin
    case 12
        DpB=[134,150,170,194,219,255,329,502,688,1200,1612,2572,3405]; %old size for TBS version,
        Dp12=(DpB(1:(end-1))+DpB(2:end))/2;
    case 100
%         [rs_file, rs_dir]= uigetfile({'Dp*.txt'},'Select POPS size bin file', 'Multiselect', 'on');  %input('input .txt file to read: ','s');
%         rs_file='Dp100_1p6.txt';
        rs_file='Dp100_1p76.txt';
        DpB=load(rs_file);
        DpB12=[134,150,170,194,219,255,329,502,688,1200,1612,2572,3405]; 
        Dp12=(DpB12(1:(end-1))+DpB12(2:end))/2;
end
% DpB=[135,150,170,195,220,260,335,510,705,1380,1760,2550,3615];%
Dp=(DpB(1:(end-1))+DpB(2:end))/2;
dlogDp=log(DpB(2:end)./DpB(1:(end-1)))/log(10);
dDp=DpB(2:end)-DpB(1:(end-1));
dDp12=DpB12(2:end)-DpB12(1:(end-1));

if nargin< 1
 [filename, rawdata_dir]= uigetfile({'*.csv'}, 'Multiselect', 'on');  %input('input .mat file to read: ','s');
else
     [filename, rawdata_dir]= uigetfile({[rawdata_dir,'*.csv']},'Select a .csv file', 'Multiselect', 'on');  %input('input .mat file to read: ','s');
end

save_file=[];

k5=strfind(rawdata_dir,'SN09');
k6=strfind(rawdata_dir,'SN269');
k7=strfind(rawdata_dir,camp_name);

if iscell(filename)
    filename=natsortfiles(filename);
    mnum=size(filename,2);
    filename0=filename{1};
else
    mnum=1;
    filename0=filename;
end

if isempty(save_file)
    save_file=[rawdata_dir,'POPS.mat'];
end

for i=1:mnum
    if ~iscell(filename)
        pops_name=[rawdata_dir,filename];
    else
   pops_name=[rawdata_dir,filename{i}];
    end
   M1=importdata(pops_name,',',1);
   var_name=strsplit(M1.textdata{1},',');
   t1=M1.data(:,1)/3600/24+datenum(1970,1,1);

      if i==1
          MC=M1.data(:,2:end);
          tnum=t1;
          
      else
          MC=vertcat(MC,M1.data(:,2:end));
          tnum=[tnum;t1];
      end
      
      tidx=find(tnum<datenum(filename0(4:11),'yyyymmdd'));
      tnum(tidx)=[];
      MC(tidx,:)=[];
   clear t1 M1;
      
end
tnum=tnum+ts0;

MSave.MC=MC; MSave.tnum=tnum; MSave.var_name=var_name;
MSave.Dp=Dp; MSave.dlogDp=dlogDp;
    Q=smooth(MC(:,idx_popsQ),140);
   n = bsxfun(@rdivide, MC(:,st_idx:(st_idx+nbin-1)), Q);
   MSave.SD= n./dlogDp';
   n(n<=0)=NaN;
   Ncal=nansum(n,2);
   switch POPS_num
       case {9,269}
           if nbin==12
               nn=n;MSave.nn=n;
           else
               nn0=interp1(Dp',(n./dDp')',Dp12);
               nn=nn0'.*dDp12; MSave.nn=nn; 
               Ncal_nn=nansum(nn,2);
           end
          
   end
   flt_num=datestr(tnum(1),'yyyymmdd');
   
    if ~isempty(k5)
        pst=strrep(rawdata_dir,'SN09\','');
        save_file=[pst,filename0(4:11),'_SN09.mat'];
    end

    if ~isempty(k6)
        pst=strrep(rawdata_dir,'SN269\','');
        save_file=[pst,filename0(4:11),'_SN269.mat'];
    end
  
   save(save_file,'MSave');
    clear MSave;


end

