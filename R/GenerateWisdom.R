#' Generate a set of wisdom files for FFTW
#' @name GenerateWisdom
#' @param Threads an integer vector specifying the distinct combination of threads desired.
#' @param Execute Whether or not the commands should be executed or printed to stdout

GenerateWisdom <- function(Threads = c(2L,4L,8L,16L),
                           Execute = FALSE,
                           Mode = "FFTW_PATIENT") {
  
  if(Mode == "FFTW_MEASURE") {
    flag = "m";
  } else if(Mode == "FFTW_PATIENT") {
    flag = "p";
  } else if(Mode == "FFTW_EXHAUSTIVE") {
    flag = "x";
  } else {
    stop("Mode must be one of 'FFTW_MEASURE','FFTW_PATIENT',or 'FFTW_EXHAUSTIVE'\n")
  }
  
  Cases <- expand.grid(type = c("r","c"),
                       inplace = c("o"),
                       direction = c("f","b"),
                       geometry =  2^seq(from = 11, to = 20))
  
  AllCases <- paste0(paste0(Cases$type,
                            Cases$inplace,
                            Cases$direction,
                            Cases$geometry), collapse = " ")
  
  Command1 <- paste0("fftwf-wisdom -",flag," -v -T ",1L," -o wisdomf1 ", AllCases)
  if(Execute) system(Command1, wait = FALSE)
  
  OtherComands <- character(length(Threads))
  
  for(i in seq_along(Threads)) {
    OtherComands[[i]] <- Command <- paste0("fftwf-wisdom -",flag," -v -T ",Threads[[i]]," -w wisdomf",Threads[[i]]," -o wisdomf ", AllCases)
    if(Execute) system(Command, wait = FALSE)
  }
  
  cat(paste0(c(Command1,OtherComands), collapse = "\n\n"))

}  

#' Combine a set of wisdom files for FFTW
#' @name CombineWisdom
#' @param Threads an integer vector specifying the distinct combination of threads with existing wisdom files
#' @param Execute Whether or not the command should be executed or printed to stdout

CombineWisdom <- function(Threads = c(2L,4L,8L,16L)) {
  
  Combine <- paste0("fftwf-wisdom -v -T 1 -o wisdomf ",paste0("-w wisdomf",c(1L,Threads), collapse = " "),"\n")
  if(Execute) system(Combine)
  cat(Combine)
}
