#### SETUP ####


work_dir <- getwd()
setwd(work_dir)

Rprof("fullprofile.txt", memory.profiling = TRUE)

source("mixture_functions.R")
date <- format.Date(Sys.Date(), "%Y%m%d")
options(scipen = 999)

needed_packages <- c("tidyr", "dplyr", "rstan", "rstudioapi", "robustbase", "portableParallelSeeds")
for(i in 1:length(needed_packages)){
  library(needed_packages[i], character.only = TRUE)
}


#### COMMAND LINE ARGUMENT SETUP ####
#commment out when not testing
comm_args <- c("rho=0.8", "P_REF=0.5", "mu2=0.5", "alpha=0.95")

#uncomment for real run
# comm_args <- commandArgs(trailingOnly = TRUE)

args <- strsplit(comm_args,"=",fixed=TRUE)

for (arg in 1:length(args)){
  argname <- args[[arg]][1]
  argval <- as.numeric(args[[arg]][2])
  assign(argname,argval)
}



#### SPECIFICATIONS ####
#number of people
n_people <- 1000
#number of items
n_items <- 60
#number of reps
nreps <- 10
#rho is the amount of DIF explained by the second-order factors - to be specified in job script
#P_REF is the proportion of people in the reference group - to be specified in job script
#alpha is mixture parameter - to be specified in job script
#mu1 is mean of distribution 1 - items with negligible DIF
mu1 <- 0
#mu2 is the mean of distribution 2 - items with "true" DIF - to be specified in job script
#sdev is the standard deviation of each distribution. sdev is equal for both distributions
sdev <- .1
#sdev_D is used to calculate beta1 and beta0
sdev_D <- sqrt(alpha*(sdev^2)) + ((1-alpha)*(sdev^2)) + (alpha*(1-alpha)*((mu1-mu2)^2))

#### SEED SETUP ####
filename <- paste0("seeds_", gsub(".", "-", as.character(rho), fixed = TRUE), "rho_", 
                   gsub(".", "-", as.character(P_REF), fixed = TRUE), "PREF_", 
                   gsub(".", "-", as.character(mu2), fixed = TRUE), "mu_",
                   gsub(".", "-", as.character(alpha), fixed = TRUE), "alpha.rds")

seeds <- readRDS(filename)

#### STAN SETUP ####
#load stan model scripts
source("stan_scripts.R")

b.dat_long <- list("n_people", "n_items", "n_observations", "respondentid", 
                   "itemid", "response", "group", "group_long",
                   "DIFpredict")

#analysis setup
precomp <- stanc(model_code = stancode_long)
precomp_model <- stan_model(stanc_ret = precomp)

#### DATA SAVE SETUP ####
true_params <- vector("list", nreps)
# result_objs <- vector("list", nreps)
est_param_summary <- vector("list", nreps)
est_param_means <- vector("list", nreps)
# est_param_medians <- vector("list", nreps)
correlations <- vector("list", nreps)
# median_correlations <- vector("list", nreps)
params_extraction <- vector("list", nreps)

#setup output folder for use later
folder_name <- paste0(date, "_simulation-results")
file_tag <- paste0(nreps, "reps_", 
                   gsub(".", "-", as.character(rho), fixed = TRUE), "rho_", 
                   gsub(".", "-", as.character(P_REF), fixed = TRUE), "PREF_", 
                   gsub(".", "-", as.character(mu2), fixed = TRUE), "mu_",
                   gsub(".", "-", as.character(alpha), fixed = TRUE), "alpha_",
                   date)

if(!dir.exists(paste0(work_dir, "/", folder_name))){
  dir.create(paste0(work_dir, "/", folder_name))
}
setwd(paste0(work_dir, "/", folder_name))


#### SIMULATION ####
#simulate a set of items
true_item_params <- item_sim(n_items, b_mean = 0, b_sd = 1, a_min = 0.5, a_max = 3, 
                             mix_alpha = alpha, mix_mu1 = mu1, mix_mu2 = mu2, mix_sdev = sdev)

#simulate a set of people's ability scores
true_ability <- ability_sim(n_people, P_REF = P_REF, ref_theta_mean = 0, ref_theta_sd = 1,
                            focal_theta_mean = -0.5, focal_theta_sd = 1)

#get responses for a set of people to a set of items
dataset <- one_dataset(true_ability, true_item_params)

