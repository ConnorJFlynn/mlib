function offset = offset_angle(A,B); 
% offset = offset_angle(A,B); 
% Returns mean offset angle
% offset = angle A - angle B in radians

       mean_sin_A_B = mean(sin(A).*cos(B) -cos(A) .* sin(B));
       mean_cos_A_B = mean(sin(A).*sin(B) + cos(A) .* cos(B));
       %
       if (mean_sin_A_B < 0) && (mean_cos_A_B < 0)
          offset = -acos(mean_cos_A_B);
          % Offset is in 3rd quadrant
       elseif mean_sin_A_B < 0
          offset = asin(mean_sin_A_B);
          % offset is in 4th quadrant
       elseif mean_cos_A_B < 0
          %offset is in 2nd quadrant
          offset = acos(mean_cos_A_B);
       else
          % Offset is in 1st quadrant
          offset = asin(mean_sin_A_B);
       end
       deg_offset = offset * 180/pi;
       % Is this at all different than mean(abs(A-B)) or abs(mean(A-B))?

