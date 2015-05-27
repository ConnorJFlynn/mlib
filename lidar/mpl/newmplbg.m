[fid, fname, pname] = getfile
%Open file, determine if it is larger than 43 bytes.  If so, read first 44 bytes.
  fidstart = ftell(fid);
  fseek(fid,0,1);
  fidend = ftell(fid);
  fseek(fid,0,-1);
  if((fidend-fidstart)>43);
    A = fread(fid,44);
  end; 
%rewind file
  fseek(fid,0,-1); 

%Read several attributes from first record to determine record size
  binTime= A(37)*256^3 + A(38)*256^2 + A(39)*256 + A(40);
  maxAlt = A(41)*256 + A(42);
  numBins = fix( 2* (maxAlt/binTime) / (2.99792458e-4) )
  profSize = 44 + 4*numBins;
  disp(['fidstart = ' num2str(fidstart)]);
  disp(['fidend = ' num2str(fidend)]);
  disp(['profSize = ' num2str(profSize)]);
%From record size and file size (above) determine number of recs
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
    %While at least 1 full record left, read up to 50 records and process...
    remaining = floor((fidend - ftell(fid))/profSize);
    profsToRead = min([remaining,50]);
    i = 0;
    while (profsToRead>0)
	i = i + profsToRead;
	disp(['reading up to profile = ' num2str(i)]);
	clear bigarray;
	clear time;
	clear shots_summed;
	clear bkgnd;
	clear dt_corr;
	clear profbins;
	bigarray = zeros(profSize,profsToRead);
        block_start = ftell(fid);
	bigarray(:) = fread(fid,profSize*profsToRead);
	temp = fseek(fid,block_start,-1);
	time = bigarray(8,:)/100 + bigarray(7,:) + 100*bigarray(6,:) + 100^2*bigarray(5,:);
	shots_summed = bigarray(12,:) + 256*bigarray(11,:) + 256^2*bigarray(10,:) + 256^3*bigarray(9,:);
	bkgnd = bigarray(36,:) + 256*bigarray(35,:) + 256^2*bigarray(34,:) + 256^3*bigarray(33,:);
	%Set dt_corr bytes to zero
	bigarray(44,:) = zeros(1,length(bigarray(44,:)));
	bigarray(43,:) = zeros(1,length(bigarray(43,:)));
	dt_corr = bigarray(44,:) + 256*bigarray(43,:);
	profbins = zeros(4,numBins*profsToRead);
	profbins(:) = bigarray(44+[1:4*numBins],:);
	profbins(1,:) = profbins(4,:) + 256*profbins(3,:) + 256^2*profbins(2,:) + 256^3*profbins(1,:);
	profbins(2:4,:) = [];
	profiles = zeros(numBins,profsToRead);
	profiles(:) = profbins;
	newbg = mean(profiles(floor(numBins*(44/60)):floor(numBins*(59/60)),:));
	temp = newbg;
	bigarray(36,:) = floor(rem(temp,256));
	temp = floor(temp/256);
	bigarray(35,:) = rem(temp,256);
	temp = floor(temp/256);
	bigarray(34,:) = rem(temp,256);
	temp = floor(temp/256);
	bigarray(33,:) = rem(temp,256);
        newbg = bigarray(36,:) + 256*bigarray(35,:) + 256^2*bigarray(34,:) + 256^3*bigarray(33,:);
	[bkgnd(1)-newbg(1)]	
	F = figure;
	plot(time, bkgnd, 'y', time, newbg, 'c');
	Title(['Background value for ' setstr(fname)]);
	XLabel('Time');
	YLabel('Counts per ?');
%	axis([min(time),max(time),0,50e6]);
	zoom('on');
	disp('Writing to file');
        fwrite(fid,bigarray,'uchar');
	remaining = floor((fidend - ftell(fid))/profSize);
	profsToRead = min([remaining,50]);
    end; %end of while
  end; %end of if-else

fclose(fid);

