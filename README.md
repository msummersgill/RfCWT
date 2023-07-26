# R Interface to the fast Continuous Wavelet Transform (fCWT)


This package allows R users to leverage a high performance implementation C++ code implementation of the continous wavelet transform by  by Lukas Arts and Egon van den Broek released in the repository [fastlib/fCWT](https://github.com/fastlib/fCWT).


> *The spectral analysis of signals is currently either dominated by the speed-accuracy trade-off or ignores a signal's often non-stationary character. Here we introduce an open-source algorithm to calculate the fast continuous wavelet transform (fCWT). The parallel environment of fCWT separates scale-independent and scale-dependent operations, while utilizing optimized fast Fourier transforms that exploit downsampled wavelets. fCWT is benchmarked for speed against eight competitive algorithms, tested on noise resistance and validated on synthetic electroencephalography and in vivo extracellular local field potential data. fCWT is shown to have the accuracy of CWT, to have 100 times higher spectral resolution than algorithms equal in speed, to be 122 times and 34 times faster than the reference and fastest state-of-the-art implementations and we demonstrate its real-time performance, as confirmed by the real-time analysis ratio. fCWT provides an improved balance between speed and accuracy, which enables real-time, wide-band, high-quality, time-frequency analysis of non-stationary noisy signals.*
>
> --- Arts, L.P.A., van den Broek, E.L. The fast continuous wavelet transformation (fCWT) for real-time, high-quality, noise-resistant time-frequency analysis. Nat Comput Sci 2, 47-58 (2022). <https://doi.org/10.1038/s43588-021-00183-z>

## Installation

### FFTW dependency

This package relies on [Fastest Fourier Transform in the West (FFTW)](http://www.fftw.org/) for the numerous FFT operations executed. FFTW is not bundled as a part of this package, and must be installed separately.

For optimal performance, FFTW needs to be configured to use OpenMP for multi-threading and 256-bit vector instructions (e.g., AVX). Since  binaries obtained via `brew` or `apt-get install libfftw3-dev` generally don't have AVX enabled.

``` bash
wget https://fftw.org/pub/fftw/fftw-3.3.10.tar.gz
tar -zxvf fftw-3.3.10.tar.gz
cd fftw-3.3.10
./configure CC=gfortran --enable-float=TRUE --enable-openmp --enable-avx=TRUE --enable-avx2=TRUE CFLAGS="-fopenmp"
make
make install
```

### Installing from Github

This package has not been submitted to CRAN. For now, the `remotes` package can be used to install directly from this repository, or you can clone and install from local source yourself.

```r
remotes::install_github(" https://github.com/msummersgill/RfCWT.git")
```

## Known Issues

+ FFTW plans are not generated as expected.
