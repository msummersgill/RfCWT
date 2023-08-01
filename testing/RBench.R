options(width = 160)
# https://englanders.us/~jason/howtos/?howto=fftw
set.seed(1234)

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
) |> print()

n = as.numeric(seq_len(1e5))
x = sin(2*pi * (n + 0.002 * (n-256)^2 ) / 16)
xmat <- matrix(cbind(n/fs,x),ncol = 2)
xdf <- data.frame(n,x)

print(paste0("Medium: N = 100,000 x ",bpo * no, " Scales"))
microbenchmark::microbenchmark(
  WaveletComp = WaveletComp::analyze.wavelet(xdf,my.series = "x",dt = 1/fs,dj = 1/(bpo),lowerPeriod = 1/f1, upperPeriod = 1/f0, n.sim = 0, make.pval = F, loess.span = 0, verbose = F),
  RWave = Rwave::cwt(x, noctave=no, nvoice=bpo, plot = F, twoD = T),
  biwavelet = biwavelet::wt(xmat,dt = 1/fs,J1 = bpo * no - 1L, do.sig = F),
  RcppWavelet = RcppWavelet::analyze(x,bands_per_octave = bpo2,frequency_min = f0,frequency_max = f1,samplerate_hz = fs,mother_wavelet = "MORLET",morlet_carrier = 2 * pi,cores = nc),
  RfCWT = RfCWT::fCWT(x, f0 = f0,f1 = f1,nthreads =  nc,fn =  bpo * no,fs = fs,optimize = F),
  times = 1,unit = "seconds"
) |> print()

n = as.numeric(seq_len(1e6))
x = sin(2*pi * (n + 0.002 * (n-256)^2 ) / 16)
xmat <- matrix(cbind(n/fs,x),ncol = 2)
xdf <- data.frame(n,x)

print(paste0("Large: N = 1,000,000 x ",bpo * no, " Scales"))
microbenchmark::microbenchmark(
  # WaveletComp = WaveletComp::analyze.wavelet(xdf,my.series = "x",dt = 1/fs,dj = 1/(bpo),lowerPeriod = 1/f1, upperPeriod = 1/f0, n.sim = 0, make.pval = FALSE, loess.span = 0),
  # RWave = Rwave::cwt(x, noctave=no, nvoice=bpo, plot = F, twoD = T),
  # biwavelet = biwavelet::wt(xmat,dt = 1/fs,J1 = bpo * no - 1L, do.sig = FALSE),
  RcppWavelet = RcppWavelet::analyze(x,bands_per_octave = bpo2,frequency_min = f0,frequency_max = f1,samplerate_hz = fs,mother_wavelet = "MORLET",morlet_carrier = 2 * pi,cores = nc),
  RfCWT = RfCWT::fCWT(x, f0 = f0,f1 = f1,nthreads =  nc,fn =  bpo * no,fs = fs,optimize = F),
  times = 1,unit = "seconds"
) |> print()



print(sessionInfo())

n = as.numeric(seq_len(1e3))
x = sin(2*pi * (n + 0.002 * (n-256)^2 ) / 16)
xmat <- matrix(cbind(n/fs,x),ncol = 2)
xdf <- data.frame(n,x)
WaveletComp_analyze_wavelet = WaveletComp::analyze.wavelet(xdf,my.series = "x",dt = 1/fs,dj = 1/(bpo),lowerPeriod = 1/f1, upperPeriod = 1/f0, n.sim = 0, make.pval = F, loess.span = 0, verbose = F)
biwavelet_wt = biwavelet::wt(xmat,dt = 1/fs,J1 = bpo * no - 1L, do.sig = F)
RWave_cwt = Rwave::cwt(x, noctave=no, nvoice=bpo, plot = F, twoD = T)
RcppWavelet_analyze = RcppWavelet::analyze(x,bands_per_octave = bpo,frequency_min = f0,frequency_max = f1,samplerate_hz = fs,mother_wavelet = "MORLET",morlet_carrier = 2 * pi,cores = nc)
RfCWT_fCWT = RfCWT::fCWT(x, f0 = f0,f1 = f1,nthreads =  nc,fn =  640,fs = fs,optimize = F,dist = "FCWT_LOGSCALES")

str(Mod(WaveletComp_analyze_wavelet$Wave))
str(t(Mod(RWave_cwt)))
str(Mod(biwavelet_wt$wave))
str(t(Mod(RcppWavelet_analyze$scalogram)))
str(t(Mod(RfCWT_fCWT$scalogram)))

# plot_ly() |>
#   add_heatmap(z = Mod(WaveletComp_analyze_wavelet$Wave)) -> WaveletComp_plot
# plot_ly() |>
#   add_heatmap(z = t(Mod(RWave_cwt))) -> Rwave_plot
# plot_ly() |>
#   add_heatmap(z = Mod(biwavelet_wt$wave)) -> biwavelet_plot
# plot_ly() |>
#   add_heatmap(z = t(Mod(RcppWavelet_analyze$scalogram))) -> RcppWavelet_plot
# plot_ly() |>
#   add_heatmap(z = t(Mod(RfCWT_fCWT$scalogram))) -> RfCWT_plot
# 
# subplot(WaveletComp_plot,Rwave_plot,biwavelet_plot,RcppWavelet_plot,RfCWT_plot, nrows = 5)