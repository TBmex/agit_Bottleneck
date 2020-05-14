library(tidyverse)
library(argparse)

# Handle command line arguments first
parser <- ArgumentParser()

parser$add_argument("--file", type="character", default = "./example_data/donor_and_recipient_freqs.txt" ,
    help="file containing variant frequencies")
parser$add_argument("--plot_bool", type="logical", default= FALSE,
    help="determines whether pdf plot approx_plot.pdf is produced or not")
parser$add_argument("--var_calling_threshold", type="double", default= 0.03,
    help="variant calling threshold")
parser$add_argument("--Nb_min", type="integer", default= 1,
    help="Minimum bottleneck value considered")
parser$add_argument("--Nb_max", type="integer", default= 200,
    help="Maximum bottleneck value considered")
parser$add_argument("--confidence_level", type="double", default= .95,
    help="Confidence level (determines bounds of confidence interval)")
args <- parser$parse_args()

# Now create necessary variables and dataframes

plot_bool  <- args$plot_bool # determines whether or not a plot of log likelihood vs bottleneck size is produced

var_calling_threshold  <- args$var_calling_threshold # variant calling threshold for frequency in recipient
 
Nb_min <- args$Nb_min      # Minimum bottleneck size we consider
if(Nb_min < 1){Nb_min = 1} # preventing erros with Nb_min at 0 or lower 
Nb_max <-  args$Nb_max     # Maximum bottlebeck size we consider

confidence_level <- args$confidence_level # determines width of confidence interval

donor_and_recip_freqs_observed <- read.table(args$file) # table of SNP frequencies in donor and recipient
original_row_count <- nrow(donor_and_recip_freqs_observed)  # number of rows in raw table
donor_and_recip_freqs_observed <- subset(donor_and_recip_freqs_observed, donor_and_recip_freqs_observed[, 1] >= var_calling_threshold)
new_row_count <- nrow(donor_and_recip_freqs_observed) # number of rows in filtered table

if(new_row_count != original_row_count )
{print("WARNING:  Rows of the input file with donor frequency less than variant calling threshold have been removed during analysis. ")}

n_variants <- nrow(donor_and_recip_freqs_observed) # number of variants 

freqs_tibble <- tibble(donor_freqs = donor_and_recip_freqs_observed[, 1], recip_freqs = donor_and_recip_freqs_observed[, 2] )

# Now implement the beta binomial algorithm

Log_Beta_Binom <- function(nu_donor, nu_recipient, NB_SIZE)  # This function gives Log Likelihood for every donor recipient SNP frequency pair
{ LL_val_above <- 0 # used for recipient frequencies above calling threshold
  LL_val_below <- 0 # used for recipient frequencies below calling threshold
  for(k in 0:NB_SIZE){
    LL_val_above <-  LL_val_above +  dbeta(nu_recipient, k, (NB_SIZE - k) )*dbinom(k, size=NB_SIZE, prob= nu_donor)  
    LL_val_below <- LL_val_below +   pbeta(var_calling_threshold, k, (NB_SIZE - k))*dbinom(k,size=NB_SIZE, prob= nu_donor)
    }
  LL_val <- if_else(nu_recipient >= var_calling_threshold , LL_val_above,  LL_val_below )

   # We use LL_val_above above the calling threshold, and LL_val_below below the calling threshold
   
  LL_val <- log(LL_val) # convert likelihood to log likelihood
  return(LL_val)
}

LL_func_approx <- function(Nb_size){  # This function sums over all SNP frequencies in the donor and recipient
  Total_LL <- 0
 LL_array <- Log_Beta_Binom(freqs_tibble$donor_freqs, freqs_tibble$recip_freqs, Nb_size)  
 Total_LL <- sum(LL_array)
   return(Total_LL)
  }


# Now we define array of Log Likelihoods for all possible bottleneck sizes
LL_tibble <- tibble(bottleneck_size = c(Nb_min:Nb_max), Log_Likelihood = 0*c(Nb_min:Nb_max)) 
for(I in 1:nrow(LL_tibble) )
  {LL_tibble$Log_Likelihood[I] <- LL_func_approx( LL_tibble$bottleneck_size[I] ) }


# Now we find the maximum likelihood estimate and the associated confidence interval

Max_LL <- max(LL_tibble$Log_Likelihood) # Maximum value of log likelihood
Max_LL_bottleneck <- which(LL_tibble$Log_Likelihood == max(LL_tibble$Log_Likelihood) ) # bottleneck size at which max likelihood occurs
likelihood_ratio <- qchisq(confidence_level, df=1) # necessary ratio of likelihoods set by confidence level
ci_tibble <- filter(LL_tibble, 2*(Max_LL - Log_Likelihood) <= likelihood_ratio ) 
lower_CI_bottleneck <- min(ci_tibble$bottleneck_size) # lower bound of confidence interval
upper_CI_bottleneck <- max(ci_tibble$bottleneck_size) # upper bound of confidence interval

# now we plot our results
if(plot_bool == TRUE){
ggplot(data = LL_tibble) + geom_point(aes(x = bottleneck_size, y= Log_Likelihood )) + 
  geom_vline(xintercept= Max_LL_bottleneck )  + 
  geom_vline(xintercept= lower_CI_bottleneck, color = "green" ) +
  geom_vline(xintercept= upper_CI_bottleneck, color = "green"  ) + 
  labs(x= "Bottleneck Size", y = "Log Likelihood" )
ggsave("approx_plot.jpg")
}
print("Bottleneck size")
print(Max_LL_bottleneck)
print("confidence interval left bound")
print(lower_CI_bottleneck)
print("confidence interval right bound")
print(upper_CI_bottleneck)