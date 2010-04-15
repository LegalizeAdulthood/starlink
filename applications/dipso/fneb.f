       FUNCTION FNEB(XS,CH,TZ,FZ,DMS)
*
*  CONTINUUM FOR N, C, O AND Ne ( Z.GE.1)
*
*  XS  - WAVELENGTH IN ANGSTROMS
*  T   - TEMPERATURE IN 10**4K
*  CH  - COLUMN DENSITY OF H+
*  FZ - FRACTIONAL ABUNDANCES RELATIVE TO H+
*  FNEB- CONTINUUM FLUX AT EARTH IN ERGS CM-2 S-1 A-1
       DIMENSION FZ(5,4), TZ(4), EL(5,4,11,4), G(11,4), NL(5,4), NU(5,4)
     :           , DMS(4)

       COMMON /ADATA / EL, G, NL, NU

*  HYDROGENIC GAMMA VALUES
       DATA G(1,1)/2.60E-12/
       DATA G(2,1), G(2,2)/9.52E-14, 2.62E-13/
       DATA G(3,1), G(3,2), G(3,3)/1.42E-14, 4.42E-14, 5.11E-14/
       DATA G(4,1), G(4,2), G(4,3), G(4,4)/3.76E-15, 1.19E-14, 1.80E-14,
     :      1.34E-14/
       DATA G(5,1), G(5,2), G(5,3), G(5,4)/1.34E-15, 4.28E-15, 6.77E-15,
     :      1.17E-14/
       DATA G(6,1), G(6,2), G(6,3), G(6,4)/5.85E-16, 1.85E-15, 3.17E-15,
     :      8.64E-15/
       DATA G(7,1), G(7,2), G(7,3), G(7,4)/2.90E-16, 91.5E-16, 1.59E-15,
     :      6.24E-15/
       DATA G(8,1), G(8,2), G(8,3), G(8,4)/1.58E-16, 4.97E-16, 8.69E-16,
     :      4.55E-15/
       DATA G(9,1), G(9,2), G(9,3), G(9,4)/9.29E-17, 2.91E-16, 5.10E-16,
     :      3.39E-15/
       DATA G(10,1), G(10,2), G(10,3), G(10,4)/5.78E-17, 1.80E-16,
     :      3.16E-16, 2.58E-15/
       DATA G(11,1), G(11,2), G(11,3), G(11,4)/3.76E-17, 1.17E-16,
     :      2.05E-16, 2.00E-15/
* NL,NU NITROGEN
       DATA NL(1,1), NL(1,2), NL(1,3), NL(1,4)/3, 3, 4, 5/
       DATA NU(1,1), NU(1,2), NU(1,3), NU(1,4)/4, 6, 8, 11/
* NL,NU CARBON
       DATA NL(2,1), NL(2,2), NL(2,3), NL(2,4)/3, 3, 4, 5/
       DATA NU(2,1), NU(2,2), NU(2,3), NU(2,4)/4, 6, 8, 11/
* NL,NU OXYGEN
       DATA NL(3,1), NL(3,2), NL(3,3), NL(3,4)/3, 3, 4, 5/
       DATA NU(3,1), NU(3,2), NU(3,3), NU(3,4)/4, 6, 8, 11/
* NL,NU NEON
       DATA NL(4,1), NL(4,2), NL(4,3), NL(4,4)/3, 3, 4, 5/
       DATA NU(4,1), NU(4,2), NU(4,3), NU(4,4)/4, 6, 8, 11/
* N , N=3
       DATA EL(1,1,3,1), EL(1,1,3,2), EL(1,1,3,3)/33056., 21564.,
     :      12473./
* N , N=4
       DATA EL(1,1,4,1), EL(1,1,4,2), EL(1,1,4,3), EL(1,1,4,4)/13483.,
     :      10352., 6976., 6859./
* N+, N=3
       DATA EL(1,2,3,1), EL(1,2,3,2), EL(1,2,3,3)/89811., 69845.,
     :      51173./
* N+, N=4
       DATA EL(1,2,4,1), EL(1,2,4,2), EL(1,2,4,3), EL(1,2,4,4)/41797.,
     :      35367., 28468., 27480./
* N+, N=5
       DATA EL(1,2,5,1), EL(1,2,5,2), EL(1,2,5,3), EL(1,2,5,4)/24397.,
     :      21457., 18084., 17558./
* N+, N=6
       DATA EL(1,2,6,1), EL(1,2,6,2), EL(1,2,6,3), EL(1,2,6,4)/15976.,
     :      14390., 12496., 12193./
* N2+, N=4
       DATA EL(1,3,4,1), EL(1,3,4,2), EL(1,3,4,3), EL(1,3,4,4)/81621.,
     :      70997., 64937., 62416./
