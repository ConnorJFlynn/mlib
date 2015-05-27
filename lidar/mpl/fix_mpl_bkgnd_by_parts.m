function status = fix_mpl_bkgnd_by_parts(fid, bite_size)
%status = fix_mpl_bkgnd_by_parts(fname)
%This function recalculates background in the open raw mpl file writing the corrected values to the file.
%It returns a status of 1 if successful, a -1 if unsuccessful, a 0 if no action occurs.
%It attempts to step through the supplied file in bite-sized chuncks to prevent memory bog.
status = 0;   
%fid = fopen(fname,'r+');
if nargin<2
   bite_size = 1000000; % Read in 1 meg of data at a time unless told otherwise...
end
if (fid<1)
   status = -1;
else
   fseek(fid,0,-1);
   fidstart = ftell(fid);
   fseek(fid,0,1);
   fidend = ftell(fid);
   filesize = fidend-fidstart;
   disp(['Total length of file in bytes: ',num2str(filesize)]);
   fseek(fid,0,-1);
   
   if(filesize<43);
      status = -1;
   else
      %Read several attributes from first record to determine record size then rewind file
      A = fread(fid,44);
      fseek(fid,0,-1);
      starting_place = ftell(fid);
      binTime= A(37)*256^3 + A(38)*256^2 + A(39)*256 + A(40);
      maxAlt = A(41)*256 + A(42);
      numBins = fix( 2* (maxAlt/binTime) / (2.99792458e-4) );
      %        disp(['number of rangebins = ' num2str(numBins)]);
      profSize = 44 + 4*numBins;
      profsPerChunk = floor(bite_size / profSize);
      %    From profile size and file size (above section) determine number of recs
      numRecs = (fidend-fidstart)/profSize;
      disp(['Total profiles: ' num2str(numRecs)])
      totalProfsToRead = floor(numRecs);
      if(numRecs ~= totalProfsToRead)
         disp('This file does not appear to contain an integral number of profiles.  It may be damaged.')
         disp('Attempting to read the good portion (if any).');
      end;
      
      profsRead = 0;
      profsLeftToRead = totalProfsToRead - profsRead;
      profsToRead = min([profsLeftToRead, profsPerChunk]);
      
      while profsToRead > 0
         disp(['Reading in ', num2str(profsToRead), ' profiles.']);
         status = fix_bg_in_chunk(fid,starting_place, profSize, profsToRead);
         if status > 0
            starting_place = status;
            profsRead = profsRead + profsToRead;
            profsLeftToRead = totalProfsToRead - profsRead;
            profsToRead = min([profsLeftToRead, profsPerChunk]);
         else
            disp('There was a problem fixing the backgrounds.');
            profsToRead = 0;
         end
      end % end of "while profsToRead>0"
   end %end of "if(filesize<43)"
end %end of "if (fid<1)"
      
function status = fix_bg_in_chunk(fid, starting_place, profSize, profsToRead);
% An internal function used by fix_mpl_bkgnd_by_parts
% The status returned is the location of the file pointer if successful.  
% If unsuccessful, status is returned as -1
fseek(fid, starting_place, -1);
numBins = (profSize - 44)/4;
bigarray = zeros(profSize,profsToRead);
elementsToRead = profSize*profsToRead;
[bigarray, goodRead] = fread(fid,size(bigarray));
if (goodRead==elementsToRead)
   status = 1;
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
   fseek(fid, starting_place, -1);
   count = fwrite(fid,bigarray,'uchar');
   status = ftell(fid);
else 
   status = -1;
end;