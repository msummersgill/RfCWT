#include <Rcpp.h>
#include <iostream>
#include <vector>
#include <math.h>
#include "fcwt.h"
using namespace Rcpp;

SCALETYPE convert(std::string x) {
  if(x == "FCWT_LINSCALES") return FCWT_LINSCALES;
  else if(x == "FCWT_LOGSCALES") return FCWT_LOGSCALES;
  else if(x == "FCWT_LINFREQS") return FCWT_LINFREQS;
  else throw std::runtime_error("Invalid vlue for 'dist'. Try 'FCWT_LOGSCALES' or FCWT_LINFREQS'");
}

//' Executes a continous wavelet transform on an input signal
//'
//' @name fCWT
//' @param x Input signal
//' @param fn Number of Frequencies
//' @param f0 Low end of the frequency range
//' @param f1 High End of the frequency range
//' @param fs Sample rate of input signal
//' @param nthreads Number of threads to be used for openmp multithreading 
//' @param optimize Whether FFTW should attempt to create an optimized plan prior to starting 
//' @param dist Distribution of frequency bands across the range. Should be one of "FCWT_LINSCALES","FCWT_LOGSCALES", or "FCWT_LINFREQS"
//' @param normalization Whether or not the output scalogram should be normalized from range 0-1
//' @param bandwidth Frequency bandwidth of the mother wavelet to be used
//' @param newplan Set to `TRUE` to force a new plan even if one exists
//' @return List object with a complex matrix scalogram and the frequencies associated with each band

// [[Rcpp::export]]
Rcpp::List fCWT(std::vector<float> x,
                int fn = 100,
                float f0 = 0.001953125,
                float f1 = 0.5,
                float fs = 1,
                int nthreads = 1,
                bool optimize = false,
                std::string flags = "FFTW_MEASURE",
                std::string dist = "FCWT_LINFREQS",
                bool normalization = false,
                float bandwidth = 2.0,
                bool newplan = false) {
  
  int n = x.size(); //signal length

  //output: n x scales
  std::vector<complex<float>> tfm(n*fn);
  
  //Create a wavelet object
  Wavelet *wavelet;
  //Initialize a Morlet wavelet having sigma=2.0;
  Morlet morl(bandwidth);
  wavelet = &morl;
  
  //Create the continuous wavelet transform object
  //constructor(wavelet, nthreads, optplan)
  //
  //Arguments
  //wavelet   - pointer to wavelet object
  //nthreads  - number of threads to use
  //optplan   - use FFTW optimization plans if true
  //normalization - take extra time to normalize time-frequency matrix
  FCWT fcwt(wavelet, nthreads, optimize, normalization);

  // TODO: new method "check_FFT_optimization_plan" isn't working like I'd hoped it would.
  // Adding in a manual override for the user to specify that a plan already exists here
  //if(optimize && newplan) fcwt.create_FFT_optimization_plan(n,flags);
  if(optimize){
    if(fcwt.check_FFT_optimization_plan(n) || newplan) fcwt.create_FFT_optimization_plan(n,flags);
  }
  
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
  Scales scs(wavelet, convert(dist), fs, f0, f1, fn);

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
  
  // Extract frequencies associated with each scale
  float freqs[fn];
  scs.getFrequencies(freqs,fn);
  // Convert to a vector
  NumericVector outfreqs = NumericVector(freqs,freqs+sizeof(freqs)/sizeof(*freqs));
  
  //NumericVector scales2 = wrap(scales);
  return Rcpp::List::create(Rcpp::Named("scalogram")=scalogram,
                           Rcpp::Named("freqs")=outfreqs);
  
}

