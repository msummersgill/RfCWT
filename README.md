# R Interface to the fast Continuous Wavelet Transform (fCWT)


This package allows R users to leverage a high performance implementation C++ code implementation of the continous wavelet transform by  by Lukas Arts and Egon van den Broek released in the repository [fastlib/fCWT](https://github.com/fastlib/fCWT).


> *The spectral analysis of signals is currently either dominated by the speed-accuracy trade-off or ignores a signal's often non-stationary character. Here we introduce an open-source algorithm to calculate the fast continuous wavelet transform (fCWT). The parallel environment of fCWT separates scale-independent and scale-dependent operations, while utilizing optimized fast Fourier transforms that exploit downsampled wavelets. fCWT is benchmarked for speed against eight competitive algorithms, tested on noise resistance and validated on synthetic electroencephalography and in vivo extracellular local field potential data. fCWT is shown to have the accuracy of CWT, to have 100 times higher spectral resolution than algorithms equal in speed, to be 122 times and 34 times faster than the reference and fastest state-of-the-art implementations and we demonstrate its real-time performance, as confirmed by the real-time analysis ratio. fCWT provides an improved balance between speed and accuracy, which enables real-time, wide-band, high-quality, time-frequency analysis of non-stationary noisy signals.*
>
> --- Arts, L.P.A., van den Broek, E.L. The fast continuous wavelet transformation (fCWT) for real-time, high-quality, noise-resistant time-frequency analysis. Nat Comput Sci 2, 47-58 (2022). <https://doi.org/10.1038/s43588-021-00183-z>

## Installation

### FFTW dependency

This package relies on [Fastest Fourier Transform in the West (FFTW)](http://www.fftw.org/) for the numerous FFT operations executed. FFTW is not bundled as a part of this package, and must be installed separately.

For optimal performance, FFTW needs to be configured to use OpenMP for multi-threading and 256-bit vector instructions (e.g., AVX). Since  binaries obtained via `brew` or `apt-get install libfftw3-dev` generally don't have AVX enabled.

In addition, using the [FFTW `fftwf-wissdom` utility](https://www.fftw.org/fftw-wisdom.1.html) to pre-generate plans that can be used system wide can improve performance at runtime. This step will likely take hours to complete, but only needs to be run a single time unless the system configuration is changed.

``` bash
wget https://fftw.org/pub/fftw/fftw-3.3.10.tar.gz
tar -zxvf fftw-3.3.10.tar.gz
cd fftw-3.3.10

./configure CC=gcc             \
            --prefix=/usr      \
            --enable-shared    \
            --enable-threads   \
            --enable-float     \
            --enable-openmp    \
            --enable-sse2      \
            --enable-avx       \
            --enable-avx2      \
            CFLAGS="-fopenmp"
sudo make
sudo make install

fftwf-wisdom -v -c -o wisdomf

sudo mkdir /etc/fftw
sudo mv wisdomf /etc/fftw/
```

### Installing the Package


This package has not been submitted to CRAN. For now, the `remotes` package can be used to install directly from this repository, or you can clone and install from local source yourself.

```r
remotes::install_github("https://github.com/msummersgill/RfCWT.git")
```

In the event the package fails to build out of the box, cloning and building from source gives an opportunity to adjust the `Makevars` file as needed.

```bash
git clone https://github.com/msummersgill/RfCWT.git
cd RfCWT
R CMD INSTALL --preclean --no-multiarch --with-keep.source RfCWT
```


In addition, 

```bash
ldd /home/matthew14786/R/x86_64-pc-linux-gnu-library/4.2/RfCWT/libs/RfCWT.so

        linux-vdso.so.1 (0x00007ffff2f9f000)
        liblapack.so => /usr/lib/x86_64-linux-gnu/liblapack.so (0x00007f69a6911000)
        libfftw3f.so.3 => /usr/lib/libfftw3f.so.3 (0x00007f69a5e8d000)
        libR.so => /usr/lib/libR.so (0x00007f69a59f6000)
        libstdc++.so.6 => /usr/lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007f69a5814000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f69a56c5000)
        libgomp.so.1 => /usr/lib/x86_64-linux-gnu/libgomp.so.1 (0x00007f69a5683000)
        libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f69a5666000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f69a5474000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f69a546e000)
        libreadline.so.8 => /lib/x86_64-linux-gnu/libreadline.so.8 (0x00007f69a541e000)
        libpcre.so.3 => /lib/x86_64-linux-gnu/libpcre.so.3 (0x00007f69a53ab000)
        liblzma.so.5 => /lib/x86_64-linux-gnu/liblzma.so.5 (0x00007f69a5382000)
        libbz2.so.1.0 => /lib/x86_64-linux-gnu/libbz2.so.1.0 (0x00007f69a536d000)
        libz.so.1 => /lib/x86_64-linux-gnu/libz.so.1 (0x00007f69a5351000)
        libicuuc.so.66 => /usr/lib/x86_64-linux-gnu/libicuuc.so.66 (0x00007f69a516b000)
        libicui18n.so.66 => /usr/lib/x86_64-linux-gnu/libicui18n.so.66 (0x00007f69a4e6c000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f69a4e49000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f69a7020000)
        libtinfo.so.6 => /lib/x86_64-linux-gnu/libtinfo.so.6 (0x00007f69a4e17000)
        libicudata.so.66 => /usr/lib/x86_64-linux-gnu/libicudata.so.66 (0x00007f69a3356000)


```
#### Makevars

```
CXX_STD = CXX17
PKG_CXXFLAGS = $(SHLIB_OPENMP_CXXFLAGS) -mavx -O3
## This path should work if the desired installation of FFTW is picked up first on the library path
PKG_LIBS = $(SHLIB_OPENMP_CFLAGS) $(LAPACK_LIBS) $(BLAS_LIBS) $(FLIBS) -lfftw3f 

## Hard code path for some local issues I had with an old FFTW installation being picked up
#PKG_LIBS = $(SHLIB_OPENMP_CFLAGS) $(LAPACK_LIBS) $(BLAS_LIBS) $(FLIBS) /usr/lib/libfftw3f.a

```


## Known Issues

+ Execution speed still falls short of expectations, but drastically exceeds other R implementations
+ FFTW plans generated, but not used after generation
