submissions="IRT_DIF_rho04_pref05_mu05_alpha085_job.sh IRT_DIF_rho06_pref05_mu05_alpha085_job.sh IRT_DIF_rho08_pref05_mu05_alpha085_job.sh IRT_DIF_rho04_pref09_mu05_alpha085_job.sh IRT_DIF_rho06_pref09_mu05_alpha085_job.sh IRT_DIF_rho08_pref09_mu05_alpha085_job.sh IRT_DIF_rho04_pref05_mu1_alpha085_job.sh IRT_DIF_rho06_pref05_mu1_alpha085_job.sh IRT_DIF_rho08_pref05_mu1_alpha085_job.sh IRT_DIF_rho04_pref09_mu1_alpha085_job.sh IRT_DIF_rho06_pref09_mu1_alpha085_job.sh IRT_DIF_rho08_pref09_mu1_alpha085_job.sh IRT_DIF_rho04_pref05_mu05_alpha09_job.sh IRT_DIF_rho06_pref05_mu05_alpha09_job.sh IRT_DIF_rho08_pref05_mu05_alpha09_job.sh IRT_DIF_rho04_pref09_mu05_alpha09_job.sh IRT_DIF_rho06_pref09_mu05_alpha09_job.sh IRT_DIF_rho08_pref09_mu05_alpha09_job.sh IRT_DIF_rho04_pref05_mu1_alpha09_job.sh IRT_DIF_rho06_pref05_mu1_alpha09_job.sh IRT_DIF_rho08_pref05_mu1_alpha09_job.sh IRT_DIF_rho04_pref09_mu1_alpha09_job.sh IRT_DIF_rho06_pref09_mu1_alpha09_job.sh IRT_DIF_rho08_pref09_mu1_alpha09_job.sh IRT_DIF_rho04_pref05_mu05_alpha095_job.sh IRT_DIF_rho06_pref05_mu05_alpha095_job.sh IRT_DIF_rho08_pref05_mu05_alpha095_job.sh IRT_DIF_rho04_pref09_mu05_alpha095_job.sh IRT_DIF_rho06_pref09_mu05_alpha095_job.sh IRT_DIF_rho08_pref09_mu05_alpha095_job.sh IRT_DIF_rho04_pref05_mu1_alpha095_job.sh IRT_DIF_rho06_pref05_mu1_alpha095_job.sh IRT_DIF_rho08_pref05_mu1_alpha095_job.sh IRT_DIF_rho04_pref09_mu1_alpha095_job.sh IRT_DIF_rho06_pref09_mu1_alpha095_job.sh IRT_DIF_rho08_pref09_mu1_alpha095_job.sh"
for submission in $submissions
do
  msub $submission
done