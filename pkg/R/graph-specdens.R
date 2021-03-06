#############################################################################
#   Copyright (c) 2019 Mathieu Ribatet, Christophe Dutang                                                                                                  
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

##A function to compute spectral densities for each dependance
##models
specdens <- function(fitted, main, plot = TRUE, ...){

  if (!inherits(fitted, c("bvpot", "mcpot")))
    stop("Use only with 'bvpot'/'mcpot' objects")
  
  model <- fitted$model
  alpha <- fitted$param["alpha"]

  if (model == "log"){
    ##Logistic case:
    h <- function(q){
      res <- rep(NaN, length(q))
      q01 <- q[q > 0 & q <= 1]
      res[q > 0 & q <= 1] <- (1/alpha - 1) * (q01 * (1-q01))^(-(1+1/alpha)) *
        (q01^(-1/alpha) + (1-q01)^(-1/alpha))^(alpha-2)
      res
    }
  }

  if (model == "alog"){
   ##Asymetric Logistic case:
    asCoef1 <- fitted$param["asCoef1"]
    asCoef2 <- fitted$param["asCoef2"]
    h <- function(q){
      res <- rep(NaN, length(q))
      q01 <- q[q > 0 & q <= 1]
      res[q > 0 & q <= 1] <- (1/alpha - 1) * (asCoef1 * asCoef2)^(1/alpha) *
        (q01 * (1-q01))^(-(1+1/alpha)) *
        ((asCoef1/q01)^(1/alpha) +
           (asCoef2/(1-q01))^(1/alpha))^(alpha-2)
      res
    }
  } 

  if (model == "nlog"){
    ##Negative Logistic case:
    h <- function(q){
      res <- rep(NaN, length(q))
      q01 <- q[q > 0 & q <= 1]
      res[q > 0 & q <= 1] <- (1 + alpha) * (q01 * (1-q01))^(alpha-1) *
        (q01^alpha + (1-q01)^alpha)^(-1/alpha-2)
      res
    }
  }

  if (model == "anlog"){
    ##Asymetric Negative Logistic case:
    asCoef1 <- fitted$param["asCoef1"]
    asCoef2 <- fitted$param["asCoef2"]
    h <- function(q){
      res <- rep(NaN, length(q))
      q01 <- q[q > 0 & q <= 1]
      res[q > 0 & q <= 1] <- (1 + alpha) * (asCoef1 * asCoef2)^(-alpha) *
        (q01 * (1-q01))^(alpha-1) *
        ((q01/asCoef1)^alpha +
           ((1-q01)/asCoef2)^alpha)^(-1/alpha-2)
      res
    }
  }

  if (model == "mix"){
    ##Mixed case:
    h <- function(q){
      res <- rep(NaN, length(q))
      res[q > 0 & q <= 1] <- 2 * alpha
      res
      }
  }

  if (model == "amix"){
    ##Mixed case:
    asCoef <- fitted$param["asCoef"]
    h <- function(q){
      res <- rep(NaN, length(q))
      q01 <- q[q > 0 & q <= 1]
      res[q > 0 & q <= 1] <- 2 * alpha + 6 * asCoef * (1-q01)
      res
    }
  }

  if (plot){
    eps <- .Machine$double.eps^0.5

    ##For the logisitic model h is infinite near 0 and 1 thus,
    if (model == "log")
      eps <- 0.01
    
    if (missing(main))
      main <- "Spectral Density"

    plot(h, from = eps, to = 1 - eps, main = main, ...)
  }
      
  attributes(h) <- list(model = model)
  invisible(h)
}


