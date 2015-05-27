function pe = proc_pe_slab(pe,ins);
if ~exist('pe','var')|isempty(pe)
   %If the input argument 'pe' doesn't exist, load a new file.
   % pe is a structure having the following elements:
   %  pe.bins, the number of bins per profiel
   %  pe.us, the number of microseconds per bin
   %  pe.fname, the full pathname of the file the data was read from.
   %  pe.profs, the number of profiles contained in the file
   %  pe.trace, [bins x profs] size matrix containing the pulse echo traces. 
   pe = read_pe_raw;
end
if ~exist('ins','var')
   %If the input argument 'ins' hasn't been provided, initialize it empty.
   ins.slab_win = [];
   ins.no_bed = [];
end
if ~isfield(ins,'slab_win')|isempty(ins.slab_win)
   % if the slab width 'slab_win' hasn't been provided, set a default value
   % of 10 or the number of incoming profiles, whichever is smaller.
   ins.slab_win = min(10,pe.profs);
end
if ~isfield(ins,'no_bed')|isempty(ins.no_bed)
   % If an initial zero bed depth profile hasn't been provided by the user
   % then load a previously save one.
   ins.no_bed = loadinto('pe_no_bed.mat');
end

%Disect the incoming file name so that we can save plots to the same place.
[pname, fname, ext] = fileparts(pe.fname);

%Load the incoming "no bed depth" trace into the data structure.
pe.no_bed = ins.no_bed;

%Load the incoming slab window into the data structure.
pe.slab_win = ins.slab_win;

%Pre-define a variable to hold the computed bed-depths.  Populate it with
%NaNs initially.
pe.bed = NaN([1,pe.profs]);

% Subtract the zero-bed depth profile from each incoming trace.
pe.trace2 = pe.trace - pe.no_bed*ones([1,pe.profs]);

% The following function "remove artifacts" generates a weighting vector of length 1xbins.  
% The weights are selected to reduce the impact of measurement artifacts
% including the transducer ringing, the second tank reflection, and the
% gradual decrease in signal amplitude as a function of bin.
arts = remove_artifacts(pe);

% Multiply the weighted profile by the mean of the measured profiles and
% subtract 80% of this signal from each and every trace.  The Matlab
% function "mean" acts along a single dimension of the supplied variable.
% That is, if A is size [1xN], then mean(A) will yield a scalar.  However,
% if A is size [MxN], then mean(A) yields a vector of length N.
% Alternatively, mean(A,n) where n is either a 1 or 2 will force mean to
% operate along the specified dimensions.  mean(A,1) results in size [1xN]
% while mean(A,2) yields size [Mx1].
pe.trace2 = pe.trace2 - 0.8.*arts.*mean(pe.trace2,2)*ones([1,pe.profs]);

%The following "figure" commands position graphics windows. Ignore them.
figure(10); set(gcf,'position',[ 20    38   560   420]);
figure(11); set(gcf,'position',[616    38   560   420]);