* N2+, N=5
       DATA EL(1,3,5,1), EL(1,3,5,2), EL(1,3,5,3), EL(1,3,5,4)/48992.,
     :      44545., 40755., 39587./
* N2+, N=6
       DATA EL(1,3,6,1), EL(1,3,6,2), EL(1,3,6,3), EL(1,3,6,4)/32879.,
     :      29264., 28173., 27449./
* N2+, N=7
       DATA EL(1,3,7,1), EL(1,3,7,2), EL(1,3,7,3), EL(1,3,7,4)/23515.,
     :      21300., 20620., 20156./
* N2+, N=8
       DATA EL(1,3,8,1), EL(1,3,8,2), EL(1,3,8,3), EL(1,3,8,4)/17649.,
     :      16194., 15742., 15432./
* N3+, N=5
       DATA EL(1,4,5,1), EL(1,4,5,2), EL(1,4,5,3), EL(1,4,5,4)/79573.,
     :      74984., 71698., 70526./
* N3+, N=6
       DATA EL(1,4,6,1), EL(1,4,6,2), EL(1,4,6,3), EL(1,4,6,4)/54287.,
     :      51862., 49625., 48772./
* N3+, N=7
       DATA EL(1,4,7,1), EL(1,4,7,2), EL(1,4,7,3), EL(1,4,7,4)/39887.,
     :      38107., 36358., 35845./
* N3+, N=8
       DATA EL(1,4,8,1), EL(1,4,8,2), EL(1,4,8,3), EL(1,4,8,4)/30122.,
     :      28949., 27786., 27434./
* N3+, N=9
       DATA EL(1,4,9,1), EL(1,4,9,2), EL(1,4,9,3), EL(1,4,9,4)/23549.,
     :      22735., 21923., 21676./
* N3+, N=10
       DATA EL(1,4,10,1), EL(1,4,10,2), EL(1,4,10,3), EL(1,4,10,4)
     :      /18915., 18327., 17738., 17558./
* N3+, N=11
       DATA EL(1,4,11,1), EL(1,4,11,2), EL(1,4,11,3), EL(1,4,11,4)
     :      /15525., 15087., 14646., 14511./
* C , N=3
       DATA EL(2,1,3,1), EL(2,1,3,2), EL(2,1,3,3)/30102., 20210.,
     :      12452./
* C , N=4
       DATA EL(2,1,4,1), EL(2,1,4,2), EL(2,1,4,3), EL(2,1,4,4)/12694.,
     :      9895., 6968., 6859./
* C+, N=3
       DATA EL(2,2,3,1), EL(2,2,3,2), EL(2,2,3,3)/80127., 64933.,
     :      51115./
* C+, N=4
       DATA EL(2,2,4,1), EL(2,2,4,2), EL(2,2,4,3), EL(2,2,4,4)/39431.,
     :      34142., 28541., 27687./
* C+, N=5
       DATA EL(2,2,5,1), EL(2,2,5,2), EL(2,2,5,3), EL(2,2,5,4)/23342.,
     :      20875., 18121., 17558./
* C+, N=6
       DATA EL(2,2,6,1), EL(2,2,6,2), EL(2,2,6,3), EL(2,2,6,4)/15413.,
     :      14069., 12518., 12193./
* C2+, N=4
       DATA EL(2,3,4,1), EL(2,3,4,2), EL(2,3,4,3), EL(2,3,4,4)/76218.,
     :      67962., 64112., 64056./
* C2+, N=5
       DATA EL(2,3,5,1), EL(2,3,5,2), EL(2,3,5,3), EL(2,3,5,4)/46661.,
     :      42250., 40454., 39662./
* C2+, N=6
       DATA EL(2,3,6,1), EL(2,3,6,2), EL(2,3,6,3), EL(2,3,6,4)/31383.,
     :      29176., 27985., 27434./
* C2+, N=7
       DATA EL(2,3,7,1), EL(2,3,7,2), EL(2,3,7,3), EL(2,3,7,4)/22599.,
     :      21264., 20465., 20156./
* C2+, N=8
       DATA EL(2,3,8,1), EL(2,3,8,2), EL(2,3,8,3), EL(2,3,8,4)/17050.,
     :      16234., 15722., 15432./
* C3+, N=5
       DATA EL(2,4,5,1), EL(2,4,5,2), EL(2,4,5,3), EL(2,4,5,4)/74809.,
     :      71317., 70289., 70230./
* C3+, N=6
       DATA EL(2,4,6,1), EL(2,4,6,2), EL(2,4,6,3), EL(2,4,6,4)/51394.,
     :      49400., 48807., 48775./
* C3+, N=7
       DATA EL(2,4,7,1), EL(2,4,7,2), EL(2,4,7,3), EL(2,4,7,4)/37472.,
     :      36228., 35857., 35834./
