#' Calculate final carbon contribution to AFOLU.
#'
#' @param Years years to return carbon totals for
#' @param approach The approach used to calculate carbon contribution.
#' @param decaytype Type of decay method to use
#' @param plot whether to return a plot or not
#' @param halflives data frame of half lives to use
#'
#' @return A vector of carbon contributions for all Years. Plot returned is optional
#' @export
#'
#' @examples
#' finalCarbonContribution()
#' finalCarbonContribution(approach = "Stock Change")
#' finalCarbonContribution(approach = "Production",
#'                          decaytype ="Exponential")
finalCarbonContribution <- function(Years = 1990:2015,approach = c("Production",
                                                                   "Stock Change"),
                                    decaytype = c("Exponential",
                                                  "Gamma"), plot = FALSE,
                                    halflives = halfLives){
  approachtype <- match.arg(approach)
  decay<- match.arg(decaytype)

  if(approachtype == "Production" | approachtype == "Stock Change"){

    vara <-  (SWP_CARBON_STOCKCHANGE(Years, approach = approachtype,
                                     decaydistribution = decay) +
                PAPER_CARBON_STOCKCHANGE(Years,
                                         approach = approachtype)) * 1000

    varb <- carbonfromdumps(Years, approach = approachtype)  * 1000

    CarbonContribution <- (-1*vara-varb)*44/12

    if(plot == TRUE){
      #gdf <- data.frame(Years = Years, CarbonContribution = (-1*var2a-var2b)*44/12)
      #ggplot(gdf, aes(x=Years, y = CarbonContribution)) + geom_line()

      plot(Years,  CarbonContribution, type = "l", col = "red",
           main = paste("Hwp Contribution to AFOLU Using",approachtype, "Approach"),
           ylab = "CarbonContribution(Gg CO2/Yr)")
      return(CarbonContribution)
    }
    return(CarbonContribution)
  }

}

