function spec = SAS_connects1(indir)
% This is a sequence of ~20 connects/disconnects of a 600 micron diameter
% fiber at the connection to a Avantes shutter.  Backgrounds at beginning
% and ending. Photodiode values (in same directory) may not be legit and
% aren't used by this code.
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
   
   %%
   con_files = dir([indir,'*avg.csv']);
   for m = (length(con_files)):-1:1
     tmp = load([indir,con_files(m).name]);
     con.nm = tmp(:,1);
     con.spec(:,m) = tmp(:,2)-darks.cts;

   end
   con.diffs = diff(con.spec,1,2);
   con.sum_spec = sum(con.spec,1);
   con.sum_diffs = diff(con.sum_spec);

  for n = 2:length(con_files)
     con.meand(:,n-1) = mean(con.spec(:,n-1:n),2);
     con.meansum(n-1) = mean(con.sum_spec(n-1:n));
  end
con.nor_diffs = abs(con.diffs ./ con.meand);
con.nor_sum_diffs = abs(con.sum_diffs./con.meansum);
figure; plot(con.nm, mean(con.nor_diffs,2),'-.');   

   
   

return
     