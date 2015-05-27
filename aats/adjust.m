function [xn]=adjust(xn,nrad);
%function adjust(f,n_coarse_rad_bin);
%King's adjust subroutine used to adjust a matrix if f(i) values still negative
%after gamma has reached the maximum range

idx = find(xn>0);
f(idx)=log10(xn(idx));

exitnradloop=0;
looprad = 1;

for i = 1:nrad
   
   looprad=1; 

   while looprad==1
      
      if xn(i)<=0
         if i==1
            for j=2:nrad
               if xn(j)>0
                  x1 = j;
                  y1 = f(j);
                  jp1 = j+1;
                  break
               end
            end
            
            for j = jp1:nrad
               if xn(j)>0
                  x2 = j;
                  y2 = f(j);
                  break
               end
            end
            
            x2m1 = x2 - 1;
            for j = 1:x2m1
               f(x2-j) = (y1-y2)/(x2-x1)*j + y2
               xn(x2-j) = 10.^f(x2-j);
            end
            break  %while looprad loop
          
         elseif i~=1
            
          if i==nrad
            looprad=0;
            exitnradloop=1;
          elseif i~=nrad
            ip1 = i + 1;
            exitnradloop=1;
            for j = ip1:nrad
               if(xn(j)>0)
                  jm1 = j - 1;
          			for k = i:jm1
            			f(k) = ((f(j) - f(i-1))*k + j*f(i-1) - (i-1)*f(j))/(j-i+1);
            			xn(k) = 10.^f(k);
         			end
                  exitnradloop=0;
						break
               end
            end   
          end
            
          if exitnradloop==1
			  for j = i:nrad
            f(j) = (f(i-1) - f(i-2))*j + (i-1)*f(i-2) - (i-2)*f(i-1);
            xn(j) = 10.^f(j);
           end
           break
          end
          
        end %if i==1 branch
        
     elseif xn(i)>0
        looprad=0;
     end  %if xn(i)<=0 branch
      
   end	%looprad while loop   
   
   if exitnradloop==1
      break
   end
   
end   %outermost loop over nrad
   
