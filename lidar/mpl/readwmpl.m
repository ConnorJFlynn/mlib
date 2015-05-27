[fid, fname, pname] = getfile
fidstart = ftell(fid);
fseek(fid,0,1);
fidend = ftell(fid);
fseek(fid,0,-1);
if((fidend-fidstart)>43);
  A = fread(fid,44);
end; 
fseek(fid,0,-1);
binTime= A(37)*256^3 + A(38)*256^2 + A(39)*256 + A(40);
maxAlt = A(41)*256 + A(42);
numBins = fix( 2* (maxAlt/binTime) / (2.99792458e-4) )
profSize = 44 + 4*numBins;
disp(['fidstart = ' num2str(fidstart)]);
disp(['fidend = ' num2str(fidend)]);
disp(['profSize = ' num2str(profSize)]);
numProfs = (fidend-fidstart)/profSize;
disp(['Total profiles: ' num2str(numProfs)])
 if(numProfs ~= fix(numProfs))
  disp('Bad file format, not integral number of profiles.')
  bigarray = zeros(profSize,fix(numProfs));
  bigarray(:) = fread(fid,profSize*fix(numProfs));
  disp(['Size of bigarray: ' num2str(profSize*fix(numProfs))])
  break;
else
  disp('Good file format...')
  bigarray = zeros(profSize,fix(numProfs));
  bigarray(:) = fread(fid,profSize*fix(numProfs));
  disp(['Size of bigarray: ' num2str(profSize*fix(numProfs))])
  ID = bigarray(1,:);
  bigarray(1,:) = [];

  date = bigarray(3,:) + 100*bigarray(2,:) + 100^2*bigarray(1,:);
  bigarray(1:3,:) = [];

  time = bigarray(4,:)/100 + bigarray(3,:) + 100*bigarray(2,:) + 100^2*bigarray(1,:);
  bigarray(1:4,:) = [];

  shots_summed = bigarray(4,:) + 256*bigarray(3,:) + 256^2*bigarray(2,:) + 256^3*bigarray(1,:);
  bigarray(1:4,:) = [];

  PRF = bigarray(2,:) + 256*bigarray(1,:);
  bigarray(1:2,:) = [];

  e_monitor = (bigarray(2,:) + 256*bigarray(1,:))/1000;
  bigarray(1:2,:) = [];

  detector_temp = (bigarray(2,:) + 256*bigarray(1,:))/100;
  bigarray(1:2,:) = [];

  filter_temp = (bigarray(2,:) + 256*bigarray(1,:))/100;
  bigarray(1:2,:) = [];

  case_temp = (bigarray(2,:) + 256*bigarray(1,:))/100;
  bigarray(1:2,:) = [];

  laser_temp = (bigarray(2,:) + 256*bigarray(1,:))/100;
  bigarray(1:2,:) = [];

  V_10 = (bigarray(2,:) + 256*bigarray(1,:))/1000;
  bigarray(1:2,:) = [];

  V_5 = (bigarray(2,:) + 256*bigarray(1,:))/1000;
  bigarray(1:2,:) = [];

  V_15 = (bigarray(2,:) + 256*bigarray(1,:))/1000;
  bigarray(1:2,:) = [];

  cbh = bigarray(2,:) + 256*bigarray(1,:);
  bigarray(1:2,:) = [];

  bkgnd = bigarray(4,:) + 256*bigarray(3,:) + 256^2*bigarray(2,:) + 256^3*bigarray(1,:);
  bigarray(1:4,:) = [];
  bkgnd = bkgnd/1e8;

  F = figure;
  plot(time, bkgnd);
  Title(['Background value for ' setstr(fname)]);
  XLabel('Time');
  YLabel('Counts per ?');
  axis([min(time),max(time),0,50e6]);
  zoom('on');

clear binTime;
  binTime = bigarray(4,:) + 256*bigarray(3,:) + 256^2*bigarray(2,:) + 256^3*bigarray(1,:);
  bigarray(1:4,:) = [];
clear maxAlt;
  maxAlt = bigarray(2,:) + 256*bigarray(1,:);
  bigarray(1:2,:) = [];
  dt_corr = bigarray(2,:) + 256*bigarray(1,:);
  bigarray(1:2,:) = [];

  profbins = zeros(4,numBins*numProfs);
  profbins(:) = bigarray(1:4*numBins,:);
  bigarray = [];
  profbins(1,:) = profbins(4,:) + 256*profbins(3,:) + 256^2*profbins(2,:) + 256^3*profbins(1,:);
  profbins(2:4,:) = [];
  profiles = zeros(numBins,numProfs);
  profiles(:) = profbins/1e8;
  profbins = [];
end;
fclose(fid);
