
# https://englanders.us/~jason/howtos/?howto=fftw
set.seed(1234)

n_1e4 <- rnorm(1e4)
n_1e5 <- rnorm(1e5)
n_1e6 <- rnorm(1e6)
opt <- FALSE
flag <- "FFTW_MEASURE"
print(sessionInfo())
print("RfCWT::fCWT Benchmark")

# RfCWT::start_profiler("/tmp/profile.out")
microbenchmark::microbenchmark(
  # `10k-300 1 Threads`   = RfCWT::fCWT(n_1e4, f0 = 1,f1 = 101,nthreads =  1L,fn =  300,fs = 100,optimize = opt),
  # `100k-300 1 Threads`  = RfCWT::fCWT(n_1e5, f0 = 1,f1 = 101,nthreads =  1L,fn =  300,fs = 100,optimize = opt),
  # `10k-3000 1 Threads`  = RfCWT::fCWT(n_1e4, f0 = 1,f1 = 101,nthreads =  1L,fn = 3000,fs = 100,optimize = opt),
  # `100k-3000 1 Threads` = RfCWT::fCWT(n_1e5, f0 = 1,f1 = 101,nthreads =  1L,fn = 3000,fs = 100,optimize = opt),
  # `10k-300 8 Threads`   = RfCWT::fCWT(n_1e4, f0 = 1,f1 = 101,nthreads =  8L,fn =  300,fs = 100,optimize = opt),
  `100k-300 8 Threads`  = RfCWT::fCWT(n_1e5, f0 = 1,f1 = 101,nthreads =  8L,fn =  300,fs = 100,optimize = opt),
  # `1m-300 24 Threads` = RfCWT::fCWT(n_1e6, f0 = 1,f1 = 101,nthreads =  24L,fn = 300,fs = 100,optimize = opt),
  # `10k-3000 8 Threads`  = RfCWT::fCWT(n_1e4, f0 = 1,f1 = 101,nthreads =  8L,fn = 3000,fs = 100,optimize = opt),
  # `100k-3000 8 Threads` = RfCWT::fCWT(n_1e5, f0 = 1,f1 = 101,nthreads =  8L,fn = 3000,fs = 100,optimize = opt),
  # `1m-1000 24 Threads` = RfCWT::fCWT(n_1e6, f0 = 1,f1 = 101,nthreads =  24L,fn = 1000,fs = 100,optimize = opt),
  times = 1,unit = "seconds"
) |> print()
# RfCWT::stop_profiler()

RfCWT::fCWT(n_1e4, f0 = 1,f1 = 101,nthreads =  8L,fn = 300,fs = 100,optimize = opt) |> str() |> print()
# Length_1e4 <- rnorm(1e4)
# Length_1e5 <- rnorm(1e5)
# opt <- TRUE
# print(sessionInfo())
# print("RfCWT::fCWT Benchmark")
# microbenchmark::microbenchmark(
#   `10k-300 1 Threads`   = RfCWT::fCWT(Length_1e4, f0 = 1,f1 = 101,nthreads =  1L,fn =  300,fs = 100,optimize = opt),
#   `100k-300 1 Threads`  = RfCWT::fCWT(Length_1e5, f0 = 1,f1 = 101,nthreads =  1L,fn =  300,fs = 100,optimize = opt),
#   `10k-3000 1 Threads`  = RfCWT::fCWT(Length_1e4, f0 = 1,f1 = 101,nthreads =  1L,fn = 3000,fs = 100,optimize = opt),
#   `100k-3000 1 Threads` = RfCWT::fCWT(Length_1e5, f0 = 1,f1 = 101,nthreads =  1L,fn = 3000,fs = 100,optimize = opt),
#   `10k-300 4 Threads`   = RfCWT::fCWT(Length_1e4, f0 = 1,f1 = 101,nthreads =  4L,fn =  300,fs = 100,optimize = opt),
#   `100k-300 4 Threads`  = RfCWT::fCWT(Length_1e5, f0 = 1,f1 = 101,nthreads =  4L,fn =  300,fs = 100,optimize = opt),
#   `10k-3000 4 Threads`  = RfCWT::fCWT(Length_1e4, f0 = 1,f1 = 101,nthreads =  4L,fn = 3000,fs = 100,optimize = opt),
#   `100k-3000 4 Threads` = RfCWT::fCWT(Length_1e5, f0 = 1,f1 = 101,nthreads =  4L,fn = 3000,fs = 100,optimize = opt),
#   times = 1,unit = "seconds"
# )
# res <- RfCWT::fCWT(x, f0 = 1/600,f1 = 10,nthreads = 24L,fn = 500,fs = 100,optimize = TRUE)
# str(fCWTResult)
# 
# print("RcppWavelet::analyze")
# Old <- system.time({
#   oldResult <- RcppWavelet::analyze(x = DT[,Signal],
#                                     bands_per_octave = 128,
#                                     frequency_min = 1/600,
#                                     frequency_max = 10,
#                                     samplerate_hz = sampleFrequency,
#                                     mother_wavelet = "MORLET",
#                                     morlet_carrier = 30,
#                                     cores = 24L)
# })
# 
# print(Old)
# suppressPackageStartupMessages({
#   library(data.table)
#   library(RcppWavelet)
#   library(RfCWT)
#   library(plotly)
# })
# 
# set.seed(1234)
# sampleLength <- 2000L
# sampleFrequency <- 10L
# Index <- seq.default(from = 1/sampleFrequency, by = 1/sampleFrequency, length.out = sampleLength)
# Scale <- c(seq.default(from = 0, to = 1.25, length.out = sampleLength/2),
#            seq.default(from = 1.25, to = 0, length.out = sampleLength/2))
# Drift   <- seq.default(from = 0.75, to = 1.5, length.out = sampleLength)
# DT <- data.table(Time = Index,
#                  c1 = sin(1/8*(2*pi)*Index),
#                  c2 = sin(1/Drift*(2*pi)*Index*1.25),
#                  c3 = sin(1/5*(2*pi)*Index)*(Scale^3),
#                  Noise = rnorm(sampleLength,mean = 0,sd = 0.5))
# DT[,Signal := c1 + c2 + c3 + Noise]
# 
# fCWTResult <- RfCWT::fCWT(DT[,Signal], f0 = 1/10,f1 = 2,nthreads = 24L,fn = 50,fs = sampleFrequency,dist = "FCWT_LOGSCALES",bandwidth = 30/2/pi,normalization = TRUE)
# 
# plot_ly() |>
#   add_heatmap(z = t(Mod(fCWTResult$scalogram)),x = Index, y = 1/fCWTResult$freqs,name = "Scalogram")  |>
#   layout(yaxis = list(title = "Period"),
#          xaxis = list(title = ""))
