function nm = sws_new_ingaas_pixelmap;

Cn  = [2206.58 -4.48404 -3.19203e-4 -9.1953e-6];
pix = [0:255];
nm = Cn(1) + Cn(2).*pix + Cn(3).*pix.^2 + Cn(4).*pix.^3;
sprintf('%3.2f \n',nm)

return