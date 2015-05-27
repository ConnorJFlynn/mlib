function [pbl,bnd] = pbl_filter(range, backscatter, bins, lowest_bin)
%pbl = pbl_filter(range, backscatter, bins, lowest_bin);
% default haar wavelet bin width 'bins'[10:5:40]
% default lowest_bin = min(bins);
if ~exist('bins','var')
    bins = [10:5:40];
end
if ~exist('lowest_bin','var')
    %lowest bin can't be lower than 4 or zero subscripts result below
    lowest_bin = max([min(bins)-1,4]);
end
pbl = -0*ones([1,size(backscatter,2)]);     % Initialize the boundary flag

%%
for t=size(backscatter, 2):-1:1                          % Loop over the profiles in this day
    %r2smoothed=sgolayfilt(backscatter(:,imin),3,5);     % Smooth the data
    c1 = cwt(backscatter(:,t), bins, 'haar'); % Do a cwt  - - Note that you can change the values "5:10" to make it more/less sensitve
    if length(bins)>1
    cmean = mean(c1); % Take the average of them to eliminate noise
    else
        cmean = c1;
    end
    bnd(:,t) = cmean;
    % This section finds the layer top as the relative maxima in c4mean 
    max_index=[];
    i=lowest_bin;		% start at 5th index
    while i < length(cmean)-(lowest_bin+1),
        if ((cmean(i) > cmean(i-1))&&(cmean(i) > cmean(i-3)))    % Check to see if this pt is more than the prev 2 pts
            if ((cmean(i) > cmean(i+1))&&(cmean(i) > cmean(i+3)))	% Check to see if this pt is more than the next 2 pts
                if (cmean(i) > 0.01)                      % threshold
                    max_index = [max_index i];                % Update the index array
                end
            end
        end
        i = i + 1;
    end
    if isempty(max_index)
        max_index = 1;
    end
    pbl(t)=range(min(max_index));
end


