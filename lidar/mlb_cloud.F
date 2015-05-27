#include "fintrf.h"
C
#if 0
C
C     mlb_cloud.F
C     .F file needs to be preprocessed to generate .for equivalent
C
#endif
C
C     mlb_cloud.F
C
C     multiple the first input by the second input

C     This is a MEX file for MATLAB.
C     Copyright 1984-2006 The MathWorks, Inc.
C     $Revision: 1.1 $

      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
C
      mwpointer plhs(*), prhs(*)
      mwpointer mxCreateDoubleMatrix
      mwpointer mxGetPr
      mwpointer x_pr, y_pr, z_pr, a_pr, b_pr, c_pr, z1_pr
C-----------------------------------------------------------------------
C

      integer nlhs, nrhs, mxIsNumeric, qlhs
      mwsize m, n, size,row
      mwsize mxGetM, mxGetN
C      real  x,a, b,c, y(1500), z(1500), z1(1500)
      real  ncount,time2(1500),powra2(1500)
      real prange2(1500),ref2(1500),z(1500),z1(1500)
      real*8 base, top

C     Check for proper number of arguments.
      if (nrhs .ne. 5) then
         call mexErrMsgTxt('Five inputs required.' )
      elseif (nlhs .ne. 2) then
         call mexErrMsgTxt('Two output required.')
      endif

C     Check to see both inputs are numeric.
      if (mxIsNumeric(prhs(1)) .ne. 1) then
         call mexErrMsgTxt('Input # 1 is not a numeric.')
      elseif (mxIsNumeric(prhs(2)) .ne. 1) then
         call mexErrMsgTxt('Input #2 is not a numeric array.')
      endif

C     Check that input #1 is a scalar.
      m = mxGetM(prhs(1))
      n = mxGetN(prhs(1))
      if(n .ne. 1 .or. m .ne. 1) then
         call mexErrMsgTxt('Input #1 is not a scalar.')
      endif

C     Get the size of the input matrix.
      m = mxGetM(prhs(2))
      n = mxGetN(prhs(2))
      size = m*n
      if(size .gt. 1500) then
         call mexErrMsgTxt('Input #2 number of elements exceeds buffer')
      endif
C     Get the size of the input matrix.
      m = mxGetM(prhs(3))
      n = mxGetN(prhs(3))
      size = m*n
      if(size .gt. 1500) then
         call mexErrMsgTxt('Input #3 number of elements exceeds buffer')
      endif
C     Get the size of the input matrix.
      m = mxGetM(prhs(4))
      n = mxGetN(prhs(4))
      size = m*n
      if(size .gt. 1500) then
         call mexErrMsgTxt('Input #4 number of elements exceeds buffer')
      endif
      m = mxGetM(prhs(5))
      n = mxGetN(prhs(5))
      size = m*n
      if(size .gt. 1500) then
         call mexErrMsgTxt('Input #5 number of elements exceeds buffer')
      endif


C     Create matrix for the return argument.
      plhs(1) = mxCreateDoubleMatrix(m,n,0)
      plhs(2) = mxCreateDoubleMatrix(m,n,0)
      x_pr = mxGetPr(prhs(1))
      y_pr = mxGetPr(prhs(2))
      z_pr = mxGetPr(plhs(1))
      z1_pr= mxGetPr(plhs(2))
      a_pr = mxGetPr(prhs(3))
      b_pr = mxGetPr(prhs(4))
      c_pr = mxGetPr(prhs(5))

C     Load the data into Fortran arrays.
      row = 1
      call mxCopyPtrToReal8(x_pr,ncount,row)
      call mxCopyPtrToReal8(y_pr,time2,size)
      call mxCopyPtrToReal8(a_pr,powra2,size)
      call mxCopyPtrToReal8(b_pr,prange2,size)
      call mxCopyPtrToReal8(c_pr,ref2,size)

C     Call the computational subroutine
C      call mlb_cloud(x,y,a,b,c,m,n, z, z1)
      call mlb_cloud(ncount,time2,powra2,prange2,ref2,base,top,m,n)

C     Load the output into a MATLAB array.
      call mxCopyReal8ToPtr(base,z_pr,size)
      call mxCopyReal8ToPtr(top,z1_pr,size)

      return
      end
      subroutine mlb_cloud(ncount,time2,powra2,prange2,ref2,
     1     base,top,m,n)
      mwsize m,n 
      mwsize i,j 
      integer ipout, name
      integer ncount
      real powra(m),prange(m)
      real powra2(m,n),prange2(m,n), time2(m,n) 
      real ref(m),hh(5000), ref2(m,n)
      real ratio(5000),time,p(5000)
      real x(100),y(100),y1(100),h(5000),hpeak(200),htop(200)
      real slope(5000),slope1(5000),avg,difp1,difp2,difp3
      real hcb(50),hct(50),ntopstar(50)
      real topflag(50),signalratio(5000),minisignal,slopemax(200)
      real p1(5000),slope1max(200),p2(5000)
      real y2(100),slope2(5000),rainslope,sdvbegratio
      real maxtempslope,avgsignalratio0,ts0,tsthreshold
      real slope_threshold,hbase(50),cloudflag(200),leveln,max0
      real*8 base(m,n), top(m,n)
      CHARACTER(LEN=30) :: Format
      CHARACTER(LEN=30) :: filename 
      CHARACTER (LEN=*), PARAMETER :: fname="Zhien_base"
      CHARACTER (LEN=20) :: fullname !** NOTE 20 characters!!!
      fullname=fname//"_"//filename !** Concatenation
      do 20 i=1,m
         do 10 j=1,n
             time = time2(1,1)
             powra(i)=powra2(i,j)
             prange(i)=prange2(i,j)
             ref(i)=ref2(i,j)
             base(i,j) = 0.0
             top(i,j) = 0.0
 10      continue
 20   continue
      ncount = int(m)
      base = 0.0
      top = 0.0
      do i=1,50 
         hcb(i)=0.0
         hct(i)=0.0
      enddo
