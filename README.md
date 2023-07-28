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
sudo make
sudo make install

```

### FFTW Wisdom Generation

In addition, using the [`fftwf-wisdom`](https://www.fftw.org/fftw-wisdom.1.html) utility to pre-generate plans that can be used system wide can improve performance at run time. Generating the full canonical set of cases using `fftw-wisdom -v -c -o wisdom` takes many hours, but for the purposes of this library, we only need a subset of plans.

`RfCWT::GenerateWisdom()` is provided as a convenience function to generate the `fftwf-wisdom` commands for a defined set of threads. By default, the commands are printed to the console output, but specifying `Execute = TRUE` will use `system(..., wait = FALSE)` to execute them directly in parallel. Upon completion, the files can all be combined using the output of `RfCWT::CombineWisdom()`.

```r
RfCWT::GenerateWisdom(Threads = c(2L,4L,8L,16L), Execute = FALSE)
RfCWT::CombineWisdom(Threads = c(2L,4L,8L,16L), Execute = FALSE) 

```
Output of these commands is as follows. Upon completion, the user will need to generate the default directory for FFTW wisdom - `/etc/fftw` - if it does not exist, and then copy the output to this location.

```
fftwf-wisdom -p -v -T 1 -o wisdomf1 rof2048 cof2048 rob2048 cob2048 rof4096 cof4096 rob4096 cob4096 rof8192 cof8192 rob8192 cob8192 rof16384 cof16384 rob16384 cob16384 rof32768 cof32768 rob32768 cob32768 rof65536 cof65536 rob65536 cob65536 rof131072 cof131072 rob131072 cob131072 rof262144 cof262144 rob262144 cob262144 rof524288 cof524288 rob524288 cob524288 rof1048576 cof1048576 rob1048576 cob1048576
fftwf-wisdom -p -v -T 2 -w wisdomf2 -o wisdomf rof2048 cof2048 rob2048 cob2048 rof4096 cof4096 rob4096 cob4096 rof8192 cof8192 rob8192 cob8192 rof16384 cof16384 rob16384 cob16384 rof32768 cof32768 rob32768 cob32768 rof65536 cof65536 rob65536 cob65536 rof131072 cof131072 rob131072 cob131072 rof262144 cof262144 rob262144 cob262144 rof524288 cof524288 rob524288 cob524288 rof1048576 cof1048576 rob1048576 cob1048576
fftwf-wisdom -p -v -T 4 -w wisdomf4 -o wisdomf rof2048 cof2048 rob2048 cob2048 rof4096 cof4096 rob4096 cob4096 rof8192 cof8192 rob8192 cob8192 rof16384 cof16384 rob16384 cob16384 rof32768 cof32768 rob32768 cob32768 rof65536 cof65536 rob65536 cob65536 rof131072 cof131072 rob131072 cob131072 rof262144 cof262144 rob262144 cob262144 rof524288 cof524288 rob524288 cob524288 rof1048576 cof1048576 rob1048576 cob1048576
fftwf-wisdom -p -v -T 8 -w wisdomf8 -o wisdomf rof2048 cof2048 rob2048 cob2048 rof4096 cof4096 rob4096 cob4096 rof8192 cof8192 rob8192 cob8192 rof16384 cof16384 rob16384 cob16384 rof32768 cof32768 rob32768 cob32768 rof65536 cof65536 rob65536 cob65536 rof131072 cof131072 rob131072 cob131072 rof262144 cof262144 rob262144 cob262144 rof524288 cof524288 rob524288 cob524288 rof1048576 cof1048576 rob1048576 cob1048576
fftwf-wisdom -p -v -T 16 -w wisdomf16 -o wisdomf rof2048 cof2048 rob2048 cob2048 rof4096 cof4096 rob4096 cob4096 rof8192 cof8192 rob8192 cob8192 rof16384 cof16384 rob16384 cob16384 rof32768 cof32768 rob32768 cob32768 rof65536 cof65536 rob65536 cob65536 rof131072 cof131072 rob131072 cob131072 rof262144 cof262144 rob262144 cob262144 rof524288 cof524288 rob524288 cob524288 rof1048576 cof1048576 rob1048576 cob1048576