* C3+, N=8
       DATA EL(2,4,8,1), EL(2,4,8,2), EL(2,4,8,3), EL(2,4,8,4)/28559.,
     :      27705., 27459., 27433./
* C3+, N=9
       DATA EL(2,4,9,1), EL(2,4,9,2), EL(2,4,9,3), EL(2,4,9,4)/22464.,
     :      21867., 21694., 21676./
* C3+, N=10
       DATA EL(2,4,10,1), EL(2,4,10,2), EL(2,4,10,3), EL(2,4,10,4)
     :      /18130., 17696., 17571., 17558./
* C3+, N=11
       DATA EL(2,4,11,1), EL(2,4,11,2), EL(2,4,11,3), EL(2,4,11,4)
     :      /14940., 14615., 14520., 14511./
* O , N=3
       DATA EL(3,1,3,1), EL(3,1,3,2), EL(3,1,3,3)/34934., 22458.,
     :      12392./
* O , N=4
       DATA EL(3,1,4,1), EL(3,1,4,2), EL(3,1,4,3), EL(3,1,4,4)/14080.,
     :      10524., 6942., 6859./
* O+, N=3
       DATA EL(3,2,3,1), EL(3,2,3,2), EL(3,2,3,3)/97155., 74551.,
     :      51196./
* O+, N=4
       DATA EL(3,2,4,1), EL(3,2,4,2), EL(3,2,4,3), EL(3,2,4,4)/44203.,
     :      36593., 28545., 27619./
* O+, N=5
       DATA EL(3,2,5,1), EL(3,2,5,2), EL(3,2,5,3), EL(3,2,5,4)/25463.,
     :      22238., 18123., 17558./
* O+, N=6
       DATA EL(3,2,6,1), EL(3,2,6,2), EL(3,2,6,3), EL(3,2,6,4)/16538.,
     :      14817., 12519., 12193./
* O2+, N=4
       DATA EL(3,3,4,1), EL(3,3,4,2), EL(3,3,4,3), EL(3,3,4,4)/85794.,
     :      74783., 64227., 62500./
* O2+, N=5
       DATA EL(3,3,5,1), EL(3,3,5,2), EL(3,3,5,3), EL(3,3,5,4)/50834.,
     :      45992., 40974., 39903./
* O2+, N=6
       DATA EL(3,3,6,1), EL(3,3,6,2), EL(3,3,6,3), EL(3,3,6,4)/33769.,
     :      31114., 28276., 27434./
* O2+, N=7
       DATA EL(3,3,7,1), EL(3,3,7,2), EL(3,3,7,3), EL(3,3,7,4)/24052.,
     :      22441., 20684., 20156./
* O2+, N=8
       DATA EL(3,3,8,1), EL(3,3,8,2), EL(3,3,8,3), EL(3,3,8,4)/17997.,
     :      16947., 15785., 15432./
* O3+, N=5
       DATA EL(3,4,5,1), EL(3,4,5,2), EL(3,4,5,3), EL(3,4,5,4)/85029.,
     :      78214., 72363., 70939./
* O3+, N=6
       DATA EL(3,4,6,1), EL(3,4,6,2), EL(3,4,6,3), EL(3,4,6,4)/57125.,
     :      53328., 50024., 48772./
* O3+, N=7
       DATA EL(3,4,7,1), EL(3,4,7,2), EL(3,4,7,3), EL(3,4,7,4)/41000.,
     :      38673., 36623., 35832./
* O3+, N=8
       DATA EL(3,4,8,1), EL(3,4,8,2), EL(3,4,8,3), EL(3,4,8,4)/30849.,
     :      29323., 27963., 27434./
* O3+, N=9
       DATA EL(3,4,9,1), EL(3,4,9,2), EL(3,4,9,3), EL(3,4,9,4)/24051.,
     :      22996., 22047., 21676./
* O3+, N=10
       DATA EL(3,4,10,1), EL(3,4,10,2), EL(3,4,10,3), EL(3,4,10,4)
     :      /19275., 18515., 17828., 17558./
* O3+, N=11
       DATA EL(3,4,11,1), EL(3,4,11,2), EL(3,4,11,3), EL(3,4,11,4)
     :      /15792., 15227., 14713., 14511./
* NE , N=3
       DATA EL(4,1,3,1), EL(4,1,3,2), EL(4,1,3,3)/39517., 23994.,
     :      12303./
* NE , N=4
       DATA EL(4,1,4,1), EL(4,1,4,2), EL(4,1,4,3), EL(4,1,4,4)/15242.,
     :      11012., 6914., 7142./
