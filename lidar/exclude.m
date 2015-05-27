function [select] = exclude(range, A);
%function [select] = exclude(range, A);
%This function was written to cycle through a matrix of MPL overlap profiles, plotting each 
%profile and permitting the exclusion on a case by case basis, generating a subset matrix.
%if no range is supplied, the length of the matrix is taken as the range.

if nargin == 1
  TempA = range;
  [bins,profs] = size(TempA);
  range = [1:bins];
else
  TempA = A;
  [bins,profs] = size(TempA);
end;
figure;
zoom;
i = 1;
good = [1:profs];
done = 0;
  plot(range, real(log(TempA(:,[good]))),'y', range,real(log(TempA(:,good(i)))),'r', range, real(log(mean(TempA(:,good)')))','g');
  TitleString = ['Selected profile ', num2str(i), ' of ' ,num2str(length(good)) ,'.  Initially ',num2str(profs),' profiles.'];
  Title(TitleString);
while ~done,
  keep = input('Keep the profile? <Y>, N, or X to exit. ', 's');
  if (keep == 'n')|(keep == 'N') 
    good(i) = [];
  elseif (keep == 'x')|(keep == 'X')
    done = 1;
  else 
    i = i + 1;
  end;
  if i > length(good) 
    i = 1;
  end;
  V = axis;
  plot(range, real(log(TempA(:,[good]))),'y', range,real(log(TempA(:,good(i)))),'r', range, real(log(mean(TempA(:,good)')))','g');
  axis(V);
  TitleString = ['Selected profile ', num2str(i), ' of ' ,num2str(length(good)) ,'.  Initially ',num2str(profs),' profiles.'];
  Title(TitleString);
end;
plot(range, log(TempA(:,good)),'y');
figure
plot(range,log(mean(TempA(:,good)'))','c');
Title('Mean of Selected Profiles; mean(Profiles(:,good)'')'' ');
select = good;


