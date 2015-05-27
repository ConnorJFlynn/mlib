function [ResMat,NewMat]=binning(Data,BinSize,Start,End);
%--------------------------------------------------------------------
% binning function     Binning a timeseries, with eqal size,
%                    equal weight bins.
%                    Calculate the mean/median/std/skewness
%                    of the observations in each bin.
%                    The bins are equally spaced,
% Input  : - Matrix, in which the first column is the
%            time, the second column is the observation, and
%            optional third column is the value error.
%          - binning interval, in units of the "time" column.
%          - First bin start Time (default is start point).
%          - last bin end Time (default is end point).
% Output : - Matrix with the following columns:
%            [Bin_Center,
%             <Y>,
%             StD(Y)/sqrt(N),
%             <X>,
%             Weighted-<Y>,
%             Formal-Error<Y>,
%             N]
%            In case that no errors are given, columns 5 and 6
%            will be zeros.
%          - The matrix as above, but the NaNs are elimated.
% Tested : Matlab 5.0
%     By : Eran O. Ofek       Febuary 1999 / Last Updated Feb 2000
%    URL : http://wise-obs.tau.ac.il/~eran/matlab.html
%--------------------------------------------------------------------
warning off MATLAB:divideByZero %added BS 5/5/2004
Xcol = 1;
Ycol = 2;
Ecol = 3;

if nargin<2,
   error('at least 2 args');
end
if nargin==2,
   Start = min(Data(:,Xcol));
   End   = max(Data(:,Xcol));
end
if nargin==3,
   End   = max(Data(:,Xcol));
end

if (length(Data(1,:))==2),
   % without errors
   Err = 'n';
else
   Err = 'y';
end

Ntot = length(Data(:,Xcol));

Nbin = (End-Start)./BinSize;

% Bin_Center; <X>; <Y>; <Y^2>; N
BinMat = zeros(Nbin,7);

% initialize bin center
BinMat(:,1) = [(Start+0.5.*BinSize):BinSize:(End-0.5.*BinSize)]';

ResMat = BinMat;


for I=1:1:Ntot,
   BinInd = ceil((Data(I,Xcol)-Start)./BinSize);
   if (BinInd>0 & BinInd<=Nbin),
      BinMat(BinInd,2) = BinMat(BinInd,2) + Data(I,Xcol);
      BinMat(BinInd,3) = BinMat(BinInd,3) + Data(I,Ycol);
      BinMat(BinInd,4) = BinMat(BinInd,4) + Data(I,Ycol).^2;
      BinMat(BinInd,5) = BinMat(BinInd,5) + 1;
      % for w-mean and formal error
      if (Err=='y'),
         BinMat(BinInd,6) = BinMat(BinInd,6) + Data(I,Ycol)./(Data(I,Ecol).^2);
         BinMat(BinInd,7) = BinMat(BinInd,7) + 1./(Data(I,Ecol).^2);
      end
      % for skewness
      %BinMat(BinInd,8) = BinMat(BinInd,4) + Data(I,Ycol).^3;
   end
end

% calculate mean and StD
% Bin_Center; <Y>; StD(Y)/sqrt(N); <X>; W-<Y>; Formal-Error(Y); N; Skewness(Y)
ResMat(:,2) = BinMat(:,3)./BinMat(:,5);
ResMat(:,3) = sqrt((BinMat(:,4)./BinMat(:,5) - ResMat(:,2).^2)./BinMat(:,5));
ResMat(:,4) = BinMat(:,2)./BinMat(:,5);
if (Err=='y'),
   % W-mean
   ResMat(:,5) = BinMat(:,6)./BinMat(:,7);
   % formal error
   ResMat(:,6) = sqrt(1./BinMat(:,7));
end
% Number of observations per bin
ResMat(:,7) = BinMat(:,5);
% The skewness
%ResMat(:,8) = (BinMat(:,8) - 3.*BinMat(:,4).*ResMat(:,2)-3.*BinMat(:,3).*ResMat(:,2).^2 - ResMat(:,2).^3)./(ResMat(:,7).*ResMat(:,3).^3);

if (nargout>1),
   % eliminate NaNs
   Innan  = find(isnan(ResMat(:,2))==0);
   NewMat = ResMat(Innan,:);
end