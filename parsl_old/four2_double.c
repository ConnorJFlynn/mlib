#include <stdio.h>

#include <math.h>

#define SWAP(a,b) tempr=(a);(a)=(b);(b)=tempr

#define PI 3.1415926535897932

/** FFT Routine from Numberical Recipies
 @param data
 @param nn  - number of points in the FFT
 @param isign
 */
#include "four1_double.h"

void four1(float * data,int nn,int isign)
{
	int n;
	int mmax;
	int m;
	int j;
	int istep;
	int i;
	double wtemp;
	double wr;
	double wpr;
	double wpi;
	double wi;
	double theta;
	float tempr;
	float tempi;

	n= (nn * 2); // n << 1 -- which is nn * 2

	j=1;

	for (i=1; i<n; i+=2)

	{
		if (j > i)
		{
			SWAP(data[j],data[i]);
			SWAP(data[j+1],data[i+1]);
		}
		m = nn;  // n >> 1 -- which is (nn * 2 / 2)
		while (m >= 2 && j > m)
		{
			j -= m;
			m >>= 1;
		}
		j += m;
	}
	mmax=2;

	while (n > mmax)
	{
		istep=2*mmax;
		theta=( 2 * PI) /(isign*mmax);
		wtemp=sin(0.5*theta);
		wpr = -2.0*wtemp*wtemp;   // -
		wpi=sin(theta);
		wr=1.0;
		wi=0.0;
		for (m=1;m<mmax;m+=2)
		{
			for (i=m;i<=n;i+=istep)
			{
				j=i+mmax;
				tempr=wr*data[j]-wi*data[j+1];
				tempi=wr*data[j+1]+wi*data[j];
				data[j]=data[i]-tempr;
				data[j+1]=data[i+1]-tempi;
				data[i] += tempr;
				data[i+1] += tempi;
			}
			wr=(wtemp=wr)*wpr-wi*wpi+wr;
			wi=wi*wpr+wtemp*wpi+wi;
		}
		mmax=istep;
	}
}

#undef SWAP