* NE+, N=3
       DATA EL(4,2,3,1), EL(4,2,3,2), EL(4,2,3,3)/110291., 81369.,
     :      50967./
* NE+, N=4
       DATA EL(4,2,4,1), EL(4,2,4,2), EL(4,2,4,3), EL(4,2,4,4)/48686.,
     :      39761., 28352., 27434./
* NE+, N=5
       DATA EL(4,2,5,1), EL(4,2,5,2), EL(4,2,5,3), EL(4,2,5,4)/27399.,
     :      23492., 18026., 17558./
* NE+, N=6
       DATA EL(4,2,6,1), EL(4,2,6,2), EL(4,2,6,3), EL(4,2,6,4)/17540.,
     :      15494., 12463., 12193./
* NE2+, N=4
       DATA EL(4,3,4,1), EL(4,3,4,2), EL(4,3,4,3), EL(4,3,4,4)/94472.,
     :      81309., 64125., 61727./
* NE2+, N=5
       DATA EL(4,3,5,1), EL(4,3,5,2), EL(4,3,5,3), EL(4,3,5,4)/55111.,
     :      49094., 40726., 39505./
* NE2+, N=6
       DATA EL(4,3,6,1), EL(4,3,6,2), EL(4,3,6,3), EL(4,3,6,4)/36062.,
     :      32825., 28138., 27434./
* NE2+, N=7
       DATA EL(4,3,7,1), EL(4,3,7,2), EL(4,3,7,3), EL(4,3,7,4)/25419.,
     :      23483., 20598., 20156./
* NE2+, N=8
       DATA EL(4,3,8,1), EL(4,3,8,2), EL(4,3,8,3), EL(4,3,8,4)/18877.,
     :      17627., 15727., 15432./
* NE3+, N=5
       DATA EL(4,4,5,1), EL(4,4,5,2), EL(4,4,5,3), EL(4,4,5,4)/89387.,
     :      85297., 71369., 70232./
* NE3+, N=6
       DATA EL(4,4,6,1), EL(4,4,6,2), EL(4,4,6,3), EL(4,4,6,4)/59505.,
     :      57270., 49429., 48772./
* NE3+, N=7
       DATA EL(4,4,7,1), EL(4,4,7,2), EL(4,4,7,3), EL(4,4,7,4)/42441.,
     :      41088., 36245., 35832./
* NE3+, N=8
       DATA EL(4,4,8,1), EL(4,4,8,2), EL(4,4,8,3), EL(4,4,8,4)/31788.,
     :      30908., 27711., 27433./
* NE3+N N=9
       DATA EL(4,4,9,1), EL(4,4,9,2), EL(4,4,9,3), EL(4,4,9,4)/24695.,
     :      24091., 21870., 21676./
* NE3+, N=10
       DATA EL(4,4,10,1), EL(4,4,10,2), EL(4,4,10,3), EL(4,4,10,4)
     :      /19736., 19304., 17699., 17558./
* NE3+, N=11
       DATA EL(4,4,11,1), EL(4,4,11,2), EL(4,4,11,3), EL(4,4,11,4)
     :      /16134., 15814., 14617., 14511./

       FNEB = 0.
       X = 1.E8/XS
       IF (XS.GT.8201.) GOTO 300
       GM = 0.
*  ION LOOP
       DO 100 I = 1, 4
*  CHARGE LOOP
          DO 50 IZ = 1, 4
             N1 = NL(I,IZ)
             N2 = NU(I,IZ)
             IF (NL(I,IZ).NE.0) THEN
                IF (FZ(I,IZ).NE.0.) THEN
*  N LOOP
                   DO 5 N = N1, N2
*  L LOOP
                      LM = N
                      IF (N.GT.4) LM = 4
                      DO 2 LP = 1, LM
                         L = LP - 1
                         ELIM = EL(I,IZ,N,LP)
                         FLIM = 1.E8/ELIM
                         IF (XS.LE.FLIM) THEN
                            XE = 1.4388*(X-ELIM)/(1.E4*TZ(IZ))
                            XEX = 0.
                            IF (XE.LE.100.) THEN
                               XEX = EXP(-XE)
                            ENDIF
                            GMM = G(N,LP)*IZ*IZ*IZ*IZ*XEX*FZ(I,IZ)
     :                            /(SQRT(TZ(IZ)**3))
                            GM = GM + GMM
                         ENDIF
    2                 CONTINUE
    5              CONTINUE
                ENDIF
             ENDIF
   50     CONTINUE
  100  CONTINUE
       FNEB = 1.982E-08*GM*CH/(XS*XS)
       DO 200 IZ = 1, 4
          FNEB = FNEB + DMS(IZ)*EXP(-14390./(TZ(IZ)*XS))/(XS*XS)
  200  CONTINUE

  300  CONTINUE

       END
