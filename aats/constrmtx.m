function [hmatrix] = constrmtx(iconstrnt,norder);
%function [hmatrix] = constrmtx(iconstrnt,norder);
%This routine calculates smoothing matrix as defined by Twomey on pages 124-125 of his book,
%Introduction to Mathematics of Inversion in Remote Sensing and Indirect Measurements
%iconstrnt = 0	sum of squares of elements of f, hmatrix = identity matrix
%          = 1 first differences 
%          = 2 second differences 
%
%written by John Livingston and Beat Schmid; January 8,1998

switch iconstrnt
	case 0,
      hmatrix=eye(norder);
   case 1, 
      kmatrix=-eye(norder)+diag(ones(1,norder-1),-1);
      kmatrix(1,1)=0;
   case 2,
      kmatrix=2*eye(norder)+diag(-ones(1,norder-1),-1)+diag(-ones(1,norder-1),1);
      kmatrix(1,:)=0;
      kmatrix(end,:)=0;      
end

hmatrix = kmatrix'*kmatrix;
