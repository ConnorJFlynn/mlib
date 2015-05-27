function goods = IQ(Io,cut);
if ~exist('cut','var')
   cut = .25;
end
goods = false(size(Io));
nonNaN = isfinite(Io);
goods(nonNaN) = IQ_noNaN(Io(nonNaN),cut);

function goods = IQ_noNaN(Io,cut);
% goods = IQ(Io,cut);
% Sorts supplied sample,discarding top and bottom cut.  Cut may be expressed
% as a fraction (<= 50%) or a number of points <= half length(Io)
% By default cut is 0.25, so this is an interquartile filter unless 
% some other cut is specified.
% returns a logical indices indicating points "making the cut".
goods = false(size(Io));
if (cut > .5)&&(cut<1)||(cut>length(Io)/2)
   disp('Cut must be a fraction <= 50% or a number >=1 and less than half length(Io)')
else
   if cut <= .5
      cut = floor(length(Io).*cut);
   end
   [Is,ind] = sort(Io);
   goods(ind((cut+1):(end-cut-1))) = true;
end

% if Q>0 &&((div-1)*Q)<length(Io)
%          goods((ind(Q:((div-1)*Q)))) = true;
%       else
%          goods(2:end-1) = true;
%       end
%    
% 
% 
% 
%    if length(goods)>2
%       Q = floor(length(Io).*cut);
%       [Is,ind] = sort(Io);
%       if Q>0 &&((div-1)*Q)<length(Io)
%          goods((ind(Q:((div-1)*Q)))) = true;
%       else
%          goods(2:end-1) = true;
%       end
%    end
% end
% figure; plot(t,Io,'r.',t(goods),Io(goods),'go'); datetick('keeplimits')