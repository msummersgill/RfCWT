#' Generate a set of wisdom files for FFTW
#' @name GenerateWisdom
#' @param Threads an integer vector specifying the distinct combination of threads desired.
#' @param Execute Whether or not the commands should be executed or printed to stdout

GenerateWisdom <- function(Threads = c(2L,4L,8L,16L,28L),
                           Execute = FALSE) {
  
  Cases <- expand.grid(type = c("r","c"),
                       inplace = c("o"),
                       direction = c("f","b"),
                       geometry =  2^seq(from = 11, to = 20))
  
  AllCases <- paste0(paste0(Cases$type,
                            Cases$inplace,
                            Cases$direction,
                            Cases$geometry), collapse = " ")
  
  
  Command1 <- paste0("fftwf-wisdom -v -T ",1L," -o wisdomf ", AllCases)
  if(Execute) system(Command1)
  
  OtherComands <- character(length(Threads))
  
  for(i in seq_along(Threads)) {
    OtherComands[[i]] <- Command <- paste0("fftwf-wisdom -v -T ",Threads[[i]]," -w wisdomf -o wisdomf ", AllCases)
    if(Execute) system(Command)
  }
  
  cat(paste0(c(Command1,OtherComands), collapse = "\n\n"))
  
}
