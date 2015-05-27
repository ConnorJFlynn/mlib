function y=sellmeier(lambda,B1,B2,B3,C1,C2,C3);
% computes n^2-1 according to the Sellmeier formula (Schott Optical Glass p. 10)
% lambda has to be in microns

l2=lambda.^2;

y=B1*l2./(l2-C1)+B2*l2./(l2-C2)+B3*l2./(l2-C3);
return
