# R Interface to the fast Continuous Wavelet Transform (fCWT)


This package allows R users to leverage a high performance implementation C++ code implementation of the continous wavelet transform by  by Lukas Arts and Egon van den Broek released in the repository [fastlib/fCWT](https://github.com/fastlib/fCWT).


> *The spectral analysis of signals is currently either dominated by the speed-accuracy trade-off or ignores a signal's often non-stationary character. Here we introduce an open-source algorithm to calculate the fast continuous wavelet transform (fCWT). The parallel environment of fCWT separates scale-independent and scale-dependent operations, while utilizing optimized fast Fourier transforms that exploit downsampled wavelets. fCWT is benchmarked for speed against eight competitive algorithms, tested on noise resistance and validated on synthetic electroencephalography and in vivo extracellular local field potential data. fCWT is shown to have the accuracy of CWT, to have 100 times higher spectral resolution than algorithms equal in speed, to be 122 times and 34 times faster than the reference and fastest state-of-the-art implementations and we demonstrate its real-time performance, as confirmed by the real-time analysis ratio. fCWT provides an improved balance between speed and accuracy, which enables real-time, wide-band, high-quality, time-frequency analysis of non-stationary noisy signals.*
>
> --- Arts, L.P.A., van den Broek, E.L. The fast continuous wavelet transformation (fCWT) for real-time, high-quality, noise-resistant time-frequency analysis. Nat Comput Sci 2, 47-58 (2022). <https://doi.org/10.1038/s43588-021-00183-z>

## Installation

### FFTW Installation

This package relies on [Fastest Fourier Transform in the West (FFTW)](http://www.fftw.org/) for the numerous FFT operations executed. FFTW is not bundled as a part of this package, and must be installed separately.

For optimal performance, FFTW needs to be configured to use OpenMP for multi-threading and 256-bit vector instructions (e.g., AVX). Since binaries obtained via `brew` or `apt-get install libfftw3-dev` generally don't have AVX enabled.


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
instamake
sudo make install

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
R CMD INSTALL . --preclean --no-multiarch --with-keep.source
```


### Intel MKL Compatibility

When the package is compiled using the Intel MKL library, plan saving and loading is incompatible with designed behavior by the original `fCWT` authors. To avoid wasted time on execution, `/src/MakeVars` requires modification prior to compilation and installation. See issue [RfCWT/1](https://github.com/msummersgill/RfCWT/issues/1) for details.


## Benchmarking

Compared to other R libraries, only [`RcppWavelet`](https://github.com/msummersgill/RcppWavelet) comes close to the performance of `RfCWT` on larger data sizes.

```r
sizefactor = 4
f0 = 1.0
f1 = 32
fs = 100.0
no = 5
bpo = 32 * sizefactor
bpo2 = 28 * sizefactor
nc = 28L
n = as.numeric(seq_len(1e3))
x = sin(2*pi * (n + 0.002 * (n-256)^2 ) / 16)
xmat <- matrix(cbind(n/fs,x),ncol = 2)
xdf <- data.frame(n,x)

print(paste0("Small: N = 10,000 x ",bpo * no, " Scales"))
microbenchmark::microbenchmark(
  WaveletComp = WaveletComp::analyze.wavelet(xdf,my.series = "x",dt = 1/fs,dj = 1/(bpo),lowerPeriod = 1/f1, upperPeriod = 1/f0, n.sim = 0, make.pval = F, loess.span = 0, verbose = F),
  RWave = Rwave::cwt(x, noctave=no, nvoice=bpo, plot = F, twoD = T),
  biwavelet = biwavelet::wt(xmat,dt = 1/fs,J1 = bpo * no - 1L, do.sig = F),
  RcppWavelet = RcppWavelet::analyze(x,bands_per_octave = bpo2,frequency_min = f0,frequency_max = f1,samplerate_hz = fs,mother_wavelet = "MORLET",morlet_carrier = 2 * pi,cores = 1L),
  RfCWT = RfCWT::fCWT(x, f0 = f0,f1 = f1,nthreads =  1L,fn =  bpo * no,fs = fs,optimize = F),
  times = 1,unit = "seconds"
)

## Equivalent code for Medium and Large omitted for the sake of brevity.
## For Medium and Large Sizes, 28 cores were used by RcppWavelet and RfCWT.
## 

```
```
[1] "Small: N = 10,000 x 640 Scales"
Unit: seconds
        expr       min        lq      mean    median        uq       max neval
 WaveletComp 0.5358071 0.5358071 0.5358071 0.5358071 0.5358071 0.5358071     1
       RWave 0.3057232 0.3057232 0.3057232 0.3057232 0.3057232 0.3057232     1
   biwavelet 1.5347819 1.5347819 1.5347819 1.5347819 1.5347819 1.5347819     1
 RcppWavelet 0.2228511 0.2228511 0.2228511 0.2228511 0.2228511 0.2228511     1
       RfCWT 0.0317194 0.0317194 0.0317194 0.0317194 0.0317194 0.0317194     1

[1] "Medium: N = 100,000 x 640 Scales"
Unit: seconds
        expr       min        lq      mean    median        uq       max neval
 WaveletComp 79.832644 79.832644 79.832644 79.832644 79.832644 79.832644     1
       RWave 40.555053 40.555053 40.555053 40.555053 40.555053 40.555053     1
   biwavelet 45.054479 45.054479 45.054479 45.054479 45.054479 45.054479     1
 RcppWavelet  2.288625  2.288625  2.288625  2.288625  2.288625  2.288625     1
       RfCWT  4.151020  4.151020  4.151020  4.151020  4.151020  4.151020     1

[1] "Large: N = 1,000,000 x 640 Scales"
Unit: seconds
        expr      min       lq     mean   median       uq      max neval
 RcppWavelet 25.03916 25.03916 25.03916 25.03916 25.03916 25.03916     1
       RfCWT 14.30784 14.30784 14.30784 14.30784 14.30784 14.30784     1
```


Comparing to the `pycwt` port, results are somewhat slower, but exceed performance of other wavelet libraries in R. Issue [RfCWT/3](https://github.com/msummersgill/RfCWT/issues/3) details why performance is slower - primarily, time spent allocating memory and then converting the complex float matrix to a numeric type compatible with R.

### Compiled with Intel MKL _(No Planning)_

```r
n_1e4 <- rnorm(1e4)
n_1e5 <- rnorm(1e5)
opt <- FALSE
microbenchmark::microbenchmark(
  `10k-300`   = RfCWT::fCWT(n_1e4, f0 = 1,f1 = 101,nthreads = 8L,fn =  300,fs = 100,optimize = opt),
  `100k-300`  = RfCWT::fCWT(n_1e5, f0 = 1,f1 = 101,nthreads = 8L,fn =  300,fs = 100,optimize = opt),
  `10k-3000`  = RfCWT::fCWT(n_1e4, f0 = 1,f1 = 101,nthreads = 8L,fn = 3000,fs = 100,optimize = opt),
  `100k-3000` = RfCWT::fCWT(n_1e5, f0 = 1,f1 = 101,nthreads = 8L,fn = 3000,fs = 100,optimize = opt),
  times = 5,unit = "seconds"
) 
```
```
Unit: seconds
      expr        min        lq      mean     median         uq       max neval
   10k-300 0.05968817 0.0601284 0.1378268 0.06224495 0.06265028 0.4444222     5
  100k-300 0.72586780 0.7325001 0.7433433 0.74075451 0.74261565 0.7749782     5
  10k-3000 0.73934641 0.7404694 1.7315075 1.33930748 1.57047484 4.2679392     5
 100k-3000 7.10608957 7.5964948 7.6111734 7.64778173 7.79255553 7.9129453     5
```

### Compiled with Atlas BLAS/LAPACK

```r
Length_1e4 <- rnorm(1e4)
Length_1e5 <- rnorm(1e5)
opt <- TRUE
microbenchmark::microbenchmark(
  `10k-300`   = RfCWT::fCWT(Length_1e4, f0 = 1,f1 = 101,nthreads = 8L,fn =  300,fs = 100,optimize = opt),
  `100k-300`  = RfCWT::fCWT(Length_1e5, f0 = 1,f1 = 101,nthreads = 8L,fn =  300,fs = 100,optimize = opt),
  `10k-3000`  = RfCWT::fCWT(Length_1e4, f0 = 1,f1 = 101,nthreads = 8L,fn = 3000,fs = 100,optimize = opt),
  `100k-3000` = RfCWT::fCWT(Length_1e5, f0 = 1,f1 = 101,nthreads = 8L,fn = 3000,fs = 100,optimize = opt),
  times = 5,unit = "seconds"
) 
```

```
Unit: seconds
      expr        min         lq       mean     median         uq        max neval
   10k-300  0.1051914  0.1053895  0.1061431  0.1060205  0.1069113  0.1072026     5
  100k-300  1.0243758  1.0266802  1.1697846  1.0270924  1.0273088  1.7434659     5
  10k-3000  1.0436445  1.0446397  1.2136461  1.1063655  1.2617259  1.6118550     5
 100k-3000  9.8671865 10.0237925 10.0578129 10.0310547 10.1542103 10.2128206     5
```

For reference, executing the [pycwt benchmark notebook](github.com/fastlib/fCWT/blob/main/benchmark.ipynb) on my machine and using 8 threads _(Ubuntu 20.04 hosted by VMWare with Intel(R) Xeon(R) CPU E5-2695 v3 @ 2.30GHz - not exactly a high performance computing environment)_ gives the following results.


```python
## Majority of benchmark code removed for the sake of brevity

#10k-300
timeit.timeit('fcwt_obj.cwt(sig_10k, scales300, output_10k_300)', number=10, globals=globals())
#100k-300
timeit.timeit('fcwt_obj.cwt(sig_100k, scales300, output_100k_300)', number=10, globals=globals())
#10k-3000
timeit.timeit('fcwt_obj.cwt(sig_10k, scales3000, output_10k_3000)', number=10, globals=globals())
#100k-3000
timeit.timeit('fcwt_obj.cwt(sig_100k, scales3000, output_100k_3000)', number=10, globals=globals())
```

```
10k-300:  0.049193423986434934 seconds
100k-300:  0.3959102466702461 seconds
10k-3000:  0.437694988399744 seconds
100k-3000:  3.7881476119160653 seconds
```


### Troubleshooting FFTW Linking

If your unsure whether a prior installation of FFTW is getting linked, checking with `ldd` may provide some insight as to whether your intended result was attained.

```
ldd /home/username/R/x86_64-pc-linux-gnu-library/4.2/RfCWT/libs/RfCWT.so

        linux-vdso.so.1 (0x00007ffe57fd3000)
        libfftw3f.so.3 => /usr/lib/libfftw3f.so.3 (0x00007fe51b233000)
        libfftw3f_omp.so.3 => /usr/lib/libfftw3f_omp.so.3 (0x00007fe51b228000)
        libR.so => /usr/lib/libR.so (0x00007fe51ad91000)
        libstdc++.so.6 => /usr/lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007fe51abaf000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fe51aa60000)
        libgomp.so.1 => /usr/lib/x86_64-linux-gnu/libgomp.so.1 (0x00007fe51aa1e000)
        libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007fe51aa01000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fe51a80f000)
        libblas.so.3 => /usr/lib/x86_64-linux-gnu/libblas.so.3 (0x00007fe51a12f000)
        libreadline.so.8 => /lib/x86_64-linux-gnu/libreadline.so.8 (0x00007fe51a0df000)
        libpcre.so.3 => /lib/x86_64-linux-gnu/libpcre.so.3 (0x00007fe51a06c000)
        liblzma.so.5 => /lib/x86_64-linux-gnu/liblzma.so.5 (0x00007fe51a043000)
        libbz2.so.1.0 => /lib/x86_64-linux-gnu/libbz2.so.1.0 (0x00007fe51a02e000)
        libz.so.1 => /lib/x86_64-linux-gnu/libz.so.1 (0x00007fe51a012000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fe51a00c000)
        libicuuc.so.66 => /usr/lib/x86_64-linux-gnu/libicuuc.so.66 (0x00007fe519e26000)
        libicui18n.so.66 => /usr/lib/x86_64-linux-gnu/libicui18n.so.66 (0x00007fe519b27000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fe519b04000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fe51bce6000)
        libtinfo.so.6 => /lib/x86_64-linux-gnu/libtinfo.so.6 (0x00007fe519ad2000)
        libicudata.so.66 => /usr/lib/x86_64-linux-gnu/libicudata.so.66 (0x00007fe518011000)

```
