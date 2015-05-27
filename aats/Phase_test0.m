%This should produce values in Bohren and Huffman p. 482
lambda=[0.6328]; 
m=1.55+0i;
r=0.525

angle=[0:9:180];
[S11,Q_scat,Q_ext,Q_bks,gasym]=phase(lambda,r,m,angle);


sprintf('%7.6e',Q_scat)
sprintf('%7.6e',Q_ext)
sprintf('%7.6e',Q_bks)
sprintf('%6.6e ',(S11'/S11(1)))
