function status = fix_mpl_bkgnd_one_file(fid)
%status = fix_mpl_bkgnd_one_file(fname)
%This function recalculates background in the open raw mpl file writing the corrected values to the file.
%It returns a status of 1 if successful, a -1 if unsuccessful, a 0 if no action occurs.
status = 0;   
%fid = fopen(fname,'r+');
if fid<1
   status = -1;
else
    fidstart = ftell(fid);
    fseek(fid,0,1);
    fidend = ftell(fid);
    disp(['Total length of file in bytes: ',num2str(fidend - fidstart)]);
    fseek(fid,0,-1);
    if((fidend-fidstart)<43);
       status = -1;
    else
        %Read several attributes from first record to determine record size then rewind file
        A = fread(fid,44);
        fseek(fid,0,-1);
        binTime= A(37)*256^3 + A(38)*256^2 + A(39)*256 + A(40);
        maxAlt = A(41)*256 + A(42);
        numBins = fix( 2* (maxAlt/binTime) / (2.99792458e-4) );
%        disp(['number of rangebins = ' num2str(numBins)]);
        profSize = 44 + 4*numBins;
        %    From profile size and file size (above section) determine number of recs
        numRecs = (fidend-fidstart)/profSize;
        disp(['Total profiles: ' num2str(numRecs)])
        if(numRecs ~= floor(numRecs))
            disp('This file does not contain an integral number of profiles.  It may be damaged.')
            disp('Attempting to read the good portion (if any).');
        end;
        profsToRead = floor(numRecs);
        clear bigarray temparray time shots_summed bkgnd dt_corr profbins
        bigarray = zeros(profSize,profsToRead);
        elementsToRead = profSize*profsToRead;
        bigarray(:) = fread(fid,elementsToRead);
        fseek(fid,0,-1);
        time = bigarray(8,:)/100 + bigarray(7,:) + 100*bigarray(6,:) + 100^2*bigarray(5,:);
        shots_summed = bigarray(12,:) + 256*bigarray(11,:) + 256^2*bigarray(10,:) + 256^3*bigarray(9,:);
        old_bkgnd = bigarray(36,:) + 256*bigarray(35,:) + 256^2*bigarray(34,:) + 256^3*bigarray(33,:);
        %Set dt_corr bytes to zero in big_array
        bigarray(43,:) = zeros(1,length(bigarray(43,:)));
        bigarray(44,:) = zeros(1,length(bigarray(44,:)));
        dt_corr = bigarray(44,:) + 256*bigarray(43,:);
        profbins = zeros(4,numBins*profsToRead);
        profbins(:) = bigarray(44+[1:4*numBins],:);
        profbins(1,:) = profbins(4,:) + 256*profbins(3,:) + 256^2*profbins(2,:) + 256^3*profbins(1,:);
        profbins(2:4,:) = [];
        profiles = zeros(numBins,profsToRead);
        profiles(:) = profbins;
        newbg = mean(profiles(floor(numBins*(44/60)):floor(numBins*(59/60)),:));
        temp = newbg;
        % Populate bigarray with new bkgnd values
        bigarray(36,:) = floor(rem(temp,256));
        temp = floor(temp/256);
        bigarray(35,:) = rem(temp,256);
        temp = floor(temp/256);
        bigarray(34,:) = rem(temp,256);
        temp = floor(temp/256);
        bigarray(33,:) = rem(temp,256);
        newbg = bigarray(36,:) + 256*bigarray(35,:) + 256^2*bigarray(34,:) + 256^3*bigarray(33,:);
        disp(['difference between backgrounds = ' num2str(old_bkgnd(1)-newbg(1))]);	
        disp([' ']);
        fwrite(fid,bigarray,'uchar');
        %      end; %end of while
        %         else
        %             disp(['Bad file format for:' file_in_dir])
        %             bigarray = zeros(profSize,fix(numRecs));
        %             bigarray = fread(fid,profSize*fix(numRecs));
        %             disp(['Size of bigarray: ' num2str(profSize*fix(numRecs))]);
        %             break;
        status = 1;
        %fclose(fid);
    end; %end of if file > 43 bytes 
 end;