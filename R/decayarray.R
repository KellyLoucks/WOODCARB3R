#' Calculates decay values
#'
#' creating blank four-dimensional array to fill
#'
#' 1. Decay Type (1 = exponential, 2 = k=2, 3 = chi-squared)
#' 2. End Use (1 = Single Family Housing, 2 = Multifamily Housing, 3 = Mobile Homes, 4 = Residential Upkeep and Improvement, 5 = All Construction Excluding Railroads, 6 = Railroad Ties, 7 = Railcar Repair, 8 = Household Furniture, 9 = Commercial Furniture, 10 = Other Manufacturing, 11 = Shipping, 12 = Other Uses, 13 = Uses for Other Industrial Products)
#' 3. Year Put in Use (1 = 1900)
#' 4. Year (1 = 1900)
#' Example: decay_array[1, 3, 51, 101] will produce percentage carbon left after exponential decay of mobile homes built in 1950 at year 2000
#' Example: decay_array[1, 3, 51, ] will produce a vector of percentage carbon left after exponential decay of mobile homes built in 1950 for years 1950 - end year
#' Example: decay_array[1, 3, , 101] will produce a vector of percentage carbon left after exponential decay of mobile homes built from 1900 to 2000 in the year 2000
#'
#' @param halfLives. data frames of half lives
#'
#' @return four dimensional array
#'
#' @examples
#' \dontrun{
#' calculatedecay()
#' }
calculatedecay <- function(halfLives. = halfLives){

  decays <- 4
  enduses <- 13
  years <- 151
  decay_array <- array(0,dim=c(decays, enduses, years, years))

  ##filling with decay percentages
  ##exponential (k=1)
  g <- function(x) {((x^(k-1))*(exp(-x/h)))/(gamma(k)*(h^k))}
  k <- 1
  for (i in 1:years)
  {
    for (j in 1:enduses)
    {
      h <- halfLives.[i,j] / log(2)
      for (l in 1:(years - i + 1))
      {
        decay <- stats::integrate(g, lower=0, upper=l)$value
        decay_array[1, j, i, (i + l - 1)] <- 1 - decay
      }
    }
  }

  ##(theta =2)
  g <- function(x) {((x^(k-1))*(exp(1)^(-x/h)))/(gamma(k)*(h^k))}
  k <- 2
  for (i in 1:years)
  {
    for (j in 1:enduses)
    {
      h <- 1
      decayval <- 1
      while(abs(decayval - 0.5) > 1e-14) #finding h given each half life
      {
        m <- decayval * 2
        h <- h * m
        decayval <- stats::integrate(g, lower=0, upper=halfLives.[i,j])$value
      }
      for (l in 1:(years - i + 1))
      {
        decay <- stats::integrate(g, lower=0, upper=l)$value
        decay_array[2, j, i, (i + l - 1)] <- 1 - decay
      }
    }
  }

  ##chi-squared (k=2)
  ##ALGORITHM IS VERY APPROXIMATE AND SPECIFIC TO THIS DATA
  ##ideas: use a solve package, solve in another external program, improve this algorithm/investigate how the integral is functioning
  for (i in 1:years)
  {
    g <- function(x) {((x^(k-1))*(exp(1)^(-x/h)))/(gamma(k)*(h^k))}
    h <- 2
    for (j in 1:enduses)
    {
      k <- 1
      decayval <- 1
      if (halfLives.[i,j] >= 100) #finding k given each half life
      {
        while(abs(decayval - 0.5) > 0.001)
        {
          m <- decayval * 1.6
          k <- k * m
          decayval <- stats::integrate(g, lower=0, upper=halfLives.[i,j])$value
        }
      }
      else if (halfLives.[i,j] >= 72)
      {
        while(abs(decayval - 0.5) > 0.001)
        {
          m <- decayval * 1.65
          k <- k * m
          decayval <- stats::integrate(g, lower=0, upper=halfLives.[i,j])$value
        }
      }
      else if (halfLives.[i,j] >= 50)
      {
        while(abs(decayval - 0.5) > 0.001)
        {
          m <- decayval * 1.555
          k <- k * m
          decayval <- stats::integrate(g, lower=0, upper=halfLives.[i,j])$value
        }
      }
      else if (halfLives.[i,j] >= 24)
      {
        while(abs(decayval - 0.5) > 0.001)
        {
          m <- decayval * 2.05
          k <- k * m
          decayval <- stats::integrate(g, lower=0, upper=halfLives.[i,j])$value
        }
      }
      else
      {
        while(abs(decayval - 0.5) > 0.001)
        {
          m <- decayval * 2.5
          k <- k * m
          decayval <- stats::integrate(g, lower=0, upper=halfLives.[i,j])$value
        }
      }
      for (l in 1:(years - i + 1))
      {
        decay <- integrate(g, lower=0, upper=l)$value
        decay_array[3, j, i, (i + l - 1)] <- 1 - decay
      }
    }
  }
  decay_array
}

