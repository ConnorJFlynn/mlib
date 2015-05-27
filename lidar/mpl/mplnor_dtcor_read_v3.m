function temp
%MPL NOR Dead time correction analysis.

warning('off','MATLAB:dispatcher:InexactMatch')
[fid,fname,pname]= getfile('*.xls','excel');
fclose(fid);
%% Read Excel spreadsheet and Plot the values.
a =xlsread([pname fname]);
%%plot([a(5:52,1)],[a(5:52,2)],
%%[a(5:52,3)],[a(5:52,4)],[a(5:52,5)],[a(5:52,6)], [a(5:52,7)],[a(5:52,8)],[a(5:52,9)],[a(5:52,10)], [a(5:52,11)],[a(5:52,12)],[a(5:52,13)],[a(5:52,14)], [a(5:52,15)],[a(5:52,16)],[a(5:52,17)],[a(5:52,18)], [a(5:52,19)],[a(5:52,20)],[a(5:52,21)],[a(5:52,22)], [a(5:52,23)],[a(5:52,24)],[a(5:52,25)],[a(5:52,26)], [a(5:52,27)],[a(5:52,28)],[a(5:52,29)],[a(5:52,30)], [a(5:52,31)],[a(5:52,32)],[a(5:52,33)],[a(5:52,34)], [a(5:52,35)],[a(5:52,36)],[a(5:52,37)],[a(5:52,38)], [a(5:52,39)],[a(5:52,40)],[a(5:52,41)],[a(5:52,42)], [a(5:52,43)],[a(5:52,44)],[a(5:52,45)],[a(5:52,46)],a(5:52,47), a(5:52,48),a(5:52,49), a(5:52,50),a(5:52,51), a(5:52,52),a(5:52,53), a(5:52,54),a(5:52,55), a(5:52,56),a(5:52,57), a(5:52,58),a(5:52,59), a(5:52,60),a(5:52,61), a(5:52,62),a(5:52,63), a(5:52,64),a(5:52,65), a(5:52,66),a(5:52,67), a(5:52,68),a(5:52,69), a(5:52,70),a(5:52,71), a(5:52,72),a(5:52,73), a(5:52,74),a(5:52,75), a(5:52,76),a(5:52,77), a(5:52,78),a(5:52,79), a(5:52,80),a(5:52,81), a(5:52,82),a(5:52,83), a(5:52,84) ,a(5:52,85), a(5:52,86)); %, a(5:52,87), a(5:52,88),a(5:52,89), a(5:52,90); % a(5:52,47), a(5:52,48)a(5:52,47), a(5:52,48)a(5:52,47), a(5:52,48)a(5:52,47), a(5:52,48)a(5:52,47), a(5:52,48)a(5:52,47), a(5:52,48)); 
%title('MPLNOR Dead-time Corrections')
%xlabel('D (kHz)')
%ylabel('DT Corr')
%%
% Compile all the values less than 10000 into a single row.
n=1;
for row=1:2:86,
    for col=5:26,
        if (a(col,row)<=10000)
            one_col(n,1)=(a(col,row));
            one_col(n,2)=(a(col,row+1));
            n= n+1;
        end;
    end;
end;
%% sort based on the first row
sort_col = sortrows(one_col,1);
plot(sort_col(:,1),sort_col(:,2));
xlabel('D (kHz) Sorted');
ylabel('DT Corr');

log_R = log10(sort_col(:,1));
min_step = 2.5* max(diff(log_R));
log_R_spaced = [min(log_R):min_step:max(log_R)];
for s = (length(log_R_spaced)-1):-1:1
subR = (log_R>=log_R_spaced(s))&(log_R<=log_R_spaced(s+1));
mean_logR(s) = (log_R_spaced(s)+log_R_spaced(s+1))/2;
mean_dtc(s) = mean(sort_col(subR,2));
end
figure; plot(log10(sort_col(:,1)), sort_col(:,2),'b.',mean_logR,mean_dtc,'r-o');
dtc = logR_dtc(mean_logR);
figure; plot(mean_logR,mean_dtc,'b.',mean_logR,dtc,'g.');

fit_dtc = logR_dtc(log10(sort_col(:,1)));
figure; 
plot(log10(sort_col(:,1)), sort_col(:,2),'b.',...
   log10(sort_col(:,1)),fit_dtc,'r.');

%% Now compute some statistics... such as bias (difference), absolute bias, 
%% standard deviation of original values within a log_R_spaced steps, 
%% standard deviation of bias values
%% and relative deviations (divide by the mean_dtc)


function dtc = logR_dtc(logR);
% double eqn8175(double x)
% /*--------------------------------------------------------------*
%    TableCurve Function: C:\\case_studies\\MPL\\APD_DTC\\logR_dtc.c Jan 8, 2008 11:54:01 AM 
%    C:\\MATLAB_R2007b\\toolbox\\logR_dtc.txt 
%    X= log_R 
%    Y= dtc 
%    Eqn# 8175  LogNorm4(a,b,c,d,e) 
%    r2=0.9996557659494626 
%    r2adj=0.9995233682377174 
%    StdErr=0.00512174897809635 
%    Fstat=10164.00084582169 
%    a= 0.9959821189967173 
%    b= 3.275375779335298 
%    c= 4.168517994572751 
%    d= 0.1873021366835257 
%    e= 0.2609923355675236 
%    Constraints: (e>1,x>t) or (e<1,x<t) t=c-d*e/(e*e-1), d>0, e>0, e<>1 
%  *--------------------------------------------------------------*/
% {
%   double y;
%   double n; 
%   double m; 
%   n=log(1.0+(x-4.168517994572751)*(0.2609923355675236*
%     0.2609923355675236-1.0)/(0.1873021366835257*
%     0.2609923355675236));
%   m=log(0.2609923355675236);
%   y=0.9959821189967173+3.275375779335298*exp(-
%     0.69314718055994530941*n*n/(m*m));
%   return(y);
% }
x = logR;
   a= 0.9959821189967173 ;
   b= 3.275375779335298 ;
   c= 4.168517994572751 ;
   d= 0.1873021366835257 ;
   e= 0.2609923355675236 ;
   
   n=log(1.0+(x-c).*(e.^2-1.0)/(d.*e));
   m=log(e);
   y=a+b.*exp(-0.69314718055994530941.*n.^2/(m.^2));
   dtc = y;