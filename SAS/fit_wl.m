function [pix,nms,P,S]= fit_wl(nm,spec,nm_in,N); 
% [pix, nms, P,S]= fit_wl(nm,spec,nm_in);
% Supplied with a measured spectra and list of peak locations allows the
% user to cycle through the supplied list, selecting those that are
% represented in the data for use in generating an Nth order polynomial
% fit.
if ~exist('N','var');
   N = 4;
end
ind = size(nm_in,1);
done = false;
figure(99);
[tmp,A] = unique(nm_in(:,1));
nm_in = nm_in(A,:);
nm_in((nm_in(:,1)<min(nm))|(nm_in(:,1)>max(nm)),:)= [];
ii = 1;
nms = [];
pix = [];
   plot(nm,spec,'k-');
   yl = ylim;
   line([nm_in(:,1)';nm_in(:,1)'],[yl'*ones([1,length(nm_in(:,1)')])],'color','red');
   line([nm_in(ii,1);nm_in(ii,1)],yl','color','blue');
   title(['Zoom in to select the wavelength range over which to select reference lines. Hit OK when done.']);
   ok = menu('Click OK when done zooming.','OK');
   xl = xlim;
   nm_in((nm_in(:,1)<xl(1))|(nm_in(:,1)>xl(2)),:)= [];
 
while ~done
   sb(1) = subplot(4,1,1);
   plot(nm,spec,'k-');
   yl = ylim;
   line([nm_in(:,1)';nm_in(:,1)'],[yl'*ones([1,length(nm_in(:,1)')])],'color','red');
   line([nm_in(ii,1);nm_in(ii,1)],yl','color','blue');
   title(['Reference wavelength: ',sprintf('%3.2f nm',nm_in(ii,1)), '  relative intensity ',num2str(nm_in(ii,2))]);
   nm_ = nm>=((nm_in(ii,1)-10))&nm<=((nm_in(ii,1)+10));
   nm_in_ = nm_in(:,1)>=((nm_in(ii,1)-10))&nm_in(:,1)<=((nm_in(ii,1)+10));
   sb(2) = subplot(4,1,2);
   if sum(nm_)>3
      plot(nm(nm_),spec(nm_),'k-');
      line([nm_in(nm_in_,1)';nm_in(nm_in_,1)'],[ylim'*ones([1,length(nm_in(nm_in_,1)')])],'color','red');
      line([nm_in(ii,1);nm_in(ii,1)],ylim','color','blue')
      xlim([nm_in(ii,1)-10,nm_in(ii,1)+10]);
      title(['Select peak with left mouse button, exit with right mouse button']);
      ylim('auto')
           ok = false;
           while ~ok
     [x,y,button] = ginput(1);
     if button==1
        if exist('ln','var')&ishandle(ln)
           delete(ln);
        end
     pix_ = interp1(nm,[1:length(nm)], x, 'nearest');
     ln = line([nm(pix_);nm(pix_)],ylim','color','black')
     else
        ok = true;
     end
           end
   end

  k = menu('Use this peak?','Use it', 'Delete it','Skip it','Done!');
  if k == 1


     pix = [pix,pix_];
     nms = [nms,nm_in(ii,1)];
%      [pix,IJ] = sort(pix);
%      nms = nms(IJ);
     if length(nms)>N+1
        [P,S] = polyfit(pix,nms,N);
        sb(3) = subplot(4,1,3);
        plot(nm,polyval(P,[1:length(nm)],S), '-b');
        sb(4) = subplot(4,1,4);
        plot(nm,nm-polyval(P,[1:length(nm)],S), '-ro');
     end
     nm_in(ii,:) = [];
     nm_in = flipud(nm_in);
  elseif k==2
     nm_in(ii,:) = [];
  elseif k==3
       ii = ii +1;
  elseif k ==4
     done = true;
  end

  if ii > length(nm_in(:,1))
     ii = 1;
  end
  if length(nm_in(:,1))<=1
     done = true;
  end
 
end
[nms, ij] = sort(nms);
pix = pix(ij);

return