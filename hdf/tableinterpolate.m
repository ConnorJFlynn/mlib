function [valintp]=tableinterpolate(xvect,yvect,valmatrix,xinvect,yinvect)
%tableinterpolate.m
% interpolates within a 2-D table
% xvect,yvect are monotonically increasing or decreasing vectors
% valmatrix is a matrix with dimensions [len(xvect),len(yvect)]
% xinvect,yinvect are vectors of same length, which can be any length

nxdim=length(xvect);
nydim=length(yvect);
nin=length(xinvect);
%first interpolate in X-direction
for k=1:nin,
    ix=[];
    iy=[];
    ix=max(find(xinvect(k)>=xvect));
    iy=max(find(yinvect(k)>=yvect));
    if isempty(ix) | isempty(iy)
        stopin_function_tableinterpolate
    end
    %valincol should be a vector of length(yvect)
    if ix<nxdim
        valintcol=valmatrix(ix,:) + (xinvect(k)-xvect(ix))./(xvect(ix+1)-xvect(ix)).*(valmatrix(ix+1,:)-valmatrix(ix,:)); 
    else
        valintcol=valmatrix(nxdim,:);
    end
    
    if iy<nydim
        valintp(k)=valintcol(iy) + (yinvect(k)-yvect(iy))./(yvect(iy+1)-yvect(iy)).*(valintcol(iy+1)-valintcol(iy));
    else
        valintp(k)=valintcol(nydim);
    end   
end