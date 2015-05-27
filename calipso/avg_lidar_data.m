function [out] = avg_lidar_data(data,N,frameNumbers)
% This function will avgerage lidar data for N profiles.
% Inputs: 
%     data - the lidar data to average. Profiles are assumed to be stored in columns.
%     N    - the number of profile to average
%     frameNumbers - [optional] if provided, will average the data starting on a frame boundary.
%                    Note that this will only be valuable for N = 3,5, or 15.
% Outputs:
%      out - the averaged data array.

nProfiles = size(data,2);
nBins = size(data,1);

% Check if this is a 1-d array that is in the wrong format, if so switch it
if nProfiles == 1,
    nProfiles = nBins;
    nBins = 1;
    data = data';
end
 
if nargin == 3,
    nF = (frameNumbers == frameNumbers(1));
    smF = sum(nF(1:15));
    if N == 3 || N == 5,
	foo = smF / N;
    else
	foo = -1;
    end

    if  foo > 1,
	startI = mod(smF,N) + 1;
    else
	startI = find(~nF,1);
    end
else
    startI = 1;
end

nOutProfiles = floor((nProfiles -startI + 1)/N); 
out = zeros(nBins,nOutProfiles);
ind = startI;
for i=1:nOutProfiles,
    out(:,i) = mean(data(:,ind:ind+N-1),2);
    ind = ind + N;
end
