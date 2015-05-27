function padded = zero_pad_fft(x,y,N)
% Usage: padded = zero_pad_fft(x,y,N);
% spec is a structure with fields x and y
% x is vector, y is vector or matrix spectrum
% A buffer of zeros of size N*size(y) is added to the front and back for
% the resuting igram.
% spec = out_spec.y(30,good_Bi);
if size(x,2)==1 && size(x,1)==size(y,1)
   x = x';
   y = y';
end

[rows,cols] = size(y);
dx = x(2)-x(1);
newx = [];
for n = 0:2*N;
newx = [newx, x+n.*dx./(2*N+1)];
end
newx = sort(newx);
padded.x = newx;
padded.y = zeros([rows,length(newx)]);
if ishandle(1)
   close(1);
end
for r = 1:rows
   igm = fftshift(ifft(y(r,:)));
   zgm = [zeros([1,N.*size(igm,2)]),igm,zeros([1,N.*size(igm,2)])];
   padded.y(r,:) = fft(ifftshift(zgm,2));
%    figure(1);
%    subplot(2,1,2); plot(padded.x,padded.y(r,:),'.k-',x,y(r,:),'-bo');
%    subplot(2,1,1); plot([1:length(igm)],igm,'r-');
end
return

