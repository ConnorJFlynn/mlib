function [PileA, PileB] = trimsift_nolog(range, InMat);
%function [pileA pileB] = trimsift_nolog(range, InMat);
%A trimmed down version of sift.
% The user zoom into a region and hits enter.
% Profiles extending above or below the Y limits are excluded from the
% selection.

if nargin == 1
   InMat = range;
   [bins,profs] = size(InMat);
   range = [1:bins];
elseif nargin == 2
   [bins,profs] = size(InMat);
end;

pile = ones([1,profs]);
PileA = find(pile>0);
PileB = find(pile<0);
done = 0;

trim = figure;
figure(trim);
plot(range, InMat(:,[PileA]),'y',  range, mean(InMat(:,PileA)')','g');
xl = xlim;
xlim([xl(1)-.1*xl(2),xl(2)+.1*xl(2)]);v = axis;
while ~done
   if ~isempty(PileA)
       figure(trim);
      plot(range, InMat(:,[PileA]),'y',  range, mean(InMat(:,PileA)')','g');
      if exist('v', 'var')
         axis(v);
      end
      title('Zoom in as desired.  Hit enter when ready.')
      zoom on;
      pause
      keep = input('Hit enter to trim profiles extending beyond y limits, "R" to reset, and "X" to exit: ', 's');
      if isempty(keep)
         keep = 'T';
      end
      v = axis;
      lower_limit = max(find(range<=v(1)));
      upper_limit = min(find(range>=v(2)));
      if isempty(lower_limit)
         lower_limit = 1;
      end
      if isempty(upper_limit)
         upper_limit = length(range);
      end;

      %clean_mpl = clean_mpl(~any(mpl.nor(cloud_range,clean_mpl)>25));
      select_range = find(range>=v(1)&range<=(v(2)));

      pileA_overmax = any(InMat(select_range,PileA)>v(4));
      pileA_undermin = any(InMat(select_range,PileA)<v(3));

      pile(PileA(pileA_overmax))=-1;
      pile(PileA(pileA_undermin))=-1;

   else
              figure(trim);
      plot(range, InMat(:,[PileB]),'y',  range, mean(InMat(:,PileB)')','g');
      if exist('v', 'var')
         axis(v);
      end
      title('Zoom in as desired.  Hit enter when ready.')
      zoom on;
      pause
      keep = input('Hit enter to trim profiles extending beyond y limits, "R" to reset, and "X" to exit: ', 's');
      if isempty(keep)
         keep = 'T';
      end
      v = axis;
      lower_limit = max(find(range<=v(1)));
      upper_limit = min(find(range>=v(2)));
      if isempty(lower_limit)
         lower_limit = 1;
      end
      if isempty(upper_limit)
         upper_limit = length(range);
      end;
      %clean_mpl = clean_mpl(~any(mpl.nor(cloud_range,clean_mpl)>25));
      select_range = find(range>=v(1)&range<=(v(2)));
      pileB_overmax = any(InMat(select_range,PileB)>v(4));
      pileB_undermin = any(InMat(select_range,PileB)<v(3));
      pile(PileB(pileB_overmax))=1;
      pile(PileB(pileB_undermin))=1;
   end
   if upper(keep)=='T'
      PileA = find(pile>0);
      PileB = find(pile<0);
   elseif upper(keep)=='R'
      pile = ones([profs,1]);
      PileA = find(pile>0);
      PileB = find(pile<0);
      clear v;
   elseif upper(keep)=='X'
      done = 1;
   end
end;
close(trim);
