function mpl_wavelet_pbl(filename);

if ~exist('filename', 'var')
   [fname, pname] = uigetfile('C:\case_studies\Aerosol_IOP\sgpmplnor1campC1.c1\cdf\*.*');
   filename = [pname, fname];
end

nc = ancload(filename);
range = nc.vars.height.data;
% r.bg = find(range>=40 & range<=55);
% backscatter = nc.vars.detector_counts.data - ones(size(range))*mean(nc.vars.detector_counts.data(r.bg,:));
% backscatter = backscatter .* (range .^2 * ones(size(nc.time)));
backscatter = nc.vars.backscatter.data;


figure(1); clf;
imagesc(nc.time,range, backscatter); colormap('jet');
set(gca,'ydir','norm');
caxis([0 .5]); colorbar
datetick('x',13, 'keeplimits', 'keepticks');
ylim([0 10]);
%%



%r2CorrectCut=backscatter; %Again, this comes from modifying the code for MPL

zmax = 70; % Index of how high you want to look for the PBL height, clouds, etc.

    cloudflagbot = -0*ones(1024, size(backscatter, 2));     % Initialize the cloud fla
    cloudflagtop = -0*ones(1024, size(backscatter, 2));     % Initialize the cloud fla
        
%%
	for imin=size(backscatter, 2):-1:1                          % Loop over the profiles in this day
		%r2smoothed=sgolayfilt(backscatter(:,imin),3,5);     % Smooth the data
				r2smoothed=backscatter(:,imin);
		c1 = cwt(r2smoothed(1:zmax), 5:12, 'haar'); % Do a cwt  - - Note that you can change the values "5:10" to make it more/less sensitve
		c4mean = mean(c1); % Take the average of them to eliminate noise
		
% 		figure(2); clf;
% 		plot(c4mean(1:zmax), range(1:zmax), 'b');
% 		hold on
% 		plot(backscatter(1:zmax), range(1:zmax), 'w');
        

% This section finds the cloud bottom      
% 		min_index=[];
% 		i=20;		% start at 20th index
%             while i < length(c4mean)-21,
% 				if ((c4mean(i) < c4mean(i-1))&(c4mean(i) < c4mean(i-15)))    % Check to see if this pt is less than the prev 15 pts
% 				   if ((c4mean(i) < c4mean(i+1))&(c4mean(i) < c4mean(i+15)))	% Check to see if this pt is less than the next 15 pts
%                       if (c4mean(i) < -0.005)                      % threshold
%                             min_index = [min_index i];                % Update the index array
%                         end    
%                    end
% 				end
% 				i = i + 1;
%             end
%             	
%             [C, I]=min(min_index);
%          cloudflagbot(min_index(I), imin)=1;            
       

% This section finds the cloud top - not a lot of finnesse here
        max_index=[];
		i=4;		% start at 5th index
            while i < length(c4mean)-5,
				if ((c4mean(i) > c4mean(i-1))&(c4mean(i) > c4mean(i-3)))    % Check to see if this pt is more than the prev 2 pts
				   if ((c4mean(i) > c4mean(i+1))&(c4mean(i) > c4mean(i+3)))	% Check to see if this pt is more than the next 2 pts
                      if (c4mean(i) > 0.01)                      % threshold
                            max_index = [max_index i];                % Update the index array
                        end    
                   end
				end
				i = i + 1;
            end
		
            [C, I]=min(max_index);
         cloudflagtop(max_index(I), imin)=-1;
		
%         ylims = get(gca, 'xlim');
% 		ylimits = ylims(1):ylims(2)/10:ylims(2); 
%         
%         for i=1:length(max_index)
%             line(ylimits,range(max_index(i))*ones(length(ylimits)), 'color', 'r');
%         end
% 		           
% 		grid;       hold off;      % xlim([0 1024]);
% 		
% 		legend('Cmean', 'lidar profile')
%         xlabel('index')
%         ylabel('P(z)*z^2')
%         title(['Cloud Detector Results for  ', datestr(nc.time(imin))]);
        imin
        
% pause

end



cloudflag = cloudflagbot + cloudflagtop; % Top = -1, Bottom = +1;
figure(12); clf;
imagesc(nc.time, range(1:zmax), cloudflag(1:zmax));
A=[[1, 0, 0];[1,1,1]; [0, 0, 1]];
colormap(A);
title('Cloud bottoms');
ylabel('index');
set(gca, 'ydir', 'normal');
datetick('x',13);
xlim([min(nc.time), max(nc.time)]); caxis([-1 1]);
colorbar;


 % Sometimes it is nice to plot the acutal PBL height on figure 1
for i=1:size(cloudflag,2)
    dummy=range(find(cloudflag(:,i)<0));
    if isempty(dummy)
        spar(i) = -1;
    else
        spar(i) = dummy;
    end
end

figure(1);
hold on;
h = plot(nc.time, spar, 'w.', 'linewidth', 2);


