function sw= svpwat(temp)
%     SATURATION VAPOR PRESSURE OVER WATER
% **** TEMP MUST BE IN DEGREES KELVIN

      b1=double(.61078d+1);
      %a=dblarr(10)
      A(1)=.999996876D0;
      A(2)=-.9082695004D-2;
      A(3)=.7873616869D-4;
      A(4)=-.6111795727D-6;
      A(5)=.4388418740D-8;
      A(6)=-.2988388486D-10;
      A(7)=.2187442495D-12;
      A(8)=-.1789232111D-14;
      A(9)=.1111201803D-16;
      A(10)=-.3099457145D-19;
      T=temp-273.16;
      S=A(1)+T*(A(2)+T*(A(3)+T*(A(4)+T*(A(5)+...
        T*(A(6)+T*(A(7)+T*(A(8)+T*(A(9)+T*A...
        (10)))))))));
      %S=B/S^8
      sw=b1/S^8;
      
end

