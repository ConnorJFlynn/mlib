function hh = xerrorbar(axestype,xmin, xmax, ymin, ymax, x, y, l,u,symbol)
%function hh = xerrorbar(axestype,xmin, xmax, ymin, ymax, x, y, l,u,symbol)
%   ERRORBAR(X,Y,L,U) plots the graph of vector X vs. vector Y with
%   error bars specified by the vectors L and U.  L and U contain the
%   lower and upper error ranges for each point in Y.  Each error bar
%   is L(i) + U(i) long and is drawn a distance of U(i) above and L(i)
%   below the points in (X,Y).  The vectors X,Y,L and U must all be
%   the same length.  If X,Y,L and U are matrices then each column
%   produces a separate line.
%
%   ERRORBAR(X,Y,E) or ERRORBAR(Y,E) plots Y with error bars [Y-E Y+E].
%   ERRORBAR(...,'LineSpec') uses the color and linestyle specified by
%   the string 'LineSpec'.  See PLOT for possibilities.
%
%   H = ERRORBAR(...) returns a vector of line handles.
%
%   For example,
%      x = 1:10;
%      y = sin(x);
%      e = std(y)*ones(size(x));
%      errorbar(x,y,e)
%   draws symmetric error bars of unit standard deviation.

%   L. Shure 5-17-88, 10-1-91 B.A. Jones 4-5-93
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2013/12/11 00:48:36 $

if min(size(x))==1,
  npt = length(x);
  x = x(:);
  y = y(:);
    if nargin > 6,
        if ~isstr(l),  
            l = l(:);
        end
        if nargin > 7
            if ~isstr(u)
                u = u(:);
            end
        end
    end
else
  [npt,n] = size(x);
end

if nargin == 8
    if ~isstr(l)  
        u = l;
        symbol = '-';
    else
        symbol = l;
        l = y;
        u = y;
        y = x;
        [m,n] = size(y);
        x(:) = (1:npt)'*ones(1,n);;
    end
end

if nargin == 9
    if isstr(u),    
        symbol = u;
        u = l;
    else
        symbol = '-';
    end
end


if nargin == 7
    l = y;
    u = y;
    y = x;
    [m,n] = size(y);
    x(:) = (1:npt)'*ones(1,n);;
    symbol = '-';
end

u = abs(u);
l = abs(l);
    
if isstr(x) | isstr(y) | isstr(u) | isstr(l)
    error('Arguments must be numeric.')
end

if ~isequal(size(x),size(y)) | ~isequal(size(x),size(l)) | ~isequal(size(x),size(u)),
  error('The sizes of X, Y, L and U must be the same.');
end

switch axestype
	case {'semilogx','linlin'}
      tee = .008*(ymax-ymin);  % make tee .008 y-distance for error bars
      ybot = y - tee;
      ytop = y + tee;
   case {'semilogy','loglog'}   
      tee = 0.60*log(ymax/ymin)/100;  % make tee .0075 log(y-distance) for error bars
      ybot = y*10^-tee;
      ytop = y*10^tee;
end

xr = x + u;
xl = x - l;
m = size(x,1);
for i = 1:m,
   if(xl(i)<xmin) xl(i)=xmin; end	%set lower limit to xmin, if necessary
   if(xr(i)>xmax) xr(i)=xmax; end	%set upper limit to xmax, if necessary
end
n = size(x,2);

% Plot graph and bars
hold_state = ishold;
cax = newplot;
next = lower(get(cax,'NextPlot'));

% build up nan-separated vector for bars
yb = zeros(npt*9,n);
yb(1:9:end,:) = y;
yb(2:9:end,:) = y;
yb(3:9:end,:) = NaN;
yb(4:9:end,:) = ybot;
yb(5:9:end,:) = ytop;
yb(6:9:end,:) = NaN;
yb(7:9:end,:) = ybot;
yb(8:9:end,:) = ytop;
yb(9:9:end,:) = NaN;

xb = zeros(npt*9,n);
xb(1:9:end,:) = xr;
xb(2:9:end,:) = xl;
xb(3:9:end,:) = NaN;
xb(4:9:end,:) = xr;
xb(5:9:end,:) = xr;
xb(6:9:end,:) = NaN;
xb(7:9:end,:) = xl;
xb(8:9:end,:) = xl;
xb(9:9:end,:) = NaN;

[ls,col,mark,msg] = colstyle(symbol); if ~isempty(msg), error(msg); end
symbol = [ls mark col]; % Use marker only on data part
esymbol = ['-' col]; % Make sure bars are solid

h = plot(xb,yb,esymbol); hold on
h = [h;plot(x,y,symbol)]; 

if ~hold_state, hold off; end

if nargout>0, hh = h; end
