#############################################################################
#   Copyright (c) 2014 Mathieu Ribatet                                                                                                  
#                                                                                                                                                                        
#   This program is free software; you can redistribute it and/or modify                                               
#   it under the terms of the GNU General Public License as published by                                         
#   the Free Software Foundation; either version 2 of the License, or                                                   
#   (at your option) any later version.                                                                                                            
#                                                                                                                                                                         
#   This program is distributed in the hope that it will be useful,                                                             
#   but WITHOUT ANY WARRANTY; without even the implied warranty of                                          
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                                 
#   GNU General Public License for more details.                                                                                    
#                                                                                                                                                                         
#   You should have received a copy of the GNU General Public License                                           
#   along with this program; if not, write to the                                                                                           
#   Free Software Foundation, Inc.,                                                                                                              
#   59 Temple Place, Suite 330, Boston, MA 02111-1307, USA                                                             
#                                                                                                                                                                         
#############################################################################



##   10) Maximum penalized likelihood estimator


##Maximum penalized likelihood estimator
gpdmple <- function(x, threshold, start, ..., std.err.type =
                    "observed", corr = FALSE, method = "BFGS",
                    warn.inf = TRUE, alpha = 1, lambda = 1){

  if (all(c("observed", "expected", "none") != std.err.type))
    stop("``std.err.type'' must be one of 'observed', 'expected' or 'none'")
  
  nlpot <- function(scale, shape) { 
    ans <- -.C(POT_do_gpdlik, exceed, nat, threshold, scale,
                shape, dns = double(1))$dns

    if ((shape > 0) & (shape <1))
     ans <- lambda * ((1 / (1 - shape) - 1)^alpha) + ans

    if (shape >= 1)
      ans <- 1e6

    return(ans)
  }
  
  nn <- length(x)
  
  threshold <- rep(threshold, length.out = nn)
  
  high <- (x > threshold) & !is.na(x)
  threshold <- as.double(threshold[high])
  exceed <- as.double(x[high])
  nat <- length(exceed)
  
  if(!nat) stop("no data above threshold")
  
  pat <- nat/nn
  param <- c("scale", "shape")
  
  if(missing(start)) {
    
    start <- list(scale = 0, shape = 0)
    start$scale <- mean(exceed) - min(threshold)
    
    start <- start[!(param %in% names(list(...)))]
    
  }
  
  if(!is.list(start)) 
    stop("`start' must be a named list")
  
  if(!length(start))
    stop("there are no parameters left to maximize over")
  
  nm <- names(start)
  l <- length(nm)
  f <- formals(nlpot)
  names(f) <- param
  m <- match(nm, param)
  
  if(any(is.na(m))) 
    stop("`start' specifies unknown arguments")
  
  formals(nlpot) <- c(f[m], f[-m])
  nllh <- function(p, ...) nlpot(p, ...)
  
  if(l > 1)
    body(nllh) <- parse(text = paste("nlpot(", paste("p[",1:l,
                          "]", collapse = ", "), ", ...)"))
  
  fixed.param <- list(...)[names(list(...)) %in% param]
  
  if(any(!(param %in% c(nm,names(fixed.param)))))
    stop("unspecified parameters")
  
  start.arg <- c(list(p = unlist(start)), fixed.param)
  if( warn.inf && do.call("nllh", start.arg) == 1e6 )
    warning("negative log-likelihood is infinite at starting values")
  
  opt <- optim(start, nllh, hessian = TRUE, ..., method = method)
  
  if ((opt$convergence != 0) || (opt$value == 1e6)) {
    warning("optimization may not have succeeded")
    if(opt$convergence == 1) opt$convergence <- "iteration limit reached"
  }
  
  else opt$convergence <- "successful"

  tol <- .Machine$double.eps^0.5
  
  if (std.err.type != "none")
  {
    if(std.err.type == "observed") 
    {
      var.cov <- qr(opt$hessian, tol = tol)
      if(var.cov$rank != ncol(var.cov$qr))
      {
        warning("observed information matrix is singular; passing std.err.type to ``expected''")
        std.err.type <- "expected"
        obs.fish <- FALSE
      }else
        obs.fish <- TRUE
      
      if (obs.fish)
      {
        var.cov <- try(solve(var.cov, tol = tol), silent = TRUE)
        
        if(!is.matrix(var.cov))
        {
          warning("observed information matrix is singular; passing std.err.type to ''none''")
          std.err.type <- "none"
          std.err <- var.cov <- corr.mat <- NULL
        }else
        {
          std.err <- diag(var.cov)
          if(any(std.err <= 0))
          {
            warning("observed information matrix is singular; passing std.err.type to ``expected''")
            std.err.type <- "expected"
            obs.fish <- FALSE
          }else
            std.err <- sqrt(std.err)
          
          if(corr) 
          {
            .mat <- diag(1/std.err, nrow = length(std.err))
            corr.mat <- structure(.mat %*% var.cov %*% .mat, dimnames = list(nm,nm))
            diag(corr.mat) <- rep(1, length(std.err))
          }else 
            corr.mat <- NULL
        }
      }
    }
    
    if (std.err.type == "expected")
    {
      
      shape <- opt$par[2]
      scale <- opt$par[1]
      a22 <- 2/((1+shape)*(1+2*shape))
      a12 <- 1/(scale*(1+shape)*(1+2*shape))
      a11 <- 1/((scale^2)*(1+2*shape))
      ##Expected Matix of Information of Fisher
      expFisher <- nat * matrix(c(a11,a12,a12,a22),nrow=2)
      
      expFisher <- qr(expFisher, tol = tol)
      var.cov <- solve(expFisher, tol = tol)
      std.err <- sqrt(diag(var.cov))
      
      if(corr) 
      {
        .mat <- diag(1/std.err, nrow = length(std.err))
        corr.mat <- structure(.mat %*% var.cov %*% .mat, dimnames = list(nm,nm))
        diag(corr.mat) <- rep(1, length(std.err))
      }else
        corr.mat <- NULL
    }
    
    colnames(var.cov) <- nm
    rownames(var.cov) <- nm
    names(std.err) <- nm
  }else
  {
    std.err <- std.err.type <- corr.mat <- NULL
    var.cov <- NULL
  }
  
  
  param <- c(opt$par, unlist(fixed.param))
  scale <- param["scale"]
  
  var.thresh <- !all(threshold == threshold[1])

  if (!var.thresh)
    threshold <- threshold[1]
  
  list(fitted.values = opt$par, std.err = std.err, std.err.type = std.err.type,
       var.cov = var.cov, fixed = unlist(fixed.param), param = param,
       deviance = 2*opt$value, corr = corr.mat, convergence = opt$convergence,
       counts = opt$counts, message = opt$message, threshold = threshold,
       nat = nat, pat = pat, data = x, exceed = exceed, scale = scale,
       var.thresh = var.thresh, est = "MPLE", logLik = -opt$value,
       opt.value = opt$value)
}