% Now, step through the measured traces with a step size of pe.slab_win
for p = pe.slab_win:pe.slab_win:pe.profs

   % Define a block or "slab" of traces
   slab = [(p-pe.slab_win+1):p];

   % Find the first non-blanked point.  If you know your pulse is going to
   % be well-synced, then you can move this outside of this loop.
   start = find(mean(pe.trace(:,slab),2)>0,1,'first');
   pe.start = start;
   
   % This computes the variance along a single dimension.  It is similar to
   % mean and max in that it operates along a single dimension, in this
   % case the second dimension.  So this results in a variance profile as a
   % function of range bin.
   pe.var = var(pe.trace2(:,slab),[],2);
   pe.var = pe.var ./ mean(pe.var(1800:pe.bins)); %Normalized to one at high bins
   
   % This variance profile will be too susceptible to the amplitude of the
   % trace, so we compute a normalization envelope as the maximum absolute
   % value encountered as a function of bin for the entire slab under
   % consideration.  
   pe.maxabs = max(abs(pe.trace2(:,slab)),[],2);
   pe.maxabs = pe.maxabs ./ mean(pe.maxabs(1800:pe.bins)); %Normalize to one at high bins
   
   % The variance profile would also be susceptible to slight jitter or
   % variability in the location of features with strong signal gradients.
   % To reduce this we compute another normaization envelope but this time
   % using the absolute value of the max gradient instead. 
   pe.maxdiff = max(abs(diff2(pe.trace2(:,slab))),[],2);
   pe.maxdiff = pe.maxdiff ./ mean(pe.maxdiff(1800:pe.bins)); %Normalized to one at high bins
   
   % We combine our two envelopes into one product.
   pe.env = (pe.maxabs .* pe.maxdiff);%These are all still normalized to one.

   %These envelopes are noisy, so we smooth them with a box-car sliding
   %window filter.  The matlab function "filter" is computationally
   %efficient.  It does this :
   % Y = filter(W,1,X) = w(1)*x(n) + w(2)*x(n-1) + ... + w(nb+1)*x(n-nb)
   % where W = [w1, w2, ... wn] is of length n and X can be of any length.
   windowSize = 20;
   pe.env = filter(ones(1,windowSize)/windowSize,1,pe.env); pe.env = filter(ones(1,windowSize)/windowSize,1,pe.env);
   pe.var = filter(ones(1,windowSize)/windowSize,1,pe.var); pe.var = filter(ones(1,windowSize)/windowSize,1,pe.var);

   %Divide the variance profile by the normalization envelope.  This mainly
   %reduces the magnitude of near range while normalizing far range to
   %approach "1".
   pe.relvar = pe.var ./ pe.env; %These are all still normalized to one.

   % The "backsmooth" function below is mine. It is coded at the end of this file. 
   % It is simply a box-car filter with a window-size that increases as a function of bin.  
   % This is done to smooth out aliases and ringing in the far-rnage data
   % without messing with the near-range data much.
   pe.relvar(start:end) = backsmooth(pe.relvar(start:end),10);

   % Compute the location of the bed boundary as the first point that the 
   % relative variance exceeds a threshold of 0.5.  This is of course
   % customizable.
   pe.bed(p) = find(pe.relvar(start:pe.bins)>.5,1,'first')+start;
   
   % The rest of the code is just for plotting the results in Matlab and saving to
   % file.  Skip to the end and look at backsmooth.
   if exist('bed_line','var')
      delete(bed_line(1)); delete(bed_line(3));
   end
   figure(10);
   ax3(1) = subplot(2,1,1);
   plt = plot(pe.us*[start:pe.bins], pe.trace(start:pe.bins,slab), '-');
   plt = recolor(plt, [slab]);
   hold('on');plot(pe.us*[start:pe.bins], pe.no_bed(start:pe.bins), 'k'); hold('off');
   %    bed_text = text(19,.5,sprintf('Bed boundary from t-zero: %3.3g us',(pe.bed(p))*pe.us),'fontsize',16,'color','red');
   ylim([-1,1])
   bed_line(1) = line(pe.us*[pe.bed(p),pe.bed(p)],ylim,'color','red');
   title(['Traces from file: ' fname], 'interpreter','none');
   ylabel('amplitude')

   ax3(2) = subplot(2,1,2);
   plot(pe.us*[start:pe.bins], pe.relvar(start:pe.bins), 'k.');
   ylim([0,1.5])
   bed_line(3) = line(pe.us*[pe.bed(p),pe.bed(p)],ylim,'color','red');
   %    title('renormalized variability')
   title([sprintf('Bed boundary from t_o=%3.3g us',(pe.bed(p))*pe.us)],'fontsize',14,'color','red')

   xlabel('bin time (us)')
   ylabel('variability')
   linkaxes(ax3,'x');
   figure(11);

   plot([1:pe.profs],(pe.bed-start)*pe.us, '-or');
   title(['Bed depths computed for file: ' fname], 'interpreter','none');
   xlim([0,pe.profs]);
   %    ylim(pe.us*([start,pe.bins]-start));
   xlabel('profile number')
   ylabel('bed depth (us from wall)')
       pause(.1)
end

figure(10);
print('-dpng', [pname, filesep,fname,'.traces.png']);
figure(11);ylim('auto');yl = ylim; ylim([0,yl(2)])
print('-dpng', [pname, filesep,fname,'.bed_depth.png']);



function arts = remove_artifacts(pe);
% This function generates a weighting vector "arts" of length 1 x bins.  
% The weights are selected to reduce the impact of measurement artifacts
% including the transducer ringing, the second tank reflection, and the
% gradual decrease in signal amplitude as a function of bin.

%Predefine arts to a vector of zeros with length pe.bins.
arts = zeros([1,pe.bins]);

% 'ring1' is the position of the transducer ringing artifact.  If the bin
% resolution is changed, or a different transducer is used, this will need
% to adjusted.  It would have been better to reference the feature in terms
% of time and convert it to bins by dividing by pe.us.
ring1 = [960:1030];

% Constructing a normalized envelope from the mean of the measured profiles
% in the "ring1" range.  Then divide it by the maximum signal observed over
% the range ring1 over all traces.  The Matlab function "mean" acts on a
% vector or matrix, taking the mean along the specified dimension.  In this
% case, I take the mean along the "prof" dimension so that the resulting
% mean vector will have length equal to "ring1".  The matlab function "max"
% is similar in that it acts along only one dimension at a time.  To get
% the max over the range ring1 and all profs, it is necessary to call max
% twice.
arts(ring1) = mean(abs(pe.trace2(ring1,:)),2)./max(max(abs(pe.trace2(ring1,:))));

%This is the location of the second echo from the tank wall. 
tank2 = [1290:1360];
arts(tank2) = mean(abs(pe.trace2(tank2,:)),2)./max(max(abs(pe.trace2(tank2,:))));

% arts = mean(pe.trace2,2);
% The matlab function "find" used below simply returns the index in the
% array of the first value satisfying the condition "mean(pe.trace2)>0".  I
% am using this to find the first non-blanked bin.
start = find(mean(pe.trace2,2)>0,1,'first');
bins = length(arts(start:end));

% Create a vector of length bins containing linearly decreasing numbers from 1 to 0.5.  This
% vector will be used to reduce the amplitude of near bins more than far
% bins.  
w = (linspace(1,.5,bins)).^2; 
% combine the weighting vector containing the artifact profiles with w.
arts(start:end) = arts(start:end) + w;
% Finally, normalize so that the maximum value is 1. 
arts = arts./max(arts);
arts = arts';

function trace = backsmooth(trace,span);
% This applies a box-car filter with initial width of 1 bin and a final width of "span". 
full = size(trace,1);
for i = 1:full;
   frac = i/full;
   back = floor(span*frac);
   if back > 0
      trace(i) = mean(trace((i-back):i));
   end
end