# ##example and plots
# ##creating test vector of product input (100 for each input)
# decay_test <- rep(100, times = enduses)
#
# ##multiplying by exponential decay values for year 2016
# exponential_test2016 <- decay_test * decay_array[1, c(1:enduses), 117, c(117:years)]
#
# ##multiplying by k=2 decay values for year 2016
# k2_test2016 <- decay_test * decay_array[2, c(1:enduses), 117, c(117:years)]
#
# ##multiplying by chi-squared decay values for year 2016
# chi_test2016 <- decay_test * decay_array[3, c(1:enduses), 117, c(117:years)]
#
# ##plots for exponential, k=2, chi-squared amount stored in mobile homes built in 2016 - end year
# plot(x = c(117:years), y = exponential_test2016[3,],
#      type = "l",
#      col = "red",
#      lwd = 3,
#      main = "Decay of Mobile Homes Built in 2016",
#      xlab = "Years (Since 1900)",
#      ylab = "Amount of Carbon Stored")
# lines(x = c(117:years), y = k2_test2016[3,],
#       col = "blue",
#       lwd = 3)
# lines(x = c(117:years), y = chi_test2016[3,],
#       col = "green",
#       lwd = 3)
# legend("bottomleft", c("exp", "k=2", "chi^2"),
#        col = c("red", "blue", "green"),
#        lwd = 3)

findKorTHETAforGamma <- function(halflife = 100, theta, k){
  g <- function(x){
    ((x^(theta - 1)) * (exp(-x/k))) / (gamma(theta) * (k^theta))
  }

  if(missing(k)){
    k <- 1
    decayval <- 1
    while(abs(decayval - 0.5) > 0.0001){
      l <- decayval * 2
      k <- k * l

      decayval<-stats::integrate(g, lower=0, upper=halflife)$value
    }
    return(k)
  }
  if(missing(theta)){
    theta <- 1.2
    decayval <- 1
    while(abs(decayval - 0.5) > 1e-4){
      #l <- decayval / 0.5
      #theta <- theta * l

      decayval<-stats::integrate(g, lower=0, upper=halflife)$value
      #print(c(round(theta,4), decayval))
      if (decayval > 0.5){
          if(decayval > 0.51){
            theta <- theta + 1
          }
        else{
          theta <- theta  + 1e-5
        }

      }
      else {
        theta <- theta - 1e-5
      }
    }
    theta
  }
}

findKorTHETAforGamma <- function(halflife = 100, theta, k){
  g <- function(x){
    ((x^(theta - 1)) * (exp(-x/k))) / (gamma(theta) * (k^theta))
  }

  if(missing(k)){
    k <- 1
    decayval <- 1
    while(abs(decayval - 0.5) > 0.0001){
      l <- decayval * 2
      k <- k * l

      decayval<-stats::integrate(g, lower=0, upper=halflife)$value
      #print(round(k,4), decayval)
    }
    return(k)
  }
  if(missing(theta)){
    theta <- 1.2
    decayval <- 1
    while(abs(decayval - 0.5) > 1e-14){
      l <- decayval / 0.5
      theta <- theta * l

      decayval<-stats::integrate(g, lower=0, upper=halflife)$value
      print(c(round(theta,4), decayval))

    }
    theta
  }
}


calculatedecay <- function(halfLives. = halfLives){

  decays <- 4
  enduses <- 13
  years <- 151
  decay_array <- array(0,dim=c(decays, enduses, years, years))

  ##filling with decay percentages
  ##exponential (k=1)
  g <- function(x) {((x^(k-1))*(exp(-x/h)))/(gamma(k)*(h^k))}
  k <- 1
  for (i in 1:years)
  {
    for (j in 1:enduses)
    {
      h <- halfLives.[i,j] / log(2)
      for (l in 1:(years - i + 1))
      {
        decay <- stats::integrate(g, lower=0, upper=l)$value
        decay_array[1, j, i, (i + l - 1)] <- 1 - decay
      }
    }
  }

  ##(theta =2)
  g <- function(x) {((x^(k-1))*(exp(1)^(-x/h)))/(gamma(k)*(h^k))}
  k <- 2
  for (i in 1:years)
  {
    for (j in 1:enduses)
    {
      h <- 1
      decayval <- 1
      while(abs(decayval - 0.5) > 1e-14) #finding h given each half life
      {
        m <- decayval * 2
        h <- h * m
        decayval <- stats::integrate(g, lower=0, upper=halfLives.[i,j])$value
      }
      for (l in 1:(years - i + 1))
      {
        decay <- stats::integrate(g, lower=0, upper=l)$value
        decay_array[2, j, i, (i + l - 1)] <- 1 - decay
      }
    }
  }

  ##chi-squared (k=2)
  for (i in 1:years)
  {

    for (j in 1:enduses)
    {
      halfLives.
    }
  }
  decay_array
}
