

function [R, lags] = xcorr (X, Y, maxlag, scale)
  
  if (nargin < 1 || nargin > 4)
%     usage ("[c, lags] = xcorr(x [, y] [, h] [, scale])");
  end %if

  %% assign arguments from list
  if nargin==1
    Y=[]; maxlag=[]; scale=[];
  elseif nargin==2
    maxlag=[]; scale=[];
    if ischar(Y), scale=Y; Y=[];
    elseif isscalar(Y), maxlag=Y; Y=[];
    end %if
  elseif nargin==3
    scale=[];
    if ischar(maxlag), scale=maxlag; scale=[]; end %if
    if isscalar(Y), maxlag=Y; Y=[]; end %if
  end %if

  %% assign defaults to arguments which were not passed in
  if isvector(X) 
    if isempty(Y), Y=X; end %if
    N = max(length(X),length(Y));
  else
    N = rows(X);
  end %if
  if isempty(maxlag), maxlag=N-1; end %if
  if isempty(scale), scale='none'; end %if

  %% check argument values
  if isscalar(X) || ischar(X) || isempty(X)
    error('xcorr: X must be a vector or matrix'); 
  end %if
  if isscalar(Y) || ischar(Y) || (~isempty(Y) && ~isvector(Y))
    error('xcorr: Y must be a vector');
  end %if
  if ~isvector(X) && ~isempty(Y)
    error('xcorr: X must be a vector if Y is specified');
  end %if
  if ~isscalar(maxlag) && ~isempty(maxlag) 
    error('xcorr: maxlag must be a scalar'); 
  end %if
  if maxlag>N-1, 
    error('xcorr: maxlag must be less than length(X)'); 
  end %if
  if isvector(X) && isvector(Y) && length(X) ~= length(Y) && ...
	~strcmp(scale,'none')
    error('xcorr: scale must be "none" if length(X) ~= length(Y)')
  end %if
  if size(X,1)<size(X,2)
     X = X';
  end
  if all(size(X)==size(Y'))
     Y = Y';
  end
  P = size(X,2);
  M = 2^nextpow2(N + maxlag);
  if ~isvector(X) 
    %% For matrix X, compute cross-correlation of all columns
    R = zeros(2*maxlag+1,P^2);

    %% Precompute the padded and transformed `X' vectors
    pre = fft (postpad (prepad (X, N+maxlag), M) ); 
    post = conj (fft (postpad (X, M)));

    %% For diagonal (i==j)
    cor = ifft (post .* pre);
    R(:, 1:P+1:P^2) = conj (cor (1:2*maxlag+1,:));

    %% For remaining i,j generate xcorr(i,j) and by symmetry xcorr(j,i).
    for i=1:P-1
      j = i+1:P;
      cor = ifft (post(:,i*ones(length(j),1)) .* pre(:,j));
      R(:,(i-1)*P+j) = conj (cor (1:2*maxlag+1, :));
      R(:,(j-1)*P+i) = flipud (cor (1:2*maxlag+1, :));
    end; 
  elseif isempty(Y)
    %% compute autocorrelation of a single vector
    post = fft (postpad(X,M));
    cor = ifft (conj(post(:)) .* post(:));
    R = [ conj(cor(maxlag+1:-1:2)) ; cor(1:maxlag+1) ];
  else 
    %% compute cross-correlation of X and Y
 R = zeros (2*maxlag + 1, 1);
 R(maxlag+1) = X'*Y;
 for k=1:maxlag
 	R(maxlag+1-k) = X(k+1:N)' * Y(1:N-k);
 	R(maxlag+1+k) = X(1:N-k)' * Y(k+1:N);
 end %for
%     post = fft (postpad(X,M));
%     pre = fft (postpad(prepad(Y,N+maxlag),M));
%     cor = conj (ifft (conj(post(:)) .* pre(:)));
%     R = cor(1:2*maxlag+1);
  end %if

  %% if inputs are real, outputs should be real, so ignore the
  %% insignificant complex portion left over from the FFT
  if isreal(X) && (isempty(Y) || isreal(Y))
    R=real(R); 
  end %if

  %% correct for bias
  if strcmp(scale, 'biased')
    R = R ./ N;
  elseif strcmp(scale, 'unbiased')
    R = R ./ ( [ N-maxlag:N-1, N, N-1:-1:N-maxlag ]' * ones(1,columns(R)) );
  elseif strcmp(scale, 'coeff')
    R = R ./ ( ones(rows(R),1) * R(maxlag+1, :) );
  elseif ~strcmp(scale, 'none')
    error('xcorr: scale must be "biased", "unbiased", "coeff" or "none"');
  end
    
  %% correct the shape so that it is the same as the input vector
  if isvector(X) && P > 1
    R = R'; 
  end
  
  %% return the lag indices if desired
  if nargout == 2
    lags = -maxlag:maxlag;
  end

return

%%------------ Use brute force to compute the correlation -------
%%if ~isvector(X) 
%%  %% For matrix X, compute cross-correlation of all columns
%%  R = zeros(2*maxlag+1,P^2);
%%  for i=1:P
%%    for j=i:P
%%      idx = (i-1)*P+j;
%%      R(maxlag+1,idx) = X(i)*X(j)';
%%      for k = 1:maxlag
%%  	    R(maxlag+1-k,idx) = X(k+1:N,i) * X(1:N-k,j)';
%%  	    R(maxlag+1+k,idx) = X(k:N-k,i) * X(k+1:N,j)';
%%      endfor
%%	if (i~=j), R(:,(j-1)*P+i) = conj(flipud(R(:,idx))); end %if
%%    endfor
%%  endfor
%%elseif isempty(Y)
%%  %% reshape X so that dot product comes out right
%%  X = reshape(X, 1, N);
%%    
%%  %% compute autocorrelation for 0:maxlag
%%  R = zeros (2*maxlag + 1, 1);
%%  for k=0:maxlag
%%  	R(maxlag+1+k) = X(1:N-k) * X(k+1:N)';
%%  endfor
%%
%%  %% use symmetry for -maxlag:-1
%%  R(1:maxlag) = conj(R(2*maxlag+1:-1:maxlag+2));
%%else
%%  %% reshape and pad so X and Y are the same length
%%  X = reshape(postpad(X,N), 1, N);
%%  Y = reshape(postpad(Y,N), 1, N)';
%%  
%%  %% compute cross-correlation
%%  R = zeros (2*maxlag + 1, 1);
%%  R(maxlag+1) = X*Y;
%%  for k=1:maxlag
%%  	R(maxlag+1-i) = X(k+1:N) * Y(1:N-k);
%%  	R(maxlag+1+i) = X(k:N-i) * Y(k+1:N);
%%  endfor
%%end %if
%%--------------------------------------------------------------
