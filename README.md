# Bike Sharing Demand Forecasting (GLM)
Daily bike rental demand forecasting on the UCI Bike Sharing Dataset (731 observations, Washington D.C., 2011–2012). Starts from Poisson GLM, diagnoses severe overdispersion, and arrives at Negative Binomial regression as the final model (McFadden R² = 0.761, CV RMSE = 1,660).

## Motivation
The [OLS version](https://github.com/ShengPeiWilliam/bikerental-ml) of this analysis achieved CV RMSE of 1,166. But bike rental counts are non-negative integers, so Poisson regression is a more natural starting point. This project follows the diagnostic chain: start with the canonical model, check its assumptions, and let the data tell you when to move on.

## Design Decisions

**Why move to Negative Binomial?**

The Poisson assumption of equal mean and variance failed dramatically. The raw Variance/Mean ratio was 833, and the post-fit dispersion estimate was 182.6. Negative Binomial (NB2) adds a dispersion parameter to absorb that extra variance, dropping the dispersion estimate to 1.046 and the AIC from 137,807 to 12,193.

**Why not Zero-Inflated Poisson?**

ZIP models are designed for datasets with excess zeros, specifically days where no bikes are rented at all. The minimum observed count in this dataset is 22. There are no zeros to inflate, so ZIP is structurally inapplicable here.

## Key Results

NB2 dramatically reduces dispersion from 182.6 to 1.046 and AIC from 137,807 to 12,193, confirming that overdispersion handling is essential for count data like this. The dominant predictors: temperature (IRR = 4.51), year (IRR = 1.62), and severe weather (IRR = 0.48).

| Model | Dispersion | AIC | McFadden R² | CV RMSE | CV MAE |
|-------|-----------|------|-------------|---------|--------|
| Poisson | 182.596 | 137,807 | 0.805 | 1,490 | 1,143 |
| **NB2** | **1.046** | **12,193** | **0.761** | **1,660** | **1,288** |


## Reflections & Next Steps

The biggest lesson: starting with the "right" model and watching it fail through diagnostics is more instructive than starting with one that happens to work. The AIC drop from 137,807 to 12,193 made that case more convincingly than any textbook description could.

If I were to continue:
- **Compare with OLS baseline**: the OLS version achieved CV RMSE of 1,166. Understanding why OLS outperforms NB2 on RMSE despite being theoretically less appropriate would be a valuable investigation.
- **Bayesian NB regression**: a Bayesian approach would quantify uncertainty around coefficient estimates, particularly useful given only two years of data where point estimates may be unstable.

## Repository

- `report/bikerental_report.pdf`: Final report
- `code/bikerental_analysis.ipynb`: Main analysis notebook
- `code/bikerental_analysis.R`: Clean R script version
- `code/config.R`: Configuration file (data paths)

## Tools

R · MASS · arm · car · ggplot2 · reshape2 · tidyr

## References

Fanaee-T, H. (2013). Bike Sharing [Dataset]. UCI Machine Learning Repository. doi:10.24432/C5W894
