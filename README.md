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

In addition, using the [FFTW `fftwf-wissdom` utility](https://www.fftw.org/fftw-wisdom.1.html) to pre-generate plans that can be used system wide can improve performance at runtime. Generating the full canonical set of cases using `fftw-wisdom -v -c -o wisdom` takes many hours, but for the purposes of this library, we only need a subset of plans. 


`RfCWT::GenerateWisdom()` is provided as a convenience function to generate the `fftwf-wisdom` commands for a defined set of threads. By default, the commands are printed to the console output, but specifying `Execute = TRUE` will use `system()` to execute them directly in sequence.

```r
RfCWT::GenerateWisdom(Threads = c(2L,4L,8L,16L,32L), Execute = FALSE) 

```

The first command utilizing one thread generates a new file named `wisdomf`. For each subsequent run, the output of the previous execution is concatenated with the prior result, so that the final file will include plans for all thread counts specified.

```
sudo mkdir /etc/fftw
sudo chmod 777 /etc/fftw 

fftwf-wisdom -v -T 1 -o wisdomf rof2048 cof2048 rob2048 cob2048 rof4096 cof4096 rob4096 cob4096 rof8192 cof8192 rob8192 cob8192 rof16384 cof16384 rob16384 cob16384 rof32768 cof32768 rob32768 cob32768 rof65536 cof65536 rob65536 cob65536 rof131072 cof131072 rob131072 cob131072 rof262144 cof262144 rob262144 cob262144 rof524288 cof524288 rob524288 cob524288 rof1048576 cof1048576 rob1048576 cob1048576

fftwf-wisdom -v -T 2 -w wisdomf -o wisdomf rof2048 cof2048 rob2048 cob2048 rof4096 cof4096 rob4096 cob4096 rof8192 cof8192 rob8192 cob8192 rof16384 cof16384 rob16384 cob16384 rof32768 cof32768 rob32768 cob32768 rof65536 cof65536 rob65536 cob65536 rof131072 cof131072 rob131072 cob131072 rof262144 cof262144 rob262144 cob262144 rof524288 cof524288 rob524288 cob524288 rof1048576 cof1048576 rob1048576 cob1048576

fftwf-wisdom -v -T 4 -w wisdomf -o wisdomf rof2048 cof2048 rob2048 cob2048 rof4096 cof4096 rob4096 cob4096 rof8192 cof8192 rob8192 cob8192 rof16384 cof16384 rob16384 cob16384 rof32768 cof32768 rob32768 cob32768 rof65536 cof65536 rob65536 cob65536 rof131072 cof131072 rob131072 cob131072 rof262144 cof262144 rob262144 cob262144 rof524288 cof524288 rob524288 cob524288 rof1048576 cof1048576 rob1048576 cob1048576

fftwf-wisdom -v -T 8 -w wisdomf -o wisdomf rof2048 cof2048 rob2048 cob2048 rof4096 cof4096 rob4096 cob4096 rof8192 cof8192 rob8192 cob8192 rof16384 cof16384 rob16384 cob16384 rof32768 cof32768 rob32768 cob32768 rof65536 cof65536 rob65536 cob65536 rof131072 cof131072 rob131072 cob131072 rof262144 cof262144 rob262144 cob262144 rof524288 cof524288 rob524288 cob524288 rof1048576 cof1048576 rob1048576 cob1048576

fftwf-wisdom -v -T 16 -w wisdomf -o wisdomf rof2048 cof2048 rob2048 cob2048 rof4096 cof4096 rob4096 cob4096 rof8192 cof8192 rob8192 cob8192 rof16384 cof16384 rob16384 cob16384 rof32768 cof32768 rob32768 cob32768 rof65536 cof65536 rob65536 cob65536 rof131072 cof131072 rob131072 cob131072 rof262144 cof262144 rob262144 cob262144 rof524288 cof524288 rob524288 cob524288 rof1048576 cof1048576 rob1048576 cob1048576

fftwf-wisdom -v -T 32 -w wisdomf -o wisdomf rof2048 cof2048 rob2048 cob2048 rof4096 cof4096 rob4096 cob4096 rof8192 cof8192 rob8192 cob8192 rof16384 cof16384 rob16384 cob16384 rof32768 cof32768 rob32768 cob32768 rof65536 cof65536 rob65536 cob65536 rof131072 cof131072 rob131072 cob131072 rof262144 cof262144 rob262144 cob262144 rof524288 cof524288 rob524288 cob524288 rof1048576 cof1048576 rob1048576 cob1048576

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
R CMD INSTALL --preclean --no-multiarch --with-keep.source RfCWT
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



## Known Issues

+ Plans are not being succesfully saved after generation


```
matthew14786@hprstudio01:~/fCWT/build$ ldd /usr/local/lib/libfCWT.so
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