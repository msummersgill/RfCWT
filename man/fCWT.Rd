% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{fCWT}
\alias{fCWT}
\title{Executes a continous wavelet transform on an input signal}
\arguments{
\item{x}{Input signal}

\item{fn}{Number of Frequencies}

\item{f0}{Low end of the frequency range}

\item{f1}{High End of the frequency range}

\item{fs}{Sample rate of input signal}

\item{nthreads}{Number of threads to be used for openmp multithreading}

\item{optimize}{Whether FFTW should attempt to create an optimized plan prior to starting}

\item{dist}{Distribution of frequency bands across the range. Should be one of "FCWT_LINSCALES","FCWT_LOGSCALES", or "FCWT_LINFREQS"}

\item{normalization}{Whether or not the output scalogram should be normalized from range 0-1}

\item{bandwidth}{Frequency bandwidth of the mother wavelet to be used}
}
\value{
List object with a complex matrix scalogram and the frequencies associated with each band
}
\description{
Executes a continous wavelet transform on an input signal
}
