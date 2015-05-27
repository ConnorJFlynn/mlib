% This procedure interactively requests a directory of lidar data.
% It then reads the detector A and B counts from each file and compiles
% a running list of maximum counts per profile.
% It was written to help determine the maximum (saturation) value from each
% detector in order to derive an alternative deadtime correction when the
% vendor-supplied tabled correction values were in doubt. 
        maxA = [];
        maxB = [];

disp('Please select a file from a raw data directory.');
[dirlist,pname] = dir_list('*.nc;*.cdf', 'data');
for i = 1:length(dirlist);
    disp(' ');
    disp(['Opening :', dirlist(i).name]);
    [cdfid, status] = ncmex('open', [pname dirlist(i).name], 'no_write');
    if status<0
        disp(['Problem opening ', fname])
    else
        detA = nc_getvar(cdfid, 'detector_A_532nm');
        detB = nc_getvar(cdfid, 'detector_B_532nm');

%         if isempty(maxA)
%             maxA = [max(detA)];
%             maxB = [max(detB)];
%         else
            maxA = [maxA max(detA)];
            maxB = [maxB max(detB)];
%         end;
        ncmex('close', cdfid);
        disp(['Closing ',dirlist(i).name]);
    end;
    clear detA detB;
end;
figure(1);
plot(maxA);
figure(2); 
plot(maxB);