      Program tstno2
c
c Phil,
c
c   Here is the NO2 cross section subroutine that I said I would
c send to you.  The data file that this needs, will be sent as a
c separate E-mail message.
c
c  Note outside the range of Harder et al.'s measurements
c [346 to 549 nm], the subroutine returns zero.  You can probably
c use the MODTRAN NO2 data outside this range, where you correcting
c measurements of other species for residual NO2 attenuation.
c {The MODTRAN UV/visible NO2 cross sections are based on Schneider
c et al.'s measurements which have some problems with them, as
c discussed in Harder et al.'s paper.
c
c
c       Eric
c
c
c      _____________________________________________
c      I                                           I
c      I  Eric P. Shettle                          I
c      I  Code 7227, Remote Sensing Division       I
c      I  Naval Research Laboratory                I
c      I  Washington, DC 20375-5351                I
c      I                                           I
c      I  Phone:      (202)404-8152                I
c      I  Fax:        (202)767-0005                I
c      I  Internet:   shettle@poamb.nrl.navy.mil   I
c      I                                           I
c      I___________________________________________I
c
c
c
c        Tests Subroutine xsno2
c
      Common /no2dt1/ xsno2a(904,3)
      Common /no2dt2/ xsno2b(3193,4)
c
      Dimension wv1(12), temp1(5), wv2(15), temp2(6), xstest(6)
      Data wv1 / 330.0, 345.2, 345.27, 352.53, 359.48, 366.65, 366.91,
     +   374.04 , 388.35, 390.18, 390.21, 397.42 /
      Data temp1 / 224.5, 234.4, 238.6, 280.0, 310.0 /
      Data wv2 / 340.0, 359.55, 381.15, 390.47, 404.61, 419.2, 440.79,
     +  455.1, 483.66, 498.32, 541.46, 549.75, 549.8, 549.82, 650.0 /
      Data temp2 / 190.0, 223.6, 232.8, 238.6, 255.0, 298.0 /
c
      Open(unit=6, file='no2xs-test', status='unknown' )
c
c        Read no2 Cross Section Data into Common Blocks
c            This Subroutine reads unit=4, file='harder-sm-1A'
      Call no2red
c
      write(6, 900)
  900   Format(//, ' Test of Subroutine no2xs ', / )
      write(6, 910) ( temp1(j), j=1,5  )
  910   Format(//, ' For Temperature =', 5x, 6f12.1 )
      Do 20 i = 1,12
        Do 10 j = 1,5
          call xsno2( wv1(i), temp1(j), xstest(j) )
   10   Continue
        Write(6, 930) wv1(i), ( xstest(j), j=1,5 )
  930     format('  wv1(i), xs = ', f10.3, 1p5e12.4 )
   20 Continue
c
      write(6, 910) ( temp2(j), j=1,6 )
      Do 40 i = 1,15
        Do 30 j = 1,6
          call xsno2( wv2(i), temp2(j), xstest(j) )
   30   Continue
  935     format('  wv2(i), xs = ', f10.3, 1p6e12.4 )
        Write(6, 935) wv2(i), ( xstest(j), j=1,6 )
   40 Continue
c
      END
      Subroutine xsno2( wv, temp, xsec )
c
c      Given an input of:  wv = Wavelength  [nm]
c                          temp = Temperature [ deg K ]
c        Returns:   xsec = NO2 Cross-section  [ cm**2/molecule ]
c
c         Covers the spectral region from  345.2 to 549.8 nm
c          & Returns  xsec = 0,   outside those wavelengths
c
c      Assumes Data has been read into the Common Blocks by
c         Subroutine no2red
c       This Subroutine reads unit=4, file='harder-sm-1A'
c
c      Also Requires Function p4lint
c         Which does a 4 point Lagrange interpolation on
c            equally spaced data
c
c    The NO2 cross section data used here is based on the
c      measurements of Harder et al. [JGR, 102, 3861-3880, 1997]
c       smoothed to 1 Angstrom resolution.
c    The subroutine was developed by E.P.Shettle
c       Code 7227, NRL, Washington, DC 20375
c
      Common /no2dt1/ xsno2a(904,3)
      Common /no2dt2/ xsno2b(3193,4)
      Dimension tp3(3), tp4(4)
      Data tp3 / 293.8, 238.6, 230.2 /
      Data tp4 / 293.8, 238.6, 230.2, 217.0 /
C
      If( wv .lt. 345.2 ) then
c         Out of Wavelength Range
        xsec = 0.0
        RETURN
c
      ElseIf( 345.2 .le. wv  .and.  wv .lt. 390.2 ) then
c          Use 4 point interpolation in Wavelength, and
c           Linear interpolation in Temperature (T = 230K, 238K, & 294K)
c               Interpolating on the Array - xsno2a
        wvindx = (wv-345.15)/0.05
        iw = int(wvindx)
         If( iw .le. 1) iw = 2
         If( iw .ge. 903) iw = 902
        p = wvindx - iw
c
        If ( temp .gt. tp3(1) ) then
          t = tp3(1)
          jt = 1
        ElseIf ( tp3(1) .ge. temp  .and.  temp .ge. tp3(2) ) then
          t = temp
          jt = 1
        ElseIf ( tp3(2) .gt. temp  .and.  temp .ge. tp3(3) ) then
          t = temp
           jt = 2
        ElseIf ( tp3(3) .gt. temp ) then
          t = tp3(3)
          jt = 2
        EndIf
         jp = jt + 1
c
        xst = p4lint ( xsno2a(iw-1,jt), p )
        xsp = p4lint ( xsno2a(iw-1,jp), p )
c
        fdt = ( tp3(jt) - t) / ( tp3(jt) - tp3(jp) )
        xsec = xst*(1.0 - fdt) +  xsp*fdt
c
        xsec = 1.0e-19*xsec
        RETURN
c
      ElseIf( 390.2 .le. wv  .and.  wv .le. 549.8 ) then
c          Use 4 point interpolation in Wavelength, and
c           Linear interpolation in Temperature
c            (T = 217K, 230K, 238K, & 294K)
c                Interpolating on the Array - xsno2b
        wvindx = (wv-390.15)/0.05
        iw = int(wvindx)
         If( iw .le. 1) iw = 2
         If( iw .ge. 3192) iw = 3191
        p = wvindx - iw
c
        If ( temp .gt. tp4(1) ) then
          t = tp4(1)
        ElseIf ( tp4(1) .ge. temp  .and.  temp .ge. tp4(4) ) then
          t = temp
        ElseIf ( tp4(4) .gt. temp ) then
          t = tp4(4)
        EndIf
c
        Do 40 jp = 2,4
          If ( t .ge. tp4(jp) ) GO TO 50
   40   Continue
         jp = 4
   50   Continue
         jt = jp - 1
c
        xst = p4lint ( xsno2b(iw-1,jt), p )
        xsp = p4lint ( xsno2b(iw-1,jp), p )
c
        fdt = ( tp4(jt) - t) / ( tp4(jt) - tp4(jp) )
        xsec = xst*(1.0 - fdt) +  xsp*fdt
c
        xsec = 1.0e-19*xsec
        RETURN
c
      ElseIf ( wv .gt. 549.8 ) then
c         Out of Wavelength Range
        xsec = 0.0
        RETURN
c
      EndIf
c
      END
      Function p4lint( v, p)
c
c        Does 4 Point Lagrange Interpolation on the vector,
c          v(i),  i=1,2,3,4
c           Assuming equally spaced points, with
c             p = the fraction of the interval after v(2)
c
      Dimension v(4)
c
C       WM, W0, W1, W2  ARE STATEMENT FUNCTIONS USED BY
C            THE 4 POINT LAGRANGE INTERPOLATION
      WM(P) = P*(P - 1)*(P - 2)/6.0
      W0(P) = (P**2 - 1)*(P - 2)/2.0
      W1(P) = P*(P + 1)*(P - 2)/2.0
      W2(P) = P*(P**2 - 1)/6.0
C
      p4lint = w2(p)*v(4) - w1(p)*v(3) + w0(p)*v(2) - wm(p)*v(1)
c
      RETURN
c
      END
      Subroutine no2red
c
c        Reads NO2 Absorption Cross Section Data into Arrays
c          for use by Subroutine xsno2
c
      Common /no2dt1/ xsno2a(904,3)
      Common /no2dt2/ xsno2b(3193,4)
      Dimension xsecin(4193)
c
      character*75 head(10), blank
c
      Open(unit=4, file='harder-sm-1A', status='old' )
c
c          Read in T=293.8 K  data
      Read(4, 800) (head(i), i=1,10)
  800   Format(a75)
      Read(4, *) nvalue, wave1, dwave, wave2, temp
c
c      nvalue = Number of Cross Section values in the file
c      wave1  = First Wavelength
c      dwave  = Interval between Wavelengths
c      wave2  = Last Wavelength
c      temp   = Temperature at which the cross sections were measured
c
      Read(4,800) blank
      Read(4,820) ( xsno2a(i,1), i=1,900 )
      Read(4,820) ( xsno2b(i,1), i=1,3193 )
  820   Format( 10f7.4 )
c
c        Overlap the end of xsno2a with xsno2b for interpolation
      Do 20 i = 1,4
        xsno2a(i+900,1) = xsno2b(i,1)
   20 Continue
c
c          Read in T=238.6 K  data
      Read(4, 800) (head(i), i=1,10)
      Read(4, *) nvalue, wave1, dwave, wave2, temp
      Read(4,800) blank
      Read(4,820) ( xsno2a(i,2), i=1,900 )
      Read(4,820) ( xsno2b(i,2), i=1,3193 )
c
c        Overlap the end of xsno2a with xsno2b for interpolation
      Do 40 i = 1,4
        xsno2a(i+900,2) = xsno2b(i,2)
   40 Continue
c
c          Read in T=230 K  data
      Read(4, 800) (head(i), i=1,10)
      Read(4, *) nvalue, wave1, dwave, wave2, temp
      Read(4,800) blank
      Read(4,820) ( xsno2a(i,3), i=1,900 )
      Read(4,820) ( xsno2b(i,3), i=1,3193 )
c
c        Overlap the end of xsno2a with xsno2b for interpolation
      Do 60 i = 1,4
        xsno2a(i+900,3) = xsno2b(i,3)
   60 Continue
c
c          Read in T = 217 K  data
      Read(4, 800) (head(i), i=1,10)
      Read(4, *) nvalue, wave1, dwave, wave2, temp
      Read(4,800) blank
      Read(4,820) ( xsno2b(i,4), i=1,nvalue )
c
      Close(unit=4)
c
      RETURN
c
      END
