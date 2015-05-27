function SimpsonSum = SimpSum(inwave, d_xwave); 
% 
    Npnts = length(inwave);
    SimpsonSum=0;
    for i = 2:2:(Npnts-3)
        SimpsonSum=SimpsonSum+(2 * inwave(i) + inwave(i+1));    % this is for the 4/3,2/3,4/3,2/3 pattern
    end %for
    SimpsonSum=SimpsonSum + 2 * inwave(Npnts-1);    % this is the 4/3 at the end of the 4/3,2/3,4/3,2/3 pattern
    SimpsonSum=SimpsonSum+(inwave(1)+inwave(Npnts)) / 2;    % this is for the 1/3 at the first and last
    SimpsonSum=SimpsonSum * 2 *d_xwave / 3;
    
%         SimpsonSum=0.
%     For (i=1;i<=Npnts-4;i+=2)
%         SimpsonSum=SimpsonSum+(2.*inwave[i]+inwave[i+1])    // this is for the 4/3,2/3,4/3,2/3 pattern
%     Endfor
%     SimpsonSum=SimpsonSum+2.*inwave[Npnts-2]    // this is the 4/3 at the end of the 4/3,2/3,4/3,2/3 pattern
%     SimpsonSum=SimpsonSum+(inwave[0]+inwave[Npnts-1])/2.    // this is for the 1/3 at the first and last
%     SimpsonSum=SimpsonSum*2./3.*d_xwave