function spec = SAS_connects_by10_3(indir)
% This is a sequence of groups of ~10 connects/disconnects followed by ~10 repeat spectra.
% Backgrounds at beginning and ending. Photodiode values aren't used by this code.
% This is connect/disconnect of the collimator
% From the readme file, :
% file numbers that are disconnects
% 12
% 23
% 34
% 44
% 56
% 67
% 78
% 89
% 100
% 
% 2-11 repeats at begining
% 12 disconnected
% 13-22 repeats after disconnect
% 
% Photodiode data =  mean,std


if ~exist('indir','var')
   indir = getdir;
end
ridni = fliplr(indir);
pmt = fliplr(strtok(ridni(2:end),filesep));

   dark_files = dir([indir,'*_Back.csv']);
   for dk = length(dark_files):-1:1

      [dmp,tmp] = strtok(dark_files(dk).name,'_');
%       dark_nm(dk) = sscanf(dmp,'%d');
     [tint, tmp]= strtok(tmp,'_');
     tint = sscanf(tint, '%d');
     dark_tint(dk) = tint;
     CCD_dark = load([indir,dark_files(dk).name]);
     dark_cts(:,dk) = CCD_dark(:,2);

   end
% sort dark counts in order of tint
[dark_tints] = unique(dark_tint);
for dk = length(dark_tints):-1:1
   dk_tf = dark_tint==dark_tints(dk);
   if sum(dk_tf)==1
      darks.tint(dk) = dark_tint(dk_tf);
      darks.cts(:,dk) = dark_cts(:,dk_tf);
   else
      darks.tint(dk) = mean(dark_tint(dk_tf));
      darks.cts(:,dk) = mean(dark_cts(:,dk_tf),2);
   end
end
%%
% 12
% 23
% 34
% 44
% 56
% 67
% 78
% 89
% 100
      disc = [12; 23; 34;  45; 56; 67; 78; 89; 100]; %previous test
      disc = [12; 23; 34;  44; 56; 67; 78; 89; 100]; % new
   connect.starts = [1; disc];
   connect.ends = [disc-1; 109];
   %%

   
   %%
   con_files = dir([indir,'*avg.csv']);
   for m = (length(con_files)):-1:1
     tmp = load([indir,con_files(m).name]);
     [N_, dmp] = strtok(con_files(m).name,'_');
     con.N(m) = sscanf(N_,'%d');
     con.group(m) = find(connect.starts<=con.N(m) & connect.ends>=con.N(m));
     con.nm = tmp(:,1);
     con.spec(:,m) = (tmp(:,2) -darks.cts);
     con.sum(m) = sum(tmp(400:700,2) -darks.cts(400:700));
     tmp = load([indir,num2str(N_),'_Photodiode.csv']);
     con.pd(m) = tmp(1);
     con.pd_std(m) = tmp(2);
   end
[con.N, inds] = sort(con.N);
con.group = con.group(inds);
con.sum = con.sum(inds);
con.pd = con.pd(inds);
con.pd_std = con.pd_std(inds);
%%
   for c = [length(connect.starts)-1]:-1:2
      con_tf = con.N>=connect.starts(c) & con.N<=connect.ends(c);
      both_tf = con.N>=connect.starts(c) & con.N<=connect.ends(c+1);
      connect.mean_spec(:,c-1) = mean(con.spec(:,con_tf),2);
      connect.mean_spec_both(:,c-1) = mean(con.spec(:,both_tf),2);
      connect.mean_sum(c-1) = mean(con.sum(con_tf));
      connect.mean_sum_both(c-1) = mean(con.sum(both_tf));
      connect.std_sum(c-1) = (std(con.sum(con_tf)))./connect.mean_sum(c-1);
      connect.std_sum_both(c-1) = (std(con.sum(both_tf)))./connect.mean_sum_both(c-1);
      connect.std_spec(:,c-1) = std(con.spec(:,con_tf),0,2)./mean(con.spec(:,con_tf),2);
      connect.std_spec_both(:,c-1) = std(con.spec(:,both_tf),0,2)./mean(con.spec(:,both_tf),2);
   end
   
   figure; plot([1:length(connect.starts)-2],connect.std_sum.*100, 'x',...
      [1:length(connect.starts)-2],connect.std_sum_both.*100,'o');
   mean_std_in = mean(connect.std_sum.*100);
   mean_std_crs = mean(connect.std_sum_both.*100);
   title('Connection repeatability test');
   legend(['stddev within group (mean=',sprintf('%1.2g',mean_std_in),'%)'],...
      ['stddev across group (mean=',sprintf('%1.2g',mean_std_crs),'%)']);
   ylabel('deviation in %')
   xlabel('index number')
   %%
   
   figure; plot([1:length(connect.starts)-2],connect.std_spec(400:200:1200,:).*100, '-x',...
      [1:length(connect.starts)-2],connect.std_spec_both(400:200:1200,:).*100,'-o');
   mean_std_in = mean(connect.std_spec(400:200:1200,:).*100);
   mean_std_crs = mean(connect.std_spec_both(400:200:1200,:).*100);
   title('Connection repeatability test');
   legend(['stddev within group (mean=',sprintf('%1.2g ',mean_std_in),'%)'],...
      ['stddev across group (mean=',sprintf('%1.2g ',mean_std_crs),'%)']);
   ylabel('deviation in %')
   xlabel('index number')
   
   %%
   figure; ax(1)= subplot(2,1,1); plot(con.nm, connect.std_spec.*100, '-');
   ax(2) = subplot(2,1,2); plot(con.nm, connect.std_spec_both.*100,'-');
   linkaxes(ax,'xy');
   %%
   %%
return
     