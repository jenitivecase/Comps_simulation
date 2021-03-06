#### LONG FORMAT CODE ------------------------------------------------------####

stancode_long <- "
data {
  int<lower=0> n_people;
  int<lower=0> n_items;
  int<lower=0> n_observations;
  int<lower=0, upper=n_people> respondentid[n_observations];
  int<lower=0, upper=n_items> itemid[n_observations];
  int<lower=0, upper=1> response[n_observations];
  int<lower=0, upper=1> group_long[n_observations];
  vector[n_people] group;
  vector[n_items] words;
  vector[n_items] sentences;
  vector[n_items] ave_word_sent;
  vector[n_items] bigword;
  vector[n_items] nonmath_word;
  vector[n_items] prep;
  vector[n_items] passive;
  vector[n_items] confuse;
  vector[n_items] schematic;
  vector[n_items] confuseXschem;
}

parameters {
  vector<lower=0>[n_items] a;
  vector[n_items] b;
  vector[n_people] theta;
  vector[n_items] D_raw;
  real beta0;
  real beta1;
  real beta2;
  real beta3;
  real beta4;
  real beta5;
  real beta6;
  real beta7;
  real beta8;
  real beta9;
  real beta10;
  real<lower=0> sigma2;
  real foc_mean;
//  real D[n_items];
}

transformed parameters {
  vector[n_items] mu;
  vector[n_items] ss_err;
  vector[n_items] ss_reg;
  vector[n_people] mu_theta;
  real R2;
  vector[n_items] D;

  mu_theta = foc_mean*group;
  
  for (j in 1:n_items) {
    mu[j] = beta0 + beta1*words[j] + beta2*sentences[j] + beta3*ave_word_sent[j] + beta4*bigword[j] + beta5*nonmath_word[j] + beta6*prep[j] + beta7*passive[j] + beta8*confuse[j] + beta9*schematic[j] + beta10*confuseXschem[j];
  }

  D = mu + sigma2*D_raw;

  for (j in 1:n_items) {
    ss_err[j] = pow((D[j]-mu[j]),2);
    ss_reg[j] = pow((mu[j]-mean(D[])),2);
  }
  
  R2 = sum(ss_reg[])/(sum(ss_reg[])+sum(ss_err[]));
}

model {
  vector[n_observations] eta;

  a ~ lognormal(0, 1);
  b ~ normal(0, 1);
  theta ~ normal(mu_theta, 1);
  D_raw ~ normal(0, 1);
//  D ~ normal(mu, sigma2);
  foc_mean ~ normal(0, 4);
  beta0 ~ normal(0, 1);
  beta1 ~ normal(0, 1);
  beta2 ~ normal(0, 1);
  beta3 ~ normal(0, 1);
  beta4 ~ normal(0, 1);
  beta5 ~ normal(0, 1);
  beta6 ~ normal(0, 1);
  beta7 ~ normal(0, 1);
  beta8 ~ normal(0, 1);
  beta9 ~ normal(0, 1);
  beta10 ~ normal(0, 1);
  sigma2 ~ uniform(0, 10);

  for(i in 1:n_observations){
    eta[i] = a[itemid[i]]*(theta[respondentid[i]] - (b[itemid[i]] + D[itemid[i]] * group_long[i]));
  }
  
  response ~ bernoulli_logit(eta);
}
"



# #### WIDE FORMAT CODE ----------------------------------------------------####
# 
# stancode <- "
# data {
#   int<lower=0> n_people;
#   int<lower=0> n_items;
#   int<lower=0> n_ref;
#   int<lower=0> n_ref_1;
#   int dataset[n_people, n_items];
#   int<lower=0, upper=1> group[n_people];
#   real DIFpredict[n_items];
# }
# 
# parameters {
#   real<lower=0> a[n_items];
#   real b[n_items];
#   real theta[n_people];
#   real D[n_items];
#   real beta0;
#   real beta1;
#   real<lower=0> sigma2;
#   real foc_mean;
# //  real<lower=0> foc_var;
# }
# 
# transformed parameters {
#   real mu[n_items];
#   real ss_err[n_items];
#   real ss_reg[n_items];
#   real SSE;
#   real SSR;
#   real R2;
#   
#   for (j in 1:n_items) {
#     mu[j] = beta0 + beta1*DIFpredict[j];
#     ss_err[j] = pow((D[j]-mu[j]),2);
#     ss_reg[j] = pow((mu[j]-mean(D[])),2);
#   }
#   
#   SSE = sum(ss_err[]);
#   SSR = sum(ss_reg[]);
#   R2 = SSR/(SSR+SSE);
# }
# 
# model {
#   for (i in 1:n_people) {
#     for (j in 1:n_items) {
#       dataset[i,j] ~ bernoulli_logit(a[j]*(theta[i] - (b[j] + D[j]*group[i])));
#     }
#   }	
#   
#   a ~ lognormal(0,1);
#   b ~ normal(0,1);
# 
# // specify N(0,1) for reference group, then estimate mean, var for reference group...
#   for(i in 1:n_ref){
#     theta ~ normal(0,1);
#   }
#   for(i in n_ref_1:n_people){
#     theta ~ normal(foc_mean, 1);
#   }
#   
#   D ~ normal(mu, sigma2);
#   foc_mean ~ uniform(-10, 10);
# //  foc_var ~ uniform(0, 100);
#   beta0 ~ normal(0,1);
#   beta1 ~ normal(0,1);
#   sigma2 ~ uniform(0,100);
# }
# "
# 
# 
# #### TEST: 2PL Model -----------------------------------------------------####
# 
# stancode_2PL <- "
# data {
#   int<lower=0> n_people;
#   int<lower=0> n_items;
#   int dataset[n_people, n_items];
# }
# 
# parameters {
#   real<lower=0> a[n_items];
#   real b[n_items];
#   real theta[n_people];
# }
# model {
#   for (i in 1:n_people) {
#     for (j in 1:n_items) {
#       dataset[i,j] ~ bernoulli_logit(a[j]*(theta[i]-b[j]));
#     }
#   }	
#     
#     a ~ lognormal(0,1);
#     b ~ normal(0,1);
#   theta ~ normal(0,1);
# }
# "