CCC   Start cloud base analysis
ccc   nbeg start data point; nend end data point 
      nbeg=5
      nend=ncount
C      write(12, *) ncount 
C     format(1x, f8.5)
C      write(12, *) '================' 
C      write(12, *) 'Height  Bscat  Rayleigh' 
      do i=1, ncount
C        write(12, *) prange(i), powra(i), ref(i) 
C2       format(1x, f8.5, 1x, f13.5, 1x, f13.5)
      enddo
      do n=1,nend
         h(n)=prange(n)
         ref(n)=ref(n)/h(n)/h(n)
      enddo
CCC   Using last 50 points to calcualte the standard deviation of background, 
C     when ncount=500. This is an approximation. You can use actual background 
C     data to calculate it and pass it to this subroutine.

C     print 5, ncount, powra(2), ' I am in powra'
C     write(12, *) time,  powra, prange, ref
C5     format(1x,f8.5,  f8.5, 1x, f8.5, 1x, f8.5)
      beg0=0.
      ibeg0=0
      avg=0.
      do n=nend-10,nend
         beg0=beg0+abs(powra(n))
         avg=avg+powra(n)
         ibeg0=ibeg0+1
      enddo
      beg0=beg0/float(ibeg0)
      avg=avg/float(ibeg0)
      sdv=0.
      do n=nend-10,nend
         sdv=sdv+(powra(n)-avg)**2.
      enddo
      sdv=sqrt(sdv/float(ibeg0-1))

      minisignal=3.*sdv
C     write(12,*) 'time:',time, beg0, sdv, sdv/beg0
      sdvbegratio=sdv/beg0
      nend0=nend

CCC   
c     To calculate the slope of signal     
      nfit=5                    ! number of points for slope calcualtion, which depends on the
                                ! vertical resulation of system

      do n=nbeg+nfit/2.+1,nend0-nfit/2.
c         write(*,*) n,nend0-nfit/2.
         flagfit=0.
         do j=1,nfit
            if ((powra(n-nfit/2-1+j)).le.0.) then 
               flagfit=1.
               goto 2002
            endif 
            x(j)=h(n-nfit/2-1+j)
            y(j)=log(powra(n-nfit/2-1+j))
            y1(j)=(powra(n-nfit/2-1+j))
            y2(j)=log(powra(n-nfit/2-1+j)*x(j)*x(j))

         enddo
 
         call line(x,y,a,b,nfit)
         slope(n)=a             ! slope of log(P)
         yvar=0.
         yavg=0.
         do j=1,nfit
            yvar=yvar+abs(y(j)-a*x(j)-b)
            yavg=yavg+y(j)
         enddo
         If(abs(a).gt.1.e8) yvar=10.*yavg
         signalratio(n)=yvar/yavg ! the variation of signal
 2002    if (flagfit.eq.1.) then
            signalratio(n)=10.
            slope(n)=0.
         endif
c         if (h(n) .lt. 15.0) then 
C           print *,h(n),powra(n),slope(n),signalratio(n)
c         endif

c         if (ipout .eq. 1) then       
c            write(40,*) h(n),powra(n),slope(n),signalratio(n)
c         endif

         call line(x,y2,a,b,nfit)
         slope2(n)=a            ! slope of log(P*R*R), range corrected signal 
         if (flagfit.eq.1.) then
            signalratio(n)=10.
            slope(n)=0.
            slope2(n)=0.
         endif

         call line(x,y1,a,b,nfit)
         slope1(n)=a            ! slope of P 

c     yvar=0.
c     yavg=0.
c     do j=1,nfit
c     yvar=yvar+abs(y1(j)-a*x(j)-b)
c     yavg=yavg+y1(j)
c     enddo
c     If(abs(a).gt.1.e8) yvar=10.*yavg
c     signalratio(n)=yvar/yavg

      enddo

      do n=1, nbeg+nfit/2
         slope(n)=slope(nbeg+nfit/2+1)
         slope1(n)=slope1(nbeg+nfit/2+1)
         slope2(n)=slope2(nbeg+nfit/2+1)
      enddo

