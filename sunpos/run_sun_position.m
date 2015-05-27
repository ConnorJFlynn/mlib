 % for NREL LT+7=UT
 % for DR LT+8=UT
 %!rm test.txt
surface_net=[-105.1436, 40.5972, 1573;... % Christman Field, CO neartest grid 0.010 deg
            -105.10, 48.31, 635;...       % Fort Peck, MT, nearest grid 0.010 deg
            -96.62, 43.73, 473;...        % Sioux Falls, SD nearest grid is at 0.013 deg
            -77.93, 40.72, 376;...        % Penn State, Pennsylvania nearest grid is 0.012 deg
            -88.37, 40.05, 213;...        % Bondville, IL nearest grid is 0.012 deg
            -105.24, 40.13, 1689;...      % Boulder, CO nearest grid is 0.012 deg
            -116.02, 36.63, 1007;...      % Desert Rock, NV, nearest gid is 0.012 deg
            -89.87, 34.25, 98;...         % Goodwin Creek, MS
            -105.18, 39.74, 1829;...      % NREL Golden CO nearest grid 0.012 deg
            -81.8021, 27.3216, 30;...     % DeSoto Florida nearest grid 0.012 deg
            -119.63, 36.31, 73];          % Hanford, CA

  location.latitude =  surface_net(7,2); % here change teh row, e.g. 11 is for Hanford 
  location.longitude = surface_net(7,1);
  location.altitude =  surface_net(7,3);
  
  %************************************
  % Set the UTC offset for the location
  %************************************
  
%  t = timeZones();
%  time.UTC = t.zone('Denver');

  time.UTC = -8;
  fcsttime.UTC = double(time.UTC);
%  fcsttime.UTC = -6;

  for yr = 2010 : 2010
    for mt = 9 : 9 
      for dy = 1 : 30 
        for hr = 0 : 23
          for mn = 10 : 1 :10 
	    for sc = 0 : 0
      
              fcsttime.year = double(yr);
              fcsttime.month = double(mt);
              fcsttime.day = double(dy);
              fcsttime.hour = double(hr);
              fcsttime.min = double(mn) ;
              fcsttime.sec = double(sc);
			       
              %**************************************
              % Calculate forecast Solar Zenith using time 
              %and running solpos
              %**************************************	    
                 
              fcstsunangle = sun_position(fcsttime, location);
	     
	      fcstsunangle.zenith
	      fcstsunangle.azimuth; 
	      fcstsunangle.radius;  %Remove the ; to write these parameters
	    
		table=[fcsttime.month, fcsttime.day, fcsttime.hour, fcsttime.min,...
                     fcstsunangle.zenith, fcstsunangle.azimuth, fcstsunangle.radius] 
             save ('time_sza_ssa_ghi_radius.txt', 'table', '-ascii', '-append') 
	    end
	  end
       end
     end
   end
 end			       
