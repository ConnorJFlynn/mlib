clear; close all;
nc = netcdf('nrb_cove_62_20040613.cdf', 'nowrite');              % Open NetCDF file.
description = nc.description(:)                      % Global attribute.
variables = var(nc);                                 % Get variable data.
for i = 1:length(variables)
%   disp([name(variables{i}) ' =']), disp(' ')
%a = (variables{i}(:))
%name(variables{i}) = (variables{i}(:));


tempdata{i}.name = name(variables{i});
tempdata{i}.data = variables{i}(:);

end
nc = close(nc); 



% This mess is the leftovers from converting the code to work for the MPL
backscatter = tempdata{1}.data;
n1 = tempdata{6}.data;
hour = tempdata{7}.data;
minute=tempdata{8}.data;
second=tempdata{9}.data;
year=tempdata{3}.data;
month=tempdata{4}.data;
day=tempdata{5}.data;
n2 = tempdata{10}.data;
zkm =  tempdata{19}.data;
n1 = num2str(n1);
n2 = num2str(n2);



n = datenum(year,month,day,hour, minute, second); %Matlab date

figure(1); clf;
imagesc(n, zkm, backscatter')
set(gca,'ydir','norm');
caxis([0 0.3]);
datetick('x',13, 'keeplimits', 'keepticks');
ylim([0 10]);



r2CorrectCut=backscatter'; %Again, this comes from modifying the code for MPL

zmax = 70; % Index of how high you want to look for the PBL height, clouds, etc.

    cloudflagbot = -0*ones(1024, size(r2CorrectCut, 2));     % Initialize the cloud fla
    cloudflagtop = -0*ones(1024, size(r2CorrectCut, 2));     % Initialize the cloud fla
        
	for imin=1:size(r2CorrectCut, 2)                          % Loop over the profiles in this day
		%r2smoothed=sgolayfilt(r2CorrectCut(:,imin),3,5);     % Smooth the data
				r2smoothed=r2CorrectCut(:,imin);
		c1 = cwt(r2smoothed(1:zmax), 5:10, 'haar'); % Do a cwt  - - Note that you can change the values "5:10" to make it more/less sensitve
		c4mean = mean(c1); % Take the average of them to eliminate noise
		
		figure(2); clf;
		plot(c4mean(1:zmax), zkm(1:zmax), 'b');
		hold on
		plot(r2smoothed(1:zmax), zkm(1:zmax), 'k');
        

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
		
        ylims = get(gca, 'xlim');
		ylimits = ylims(1):ylims(2)/10:ylims(2); 
        
        for i=1:length(max_index)
            line(ylimits,zkm(max_index(i))*ones(length(ylimits)), 'color', 'r');
        end
		           
		grid;       hold off;      % xlim([0 1024]);
		
		legend('Cmean', 'lidar profile')
        xlabel('index')
        ylabel('P(z)*z^2')
        title(['Cloud Detector Results for  ', datestr(n(imin))]);
        imin;
        
% pause

end



cloudflag = cloudflagbot + cloudflagtop; % Top = -1, Bottom = +1;
figure(12); clf;
imagesc(n, zkm, cloudflag);
A=[[1, 0, 0];[1,1,1]; [0, 0, 1]];
colormap(A);
title('Cloud bottoms');
ylabel('index');
set(gca, 'ydir', 'normal');
datetick('x',13);
xlim([min(n), max(n)]); caxis([-1 1]);
colorbar;


 % Sometimes it is nice to plot the acutal PBL height on figure 1
for i=1:size(cloudflag,2)
    dummy=zkm(find(cloudflag(:,i)<0));
    if isempty(dummy)
        spar(i) = -1;
    else
        spar(i) = dummy;
    end
end

figure(1);
hold on;
h = plot(n, spar, 'w.', 'linewidth', 2);