#get values for the DIF predictor
DIFpredict <- DIF_predictor(true_item_params, rho = rho)

#save the true parameters
true_params[[i]] <- list(true_item_params, true_ability, dataset, DIFpredict)
names(true_params[[i]]) <- c("true_item_params", "true_ability", "dataset", 
                             "DIFpredict")

#set up grouping variable
group <- true_ability[,2]
n_ref <- sum(group)

#restructuring the data to long format
dataset <- long_format(dataset, group)

#pulling the individual parts back out
respondentid <- dataset$respondentid
itemid <- as.numeric(dataset$itemid)
response <- dataset$response
group_long <- dataset$group

n_observations <- nrow(dataset)

#conducting the analysis
analysis <- sampling(precomp_model, data = b.dat_long,
                     iter = 12000, warmup = 5000, chains = 2, verbose = FALSE, cores = 2)

#save the analysis object
# result_objs[[i]] <- analysis

#### OUTPUT ####
#pull out the summary of the estimated parameters
params_summary <- summary(analysis, pars = c("a", "b", "D", "beta0", "beta1", "mu", 
                                             "sigma2", "R2", "theta",
                                             "foc_mean"),
                          probs = c(0.025, 0.25, 0.5, 0.75, 0.975))$summary

#save the summary of the estimated parameters
est_param_summary[[i]] <- params_summary

#calculate the means of the estimated parameters
params <- extract(analysis, pars = c("a", "b", "D", "beta0", "beta1", "mu", "sigma2", 
                                     "R2", "theta", "foc_mean"))

params_extraction[[i]] <- params

a_params <- as.matrix(colMeans(params$a))
b_params <- as.matrix(colMeans(params$b))
D_params <- as.matrix(colMeans(params$D))
beta0 <- mean(params$beta0)
beta1 <- mean(params$beta1)
mu <- as.matrix(colMeans(params$mu))
sigma2 <- mean(params$sigma2)
R2 <- mean(params$R2)
theta <- as.matrix(colMeans(params$theta))
foc_mean <- mean(params$foc_mean)

beta1_true <- rho*sdev_D/sd(DIFpredict)
beta0_true <- mean(DIFpredict) - (beta1_true*mean(true_item_params[, "dif_param"]))

#save the means of estimated parameters
est_param_means[[i]] <- list(a_params, b_params, D_params, beta1, beta0,
                             mu, sigma2, R2, theta, foc_mean)
names(est_param_means[[i]]) <- c("a_params", "b_params", "D_params", 
                                 "beta1", "beta0", "mu", "sigma2", 
                                 "R2", "theta", "foc_mean")

#save the mean correlations & differences from the expected values
a_corr <- cor(a_params, true_item_params[,"a_param"])
b_corr <- cor(b_params, true_item_params[,"b_param"])
D_corr <- cor(D_params, true_item_params[,"dif_param"])
theta_corr <- cor(theta, true_ability[, 1])
foc_mean_diff <- foc_mean-(-.5)
ref_mean_diff <- mean(theta[1:n_ref])-0
R2_diff <- R2-(rho^2)
beta1_diff <- beta1_true - beta1
beta0_diff <- beta0_true - beta0

correlations[[i]] <- list(a_corr, b_corr, D_corr, theta_corr, 
                          foc_mean_diff, ref_mean_diff, R2_diff, 
                          beta1_diff, beta0_diff)
names(correlations[[i]]) <- c("a_corr", "b_corr", "D_corr", "theta_corr",
                              "foc_mean_diff", "ref_mean_diff", "R2_diff",
                              "beta1_diff", "beta0_diff")

#write all the good stuff out to disk
saveRDS(true_params, paste0("true_params_", file_tag, ".rds"))
# saveRDS(result_objs, paste0("result_objs_", file_tag, ".rds"))
saveRDS(est_param_summary, paste0("est_param_summary_", file_tag, ".rds"))
saveRDS(params_extraction, paste0("params_extraction_", file_tag, ".rds"))
saveRDS(est_param_means, paste0("est_param_means_", file_tag, ".rds"))
saveRDS(correlations, paste0("correlations_", file_tag, ".rds"))

Rprof(NULL)
summaryRprof(paste0(getwd(), "/../fullprofile.txt"), memory = "both")