C     Calculate the maximum of negative slope from 0.4km to 5km
      n1=10                     ! for ARM Raman lidar
      n2= 130
      do n=n1,n2
         p2(n-n1+1)=-slope2(n)
      enddo
      call maxf(n2-n1+1,p2,ilable,max0)
      n=n1+ilable-1
      rainslope=(slope(n)+slope(n-2)+slope(n-1)+slope(n+1)
     #     +slope(n+2))/5.

 700  continue


      nend=nend0-nfit/2.  
CCC   
CCC   Star to look for layers
      iid=0
      nstar=nbeg+1              !+40
      nstar0=nstar

 800  do n=nstar,nend-1

         sdv0=sdv
         if ((h(n).lt.5.).and.(powra(n).gt.(20.*minisignal))) then
            iavg0=0
         else
            iavg0=3
         endif 

         slopeavg3=(slope2(n+1)+slope2(n-1)+slope2(n))/3.
         difp1=powra(n+3)-powra(n+2)
CCC   
C     We use range corrected signal to calcuate the increase of signal if it
C     is satisfied to following conditions. For strong attenuation low clouds,
C     we can't detect strong increase in range uncorrected lidar signal, but 
C     range corrected lidar signal can show the increase in signal 
C     at low level.


         if((h(n+3).lt.5.).and.(powra(n).gt.(20.*minisignal)).and.
     #        (((slopeavg3.gt.0.35).or.((slopeavg3.gt.0.0).and.
     #        (slope2(n+5).lt.-3.))).and.
     #        (difp1.lt.0.).and.
     #        ((slope(n+7).lt.-3.).or.(slope(n+5).lt.-3.).or.
     #        ((slope2(n+5)+slope2(n+6)).gt.1.0) )  )
     #        ) then

C     To calculate the average signal below point n
            avg=0.
            ic=0
            do iavg=n-iavg0,n
               ic=ic+1
               avg=avg+powra(iavg)*h(iavg)*h(iavg)
            enddo
            avg=avg/float(ic)
            difp1=powra(n+1)*h(n+1)*h(n+1)-avg
            difp2=powra(n+2)*h(n+2)*h(n+2)-avg
            difp3=powra(n+3)*h(n+3)*h(n+3)-avg
            sdv0=sdv*h(n+1)*h(n+1)

         else

            avg=0.
            ic=0
            do iavg=n-iavg0,n
               ic=ic+1
               avg=avg+powra(iavg)
            enddo
            avg=avg/float(ic)

            if (avg.lt.minisignal/5.) avg=minisignal
            difp1=powra(n+1)-avg
            difp2=powra(n+2)-avg
            difp3=powra(n+3)-avg

         endif


         avg=0.
         ic=0
         do iavg=n-iavg0,n
            ic=ic+1
            avg=avg+powra(iavg)
         enddo
         avg=avg/float(ic)

cccc  changed 05/11/2001
         if (avg.lt.minisignal/5.) avg=minisignal
         difp1=powra(n+1)-avg
         difp2=powra(n+2)-avg
         difp3=powra(n+3)-avg

         
C     If difp1-3 satisfy certain conditions, point n is a layer
c     base
c         write(12,*) h(n),difp1,difp2,difp3,sdv0,powra(n)

c changed slightly to get more cloud detection in thin cirrus during daytime
         if((difp2.ge.difp1).and.
     $        (difp3.ge.difp2).and. 
c     $        (difp1.gt.sdv0) .and. (powra(n).gt.sdv0)) then
     $        (difp1.gt.(3.*sdv0))) then

            iid=iid+1
            iidbase=n
            hh(iid)=h(n+1)
            if(avg.lt.powra(n)) avg=powra(n)
            powerbase=avg
            nstar=n+2           ! +2 because we use the three points to detect the layer
                                ! base. 
            
            Rref=avg/ref(n)
            basesr=(signalratio(n-2)+signalratio(n-1))/2.
C           write(12,*) 'layer_base 1', hh(iid),n,basesr,avg
            goto 1000

         endif
C      print *, ' I am here in 25lr'

CCCC  There sometimes are strong attenuation clouds at low level, and 
C     we can't find three points continuous increase for raman lidar.
C     So we use two points increase and strong decrease after 100m as 
C     condition to detect a layer base

         IF(h(n).lt.6.) THEN

            if((difp1.gt.(3.*sdv0)).and.
     $           (difp2.gt.0.).and.
     $           ((slope(n+5).lt.-3.).and.(h(n+5).gt.0.6))) then

               iid=iid+1
               iidbase=n
               hh(iid)=h(n+1)
               if(avg.lt.powra(n)) avg=powra(n)
               powerbase=avg
               nstar=n+1        ! +1 because we use the two points to detect the layer
                                ! base. 

               Rref=avg/ref(n) 
               basesr=(signalratio(n-2)+signalratio(n-1))/2.
C               write(12,*) 'layer_base 2',hh(iid),n,basesr,avg,rref
               goto 1000

            endif
         ENDIF

CCCC  For strong attenuation low clouds, there is not positive slope at cloud
C     base. The change of negative slope is used to detect this clouds.

         IF(h(n).lt.2.) THEN
            difp1=slope(n+1)-slope(n)
            difp2=slope(n+3)-slope(n)
            if((difp1.lt.0.).and.
     $           (difp2.lt.-2.).and.(rainslope.lt.-10.)) then

               iid=iid+1
               iidbase=n
               hh(iid)=h(n)
               avg=powra(n)/1.1
               powerbase=avg
               nstar=n+2  

               Rref=avg/ref(n) 
               basesr=(signalratio(n-2)+signalratio(n-1))/2.
C               write(12,*) 'layer_base 3',hh(iid),n,basesr,avg,rref
               goto 1000

            endif
         ENDIF

 810     continue
      enddo                     !n

CCC   No layer base is found, goto the 1090 to judge cloud layer
      goto 1090           
 1000 continue

CCC   Calculate the maximum negative slope within about 1km above layer base
      do n=nstar+1,nstar+30
         p2(n-nstar)=-slope(n)        
      enddo
      call maxf(30,p2,ilable,max0)
      n=nstar+ilable
      maxtempslope=slope(n)
C      write(12,*) n, slope(n), 'I am in slope'
      
CCc   
C     looking for layer top.
      tempslope=0.
      do n=nstar, nend

C     First we look for the point where signal reduce to the level
C     of layer base (correcting range effect) or air return level
C     at given altitude rescaled according to layer base signal.

c     leveln=Rref*ref(n)  !air return level at given altitude rescaled 
                                !according to layer base signal.
         leveln=avg*h(iidbase)**2/h(n)**2 !the level of layer base 
                                ! (range corrected)
         
c     write(12,*) h(n),leveln,powra(n),ref(n)

         if (((powra(n).le.leveln).
     #        and.((slope(n).lt.-1.).or.(maxtempslope.gt.-3.)))
     #        .or.(powra(n).le.minisignal)
     #        .or.((powra(n).le.avg ) 
     #        .and. ((h(n)-h(iidbase)).lt.0.4) )
     #        .or.((powra(n).le.avg).and.(h(n) .gt. 14.) )) then
            nstar=n
c           write(12,*) h(n),n,powra(n),leveln,maxtempslope,avg
            h00=h(n)
            goto 1010
         endif
      enddo
 1010 continue


C     c     Second, we look for the local maximum of negative slope.
C     (powra(n).le.minisignal): signal too small
C     (signalratio(n).gt.0.2): Signal too noisy
C     ( ((slope2(n)+slope2(n+1))/2.).ge.-1.8): slope close to 
C     air return slope. Here we simply use -0.8 to cut it. 

c     goto 1020
      
      do n=nstar,nend
         if((powra(n).le.minisignal).or.(signalratio(n).gt.0.2)
     #        .or. ( ((slope2(n)+slope2(n+1))/2.).ge.-1.8)) goto 1020
         
         if ((slope(n).le.slope(n+1)).and.
     #        (slope(n).le.slope(n+2)).and.    
     #        (slope(n).le.slope(n-1)).and.      
     #        (slope(n).le.slope(n-2))) then
            nstar=n
            tempslope=slope(n)
C            write(12,*) 'max',h(n),n,tempslope
            goto 1020
         endif
      enddo
 1020 continue
      

C     c      looking for the layer top where slope from negative return to
c     a preselected negative value or signal reduces below minisignal.
C     Here we use different thresholds for different altitudes.

      iflagtop=0
 1025 do n=nstar,nend
         if(h(n).lt.1.0) then
            slope_threshold=-2.
         else 
            if((h(n).lt.2.0).and.(h(n).ge.1.0)) then
               slope_threshold=-1.5 !-1.2
            else 
               slope_threshold=-1.0 !-0.8
            endif 
         endif
         if(( ((slope2(n)+slope2(n+1))/2.).ge.slope_threshold)
     #        .or.(powra(n).le.minisignal)) then
            nstar=n
            htop(iid)=h(n-2)
            iidtop=n-2
            ratiobasetotop=avg*hh(iid)**2/(powra(n)*h(n)**2)
            goto 1030
         endif

      enddo
 1030 continue
C      write(12,*) 'top,h(n),n,ratiobasetotop,powra(nstar),minisignal'
C      write(12,*) h(n),n,ratiobasetotop,powra(nstar),minisignal
      iflagtop=iflagtop+1

      do n=iidbase,iidtop
         p1(n-iidbase+1)=-slope(n) 
      enddo
      call maxf(iidtop-iidbase+1,p1,ilable,max0)
      n1=iidbase+ilable-1
      if (abs(signalratio(n1)).lt.0.1) then
         avgslopemax=(slope(n1)+slope(n1-1)+slope(n1+1))/3.
      else
         avgslopemax=-1.
         do n=iidbase,n1
            if((slope(n).lt.slopemax(iid)).and.
     #           (abs(signalratio(n)).lt.0.1)) then
               avgslopemax=(slope(n)+slope(n-1)+slope(n+1))/3.
            endif
         enddo        
      endif 

CCC   If powra(n)> 20.*minisignal, looking for next 1km to see whether there
C     is a big decrease in signal or not, because there are sometimes are 
C     sublayer around the top.
      do n=iidbase,iidtop
         p(n-iidbase+1)=powra(n)
      enddo
      call maxf(iidtop-iidbase+1,p,ilable,max0)
      n=iidbase+ilable-1
      npeak=n
      ratio(iid)=powra(npeak)/
     #     (powerbase*hh(iid)**2/h(npeak)**2)

      If  ((iflagtop.eq.1).and.(ratio(iid).gt.2.)) then
         tsthreshold=-3.
      else
         tsthreshold=-4.5
      endif
      if (htop(iid) .lt. 2.)  tsthreshold=-6  
      
      IF ((powra(nstar).gt.( 20.*minisignal))
     #     .and.(avgslopemax.lt.-3.)) then 
         ts=1.0
         nts0=nstar
         do n=nstar+1,nstar+18
            ts0=(slope(n)+slope(n+1)+slope(n-1))/3.
            IF (ts.gt.ts0) then
               ts=ts0
               nts0=n
C     C       If the negative slope is larger enough and data quality is good,
C     this negative slope indicate a sublayer.
               avgsignalratio0=(signalratio(nts0-1)+signalratio(nts0)+
     #              signalratio(nts0+1))/3.
               if((ts.lt.tsthreshold).and.(avgsignalratio0 .lt.0.1)) 
     #              then 
                  nstar=nts0
                  goto 1025
               endif
            ENDIF

         enddo
      ENDIF


CCC   
c     looking for the peak of cloud signal
      do n=iidbase,iidtop
         p(n-iidbase+1)=powra(n)
         p1(n-iidbase+1)=-slope(n) 
         p2(n-iidbase+1)=slope1(n)        
      enddo

      call maxf(iidtop-iidbase+1,p,ilable,max0)
      n=iidbase+ilable-1
      npeak=n
      hpeak(iid)=h(n)

C     C----- the  maximum of positive slope
      call maxf(iidtop-iidbase+1,p2,ilable,max0)
      n=iidbase+ilable-1
      slope1max(iid)=slope1(n)  !(slope1(n)+slope1(n-1)+slope1(n-2))/3.
      slope1max(iid)=slope1max(iid)/powra(npeak)

C     C----- the  maximum of negative slope
      call maxf(iidtop-iidbase+1,p1,ilable,max0)
      n1=iidbase+ilable-1
      if(n1.lt.npeak) n1=npeak+3
      if (abs(signalratio(n1)).lt.0.1) then
         slopemax(iid)=(slope(n1)+slope(n1-1)+slope(n1+1))/3.
         avgslopemax=(slope(n1)+slope(n1-1)+slope(n1+1))/3.
      else
         slopemax(iid)=-1.
         avgslopemax=-1.
         do n=iidbase,n1
            if((slope(n).lt.slopemax(iid)).and.
     #           (abs(signalratio(n)).lt.0.1)) then
               slopemax(iid)=(slope(n)+slope(n-1)+slope(n+1))/3.
               avgslopemax=(slope(n)+slope(n-1)+slope(n+1))/3.
            endif
         enddo        
      endif 
      
      



CCC   Claculate the ratio of peak signal to base signal.
C     We can use base signal directly or rescaled air return signal
C     at peak. 

      if (powerbase.le. minisignal) powerbase=minisignal
c     powerbase=Rref*ref(npeak)
      powerbase=powerbase*hh(iid)**2/hpeak(iid)**2

      if( powerbase.le.0.) then
         ratio(iid)=0.
      else
         ratio(iid)=powra(npeak)/powerbase
      endif

CCCCCCif base-to-top ratio is not large enough, the large negative slope
C     is caused by the transition from boundary layer to free troposphere.
C     So we limite the maximum negative slope to -5. 
      
      if ((htop(iid) .lt.2) .and.( ratiobasetotop.lt.20.)) 
     #     slopemax(iid) =-5.


C     average signal variation at peak
      s_ravg=(signalratio(npeak-1)+signalratio(npeak)
     #     +signalratio(npeak+1))/3.
      if (s_ravg.lt.signalratio(npeak)) s_ravg=signalratio(npeak)

C      write(12,*) 'ratio',ratio(iid),s_ravg,basesr,slopemax(iid)
      

CCC   
C     If the signal to noise ratio of this layer is low, we take this layer
C     out. If the signal to noise ratio is good, and layer base of this layer
C     is within 0.06km of later layer's top, then we updata this later layer's
C     top to this layer's top. 

Ccc   If the signal is too noisy, we take out this layer
c     if ((basesr.lt.0.).or.((basesr.gt.0.1).and.
c     #  (ratio(iid).lt.4.5)).or.
c     # (slopemax(iid).ge.0.).or.
c     #  ((basesr.gt.0.3) .and. (ratio(iid).lt.6.))) then

c     if (((basesr.lt.0.).and. (ratio(iid).lt.3.)).or.
      if ( (basesr.lt.0.).or.
     #     ((basesr.gt.0.2).and. (ratio(iid).lt.2.5)).or.
     #     (slopemax(iid).ge. 0.).or.
     #     ((basesr.gt.0.5) .and. (ratio(iid).lt.4.))) then
         iid=iid-1
C         write(12,*) 'cut 1'
         goto 1089              !1090 
      endif

C     C     If S(base)>0.035 and peak to base ratio <2. or maximum negative 
C     slope>-8, it is a noise.


      if (((abs(basesr).gt.0.035).and.(ratio(iid).lt.2.))
     #     .and.((abs(basesr).gt.0.035).and.(avgslopemax.ge.-7.))
     #     )  then 
C         write(12,*) 'basesr',basesr,ratio(iid),avgslopemax
         iid=iid-1
         goto 1089
      endif

C     C     If S(peak)>0.035 and the ratio <4 or the maximum negative 
C     slope >-8, it is  a noise or aerosol layer
      
      if(((s_ravg.gt.0.05).and.(ratio(iid).lt.3.))
     #     .and.((s_ravg.gt.0.05).and.(avgslopemax.ge.-6.))
     #     .or.(signalratio(npeak).lt.0.))  then
C         write(12,*) s_ravg,ratio(iid),slopemax(iid),signalratio(npeak)

         iid=iid-1
      else

CCC   If a weak layer's base is near a strong layer's top, put this weak
C     layer into the strong layer.
         if (iid .gt. 1 ) then
            if (((hh(iid)-htop(iid-1)).lt.0.06).and.
     #           (ratio(iid).gt.1.5).and. (s_ravg.lt.0.20).and.
     #           (ratio(iid-1).gt.6.) .and.(iid.gt.1) ) then
               htop(iid-1)=htop(iid)
               iid=iid-1
            endif
         endif
      endif
      
 1089 continue
C      write(12,*) iid

CCC   for multi-layer repeat above steps
      if( nstar.lt.nend-1) goto 800 
      

 1090 continue

      ic=0      

CCCC  looking  for the cloud layer
C     we use the ratio of peak signal to base signal or to rescaled air
C     return signal at peak  and the  maximun negative slope to decide 
C     whether this layer is a cloud layer or not.

      if (iid.eq.0) goto 9191   ! no layer

      icloud=0
      do i=1,iid

         cloudflag(i)=0.

         hratio=2.0  
         if (sdvbegratio .lt.0.1) hratio=1.3 !1.4
         if (((ratio(i).gt.8.).and. (hh(i).lt.4.)).or.
     #        ((ratio(i).gt. hratio).and. (hh(i).ge.4.).and.
     #        ((htop(i)-hh(i)).gt.0.1)) .or. 
c     #   (slopemax(i).lt.-6.) ) then ! It is cloud
     #        ((slopemax(i).lt.-8.) .and.(ratio(i).gt.1.5) )) then ! It is cloud
         icloud=icloud+1
         hcb(icloud)=hh(i)
         hct(icloud)=htop(i)
         ratio(icloud)=ratio(i)
         hpeak(icloud)=hpeak(i)
         cloudflag(i)=1.

C     Here we try to include the small layer which is just within 
C     300m of a cloud base.
         if ((i.gt.1).and.(cloudflag(i-1).eq.0.) ) then
            if((hh(i-1).gt.1.0) .and.(hh(i-1).lt.5.0)) then
               if(((ratio(i).gt.3).or.(slopemax(i).lt.-4.)).and.
     #              ((hh(i)-htop(i-1)).lt.0.3)   ) then
                  hcb(icloud)=hh(i-1)
                  cloudflag(i)=1.
               endif
            endif
         endif 

      else  

C     Here we try to include the small layer which is just within 
C     300m of a cloud top.
         if (icloud.ge.1) then
            if ((abs(hh(i)-hct(icloud)) .lt.0.3).and.
     #           (hh(i).gt.5.).and.
     #           ((ratio(i).gt.1.4).or.
     #           (slopemax(i).lt.-3.5))) then
               hct(icloud)=htop(i)
               cloudflag(i)=1. 
            endif            
         endif
      endif
      enddo

C     C     A cloud layer is sometimes detected as several sublayers, 
C     or there is only a small difference between one's top and another base.
C     So we need put them together as one layer. Here if one's top and another
C     base is within 500m, these two layers are put together.
c      if (icloud.gt. 1) then
c	 write(12,*) 'icloud:',icloud,hcb(1), hct(icloud)
c      else
c        write(12,*) 'icloud:',icloud
c      endif 

      if (icloud.eq.0) goto 9191

      if (icloud.gt. 1) then
 1222    i1=1
         ic=1       
         do i=i1,icloud-1
            if (abs(hct(ic)-hcb(ic+1)).le.0.5) then
               hcb(ic)=hcb(i)
               hct(ic)=hct(i+1)
               if(ratio(i).lt.ratio(i+1)) then
                  ratio(ic)=ratio(i+1)
                  hpeak(ic)=hpeak(i+1)
               else
                  ratio(ic)=ratio(i)
                  hpeak(ic)=hpeak(i)
               endif

               do j=ic+1,icloud-1
                  hcb(j)=hcb(j+1)
                  hct(j)=hct(j+1)
                  ratio(j)=ratio(j+1)
                  hpeak(j)=hpeak(j+1)
               enddo
               icloud=icloud-1
               goto 1222
            else
               hcb(ic)=hcb(i)
               hct(ic)=hct(i)
               ratio(ic)=ratio(i)
               hpeak(ic)=hpeak(i)
               hcb(ic+1)=hcb(i+1)
               hct(ic+1)=hct(i+1)
               ratio(ic+1)=ratio(i+1)
               hpeak(ic+1)=hpeak(i+1)
               ic=ic+1
            endif
         enddo
      else 
         ic=1
      endif

c     c      If the first cloud layer base is below 5km or other selected value,
C     then we try to find whether there is a percipation layer below real
C     cloud layer base on the slope of return signal. It is very difficult
C     to distinguish these two different base. Now we use following approach.
C     First is to find the maximum of positive slope from peak to base 
C     or from top to base. Then we search downward for a local minimum of 
C     positive slope when it is smaller than a threshold,
C     or where it is smaller than 0. This altitude will be the cloud 
C     base if following conditions are satisfied: strong attenuation in the 
C     clouds; magnitude difference in backscatter between clouds and virga, 
C     and virga layer should be wide enough. This part of algorithm is still 
C     tested, and we need more data to test it and to find a best algorithm.
C     write(12,*) 'top:', (hct(i),i=1,ic)

      do ij=1,ic
         if (hcb(ij).gt.5.) then
            hbase(ij)=99999.
            goto  8300
         endif 
         
         do n=nstar0,nend
            if (h(n).eq.hcb(ij)) n1=n !base point
            if (h(n).eq.hpeak(ij)) n4=n !peak point
            if (h(n).eq.hct(ij)) n2=n !top point           
         enddo

c     looking for the maximum of positive slope from top to base
         n10=n1

         do n=n10,n2
            p(n-n10+1)=slope1(n)
         enddo
         call maxf(n2-n10+1,p,ilable,max0)
         n31=n10+ilable-1       ! the point of maximum positive slope (P)

         do n=n10,n2
            p(n-n10+1)=slope(n)
         enddo
         call maxf(n2-n10+1,p,ilable,max0)
         n32=n10+ilable-1       ! the point of maximum positive slope (log(p))
         ra=powra(n31)*h(n31)**2/(powra(n32)*h(n32)**2)
         if((((slope(n32)/slope(n31)) .gt.3. ) .or.
     #        (((slope(n32)/slope(n31)) .gt.2.).and.
     #        (slope(n32).gt.10.)))
     #        .and. (ra.lt.5.) ) then
            n3=n32
         else
            n3=n31
         endif

         maxslope=slope(n3)
         hmaxslope=h(n3)
         if(maxslope.le.0.) n3=n1

C     Find the maximum signal beyond the maximum positive slope
         n10=n1
 8080    continue
         do n=n10,n2
            p(n-n10+1)=powra(n)
         enddo
         call maxf(n2-n10+1,p,ilable,max0)
         n40=n10+ilable-1       ! the point of maximum signal
         if (n40.lt.n3) then
            n10=n3
            goto 8080
         endif
         n4=n40
         hbase(ij)=99999.

C     Find a local minimum of positive slope
         n5=n1 
         do n=n3,n1,-1
            if (((slope(n).lt.slope(n-1)).and.
     #           (slope(n).lt.(maxslope/15.))
     #           ).or.(slope(n).lt.0.)) then
               hbase(ij)=h(n)
               n5=n
               goto 8007
            endif
         enddo
 8007    continue

c     write(*,*) n5
         if (slope(n5-1).lt.-8.) then
            hbase(ij)=99999.
            n5=n1
         endif

C     the average power between base and peak 
         maxsub=0.
         imaxsub=0
         do n=n5,n1,-1
c     if (powra(n).gt.maxsub) then
c     maxsub=powra(n)
c     endif
            maxsub=maxsub+powra(n)*h(n)*h(n)
            imaxsub=imaxsub+1
         enddo
         maxsub=maxsub/float(imaxsub)

C     the average negative slope between peak and 15% peak signal
         nfit=0
         do n=n4,n2
            nfit=nfit+1
            if (powra(n).lt.(0.15*powra(n4))) then
               h20=h(n)
               goto 8001
            endif
         enddo
 8001    continue
         if (nfit.gt.200) nfit=200
         do j=1,nfit
            x(j)=h(n4+j)
c     Write(*,*) j,powra(n4+j)
            y(j)=log(powra(n4+j))
         enddo
         call line(x,y,a,b,nfit)
         a15=a
         ratiobasetop=powra(n1)*ref(n2)/powra(n2)/ref(n1)
         
c         write(11,*) time,hbase(ij),powra(n4)*h(n4)*h(n4)/maxsub,
c     #        ratiobasetop,a15,h(n4)-h(n3),ra

         peakpower=powra(n4)*h(n4)*h(n4)

         if (((hbase(ij)-h(n1)).lt.0.2*(h(n2)-h(n1))).or.
     #        (((peakpower/maxsub).lt.4.0).and.((a15.gt.-12).and.
     #        (ratiobasetop.lt.1000.) ) ).or.
     #        ((a15.gt.-8.).and.(ratiobasetop.lt.800.)) .or. 
     #        ((peakpower/maxsub).lt.0.1).or.
     #        ((h(n4)-h(n3)).gt.0.3)) hbase(ij)=99999.


 8300    continue
      ENDDO


c     goto 9876
CCC   
CCC   Following part program is to determine whether the cloud top is real top
C     or effective cloud top. We will base on the slope of signal beyond 
C     the cloud top and the signal magnitude itself.

      do i=1,ic
c     write(13,*) hct(i),ic
         do n=nstar0,nend
            if (h(n).eq.hct(i)) then
               ntopstar(i)=n
               goto 9000
            endif
         enddo                  !n
 9000    continue
      enddo                     !i

C     If the signal above the top is smaller than minisignal, it is an 
C     effective top. Otherwise data points within 2km are fitted to 
C     calculate the average slope of signal.
      hcb(ic+1)=99999. 
C      write(12,*) 'top:', (hct(i),i=1,ic),ic

      do ij=1,ic
         nn=ntopstar(ij)+1 
         if( powra(nn).lt.minisignal) then
            topflag(ij)=0.      ! effective cloud top
         else  
            nd=2./(h(2)-h(1))
            if (h(nn+nd).ge.hcb(ij+1)) then 
     #           nd=hcb(ij+1)/(h(2)-h(1))-nn
               If (nn+nd .gt. ncount) nd=ncount-nn
               do j=1,nd
                  if( powra(nn+j).lt.minisignal) then
                     nd=j-1
                     goto 9001
                  endif
                  x(j)=h(nn+j)
                  y1(j)=log(powra(nn+j))

               enddo
 9001          continue
               if (nd.lt.3)  then
                  topflag(ij)=0. ! effective cloud top
               else
                  call line(x,y1,a,b,nd)
                  yvar=0.
                  yavg=0.
                  do j=1,nd
                     yvar=yvar+abs(y1(j)-a*x(j)-b)
                     yavg=yavg+y1(j)
                  enddo

                  topratio=yvar/yavg

C     If slope is between -.2 and -1.2, and signal variation is 
C     below a threshold, the top is a  real top. You  
C     need select the range of slope according to your system, and 
C     signal-to-noise ratio. Multi-scattering causes some problems for
C     this analysis.

                  
                  if((a.ge.-.2).or.(a.lt.-1.2).or.
     #                 (abs(topratio).gt.0.2)) then
                     topflag(ij)=0. ! effective cloud top
                  else      
                     topflag(ij)=1. ! real cloud top
                  endif
               endif
            endif   
c            write(13,9999) time,a, topflag(ij),topratio
         enddo

C     write(12,*) 'top:', (hct(i),i=1,ic),ic
CCC   
C     output base, top, cloud base (if there is a virga below clouds), top 
C     flag, ratio of peak to base for each cloud layer.
 9876    do i=1,ic
c            write(12,9999) time,hcb(i),hct(i),hbase(i) 

c            write(18,9999) time,hcb(i),hct(i),hbase(i), topflag(i),
c     #           ratio(i)
 9999       format(2x, 6(f11.5,1x))
         enddo
         base(1,1)=hcb(1)
         top(1,1)=hct(ic)
C         print *,'zwang:',base(1,1),top(1,1) 
C         write(12, 9996) time, base, top 
C         write(12,*) 'top:', (hct(i),i=1,ic),ic
 9191    continue  
C         write(12,*) 'I am in 940'
C         write(12, 9996) time(1,1), base(1,1), top(1,1) 
 9998    format(2x,f11.5)
         do i=1,ic 
C            write(12, 9997) hcb(i),hct(i),hpeak(i)       
 9997   format(2x,f11.5,f11.5,f11.5)
         enddo
C         write(12, 9996) time, base(1,1), top(1,1) 
C        print *, powra(1), prange(1)
C        print *, 'Time',  time,'Base', base(1,1),'Top', top(1,1) 
 9996   format(1x,f6.3,1x, f8.3,3x,f8.3)
C         close(12)        
         return
         END

C-------------------------------------------------------------------------
      subroutine maxf(iid,summ,ilable,max0)
      real summ(iid),max0
      if (iid .eq. 0) then 
	 ilable= 0
	 max0 =0.
         goto 11
      endif
      max0=summ(1)
      ilable=1
      do i=2,iid
         if(summ(i).gt.max0) then
            max0=summ(i)
            ilable=i
         endif
      enddo
 11   continue
      return
      end
C-------------------------------------------------------------------------
      subroutine min(iid,sum,ilable,max0)
      real summ(iid),max0
      max0=summ(1)
      ilable=1
      do i=2,iid
         if(summ(i).lt.max0) then
            max0=summ(i)
            ilable=i
         endif
      enddo
      return
      end
      
      
      subroutine line(x,y,a,b,n)
c     y=a*x+b
      real x(1100),y(1100),x1,x2,y1,xy
      x1=0.
      x2=0.
      y1=0.
      xy=0.
      do i=1,n
         x1=x1+x(i)
         x2=x2+x(i)*x(i)
         y1=y1+y(i)
         xy=xy+x(i)*y(i)
      enddo
      a=(real(n)*xy-x1*y1)/(real(n)*x2-x1*x1)
      b=(x2*y1-x1*xy)/(real(n)*x2-x1*x1)
c     write(*,*) (real(n)*x2-x1*x1),5.*x2-x1*x1
      return
      end 
