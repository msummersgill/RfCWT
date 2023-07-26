#include <Rcpp.h>
#include <iostream>
#include <vector>
#include <math.h>
#include "fcwt.h"
using namespace Rcpp;

// [[Rcpp::export]]
Rcpp::List fCWT(std::vector<float> x,
                float fn = 360,
                float f0 = 0.001953125,
                float f1 = 0.5,
                float fs = 1,
                std::string mother_wavelet = "MORLET",
                int nthreads = 1,
                std::string optimisation_flags = "ESTIMATE",
                bool optimize = false) {
  
  int n = x.size(); //signal length
  float twopi = 2*PI;
  
  //output: n x scales
  std::vector<complex<float>> tfm(n*fn);
  
  //Create a wavelet object
  Wavelet *wavelet;
  if (mother_wavelet == "MORLET") {
    //Initialize a Morlet wavelet having sigma=2.0;
    Morlet morl(2.0f);
    wavelet = &morl;
  } else {
    throw std::runtime_error("Invalid mother_wavelet. Try 'MORLET'");
  }
  
  //Create the continuous wavelet transform object
  //constructor(wavelet, nthreads, optplan)
  //
  //Arguments
  //wavelet   - pointer to wavelet object
  //nthreads  - number of threads to use
  //optplan   - use FFTW optimization plans if true
  //normalization - take extra time to normalize time-frequency matrix
  FCWT fcwt(wavelet, nthreads, optimize, false);

  if(optimize) fcwt.create_FFT_optimization_plan(n,optimisation_flags);
  //Generate frequencies
  //constructor(wavelet, dist, fs, f0, f1, fn)
  //
  //Arguments
  //wavelet   - pointer to wavelet object
  //dist      - FCWT_LOGSCALES | FCWT_LINFREQS for logarithmic or linear distribution frequency range
  //fs        - sample frequency
  //f0        - beginning of frequency range
  //f1        - end of frequency range
  //fn        - number of wavelets to generate across frequency range
  Scales scs(wavelet, FCWT_LINFREQS, fs, f0, f1, fn);

  //Perform a CWT
  //cwt(input, length, output, scales)
  //
  //Arguments:
  //input     - floating pointer to input array
  //length    - integer signal length
  //output    - floating pointer to output array
  //scales    - pointer to scales object
  fcwt.cwt(&x[0], n, &tfm[0], &scs);
  ComplexVector scalogram = wrap(tfm);
  scalogram.attr("dim") = Dimension(n, fn);
  
  return Rcpp::List::create(Rcpp::Named("signal")=x,
                            Rcpp::Named("scalogram")=scalogram);
}