fftwf-wisdom -v -T 1 -o wisdomf -w wisdomf1 -w wisdomf2 -w wisdomf4 -w wisdomf8 -w wisdomf16


sudo mkdir /etc/fftw
sudo chmod 777 /etc/fftw 
mv wisdomf /etc/fftw/wisdomf

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

## Benchmarking

Comparing to the `pycwt` port, results indicate relatively high performance even without using FFTW optimization. _(In it's current state, I have yet to get to the bottom of troubleshooting why generated wisdom files are empty, nor is the system wisdom file detected from `/etc/fftw/wisdomf`)_


```r
set.seed(1234)

Length_1e4 <- rnorm(1e4)
Length_1e5 <- rnorm(1e5)

opt <- FALSE
microbenchmark::microbenchmark(
  `10k-300` = RfCWT::fCWT(Length_1e4, f0 = 1,f1 = 101,nthreads =  8L,fn =  300,fs = 100,optimize = opt),
  `100k-300` = RfCWT::fCWT(Length_1e5, f0 = 1,f1 = 101,nthreads =  8L,fn =  300,fs = 100,optimize = opt),
  `10k-3000` = RfCWT::fCWT(Length_1e4, f0 = 1,f1 = 101,nthreads =  8L,fn = 3000,fs = 100,optimize = opt),
  `100k-3000` = RfCWT::fCWT(Length_1e5, f0 = 1,f1 = 101,nthreads =  8L,fn = 3000,fs = 100,optimize = opt),
  times = 1,unit = "seconds"
) 
```

```
Unit: seconds
      expr       min        lq      mean    median        uq       max neval
   10k-300 0.1802968 0.1802968 0.1802968 0.1802968 0.1802968 0.1802968     1
  100k-300 0.7537258 0.7537258 0.7537258 0.7537258 0.7537258 0.7537258     1
  10k-3000 1.6184668 1.6184668 1.6184668 1.6184668 1.6184668 1.6184668     1
 100k-3000 7.6223623 7.6223623 7.6223623 7.6223623 7.6223623 7.6223623     1
```

For reference, executing the [pycwt benchmark notebook](github.com/fastlib/fCWT/blob/main/benchmark.ipynb) on my machine _(Ubuntu 20.04 hosted by VMWare with Intel(R) Xeon(R) CPU E5-2695 v3 @ 2.30GHz - not exactly a high performance computing environment)_ gives the following results.

Additionally, `pcwt` timings do not include time spent allocating memory, initializing the wavelet, scales, fcwt object, or creating optimization plans. Bundling these steps into a single command adds some additional overhead for this R equivalent for benchmarking purposes.

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
10k-300:  0.04321003705263138 seconds
100k-300:  0.38753629140555856 seconds
10k-3000:  0.4065719280391932 seconds
100k-3000:  3.8452174592763186 seconds
```



## Known Issues

+ Plans are not being successfully saved after generation on _one_ of my test machines - Ubuntu 20.04


## Troubleshooting

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

### LDD on 

```
ldd /usr/local/lib/libfCWT.so
        linux-vdso.so.1 (0x00007ffdfaf7e000)
        libfftw3f.so.3 => /usr/lib/libfftw3f.so.3 (0x00007fd6bb0e5000)
        libfftw3f_omp.so.3 => /usr/lib/libfftw3f_omp.so.3 (0x00007fd6bb0da000)
        libstdc++.so.6 => /usr/lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007fd6baef8000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fd6bada9000)
        libgomp.so.1 => /usr/lib/x86_64-linux-gnu/libgomp.so.1 (0x00007fd6bad67000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fd6bab75000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fd6bbb87000)
        libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007fd6bab58000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fd6bab52000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fd6bab2f000)

```
