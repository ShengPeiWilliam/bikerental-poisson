# Bike Sharing Demand Forecasting (Poisson)

[![Full Report](https://img.shields.io/badge/📄_Read_Full_Report-PDF-blue?style=for-the-badge)](report/bikerental_report.pdf)

Daily bike rental demand forecasting on 731 days of Capital Bikeshare data 
(Washington D.C., 2011–2012), using count regression to handle the discrete, 
non-negative nature of the response.

Starting from Poisson GLM, the model failed dispersion checks badly (raw 
variance/mean = 833; post-fit dispersion = 182.6), motivating a switch to 
Negative Binomial regression. NB2 collapsed the dispersion estimate to 
1.046 and AIC from 137K to 12K, with binned residual diagnostics moving 
from [-18, 9] back inside the 95% confidence bands. Temperature (IRR = 4.51) 
and year-over-year growth (IRR = 1.62) emerged as the dominant demand drivers.

## Motivation

This project follows up on [bikerental-ml](https://github.com/ShengPeiWilliam/bikerental-ml), 
which fit OLS, Ridge, and Lasso on the same dataset. While OLS achieved a 
strong R² of 0.827, treating bike rental counts as a continuous Gaussian 
response ignores their discrete, non-negative nature. This project explores 
whether a count-aware regression family (Poisson, Negative Binomial) provides 
better fit and more reliable inference.

The exercise follows a deliberate diagnostic chain: start with the canonical 
model (Poisson), check its assumptions, and let the data tell you when to 
move on.

## Design Decisions

**Why move to Negative Binomial?**

The Poisson assumption of equal mean and variance failed dramatically. The 
raw Variance/Mean ratio was 833, and the post-fit dispersion estimate was 
182.6. Negative Binomial (NB2) adds a dispersion parameter to absorb that 
extra variance, dropping the dispersion estimate to 1.046 and the AIC from 
137,807 to 12,193.

**Why not Zero-Inflated Poisson?**

ZIP models are designed for datasets with excess zeros, specifically days 
where no bikes are rented at all. The minimum observed count in this dataset 
is 22. There are no zeros to inflate, so ZIP is structurally inapplicable 
here.

**Why interpret coefficients as Incidence Rate Ratios?**

NB2 uses a log link, so raw coefficients represent additive changes on the 
log scale, which are not intuitive. Exponentiating them gives Incidence Rate 
Ratios (IRR), the multiplicative effect on expected count, which translates 
directly into business language ("a one-unit increase in temperature is 
associated with 4.51× higher demand").

## Key Results

**Headline finding**: Negative Binomial collapses overdispersion from 182.6 to 1.046 and AIC from 137K to 12K, with temperature (IRR = 4.51) and year-over-year growth (IRR = 1.62) as dominant demand drivers.

| Model | Dispersion | AIC | McFadden R² | CV RMSE | CV MAE |
|-------|-----------|------|-------------|---------|--------|
| Poisson | 182.596 | 137,807 | 0.805 | 1,490 | 1,143 |
| **NB2** | **1.046** | **12,193** | **0.761** | **1,660** | **1,288** |

## Reflections & Next Steps

The biggest lesson: starting with the "right" model and watching it fail 
through diagnostics is more instructive than starting with one that happens 
to work. The AIC drop from 137,807 to 12,193 made that case more convincingly 
than any textbook description could.

Next steps:
- **Compare with OLS baseline**: the [OLS version](https://github.com/ShengPeiWilliam/bikerental-ml) achieved CV RMSE of 1,166. Understanding why OLS outperforms NB2 on RMSE despite being theoretically less appropriate would be a valuable investigation.
- **Bayesian NB regression**: a Bayesian approach would quantify uncertainty around coefficient estimates, particularly useful given only two years of data where point estimates may be unstable.
- **Interaction effects**: temperature likely behaves differently across seasons. Adding `temp:season` interactions could capture more nuanced demand dynamics.

## Repository


# Bike Sharing Demand Forecasting (Poisson)

[![Full Report](https://img.shields.io/badge/📄_Read_Full_Report-PDF-blue?style=for-the-badge)](report/bikerental_report.pdf)

Daily bike rental demand forecasting on 731 days of Capital Bikeshare data 
(Washington D.C., 2011–2012), using count regression to handle the discrete, 
non-negative nature of the response.

Starting from Poisson GLM, the model failed dispersion checks badly (raw 
variance/mean = 833; post-fit dispersion = 182.6), motivating a switch to 
Negative Binomial regression. NB2 collapsed the dispersion estimate to 
1.046 and AIC from 137K to 12K, with binned residual diagnostics moving 
from [-18, 9] back inside the 95% confidence bands. Temperature (IRR = 4.51) 
and year-over-year growth (IRR = 1.62) emerged as the dominant demand drivers.

## Motivation

This project follows up on [bikerental-ml](https://github.com/ShengPeiWilliam/bikerental-ml), 
which fit OLS, Ridge, and Lasso on the same dataset. While OLS achieved a 
strong R² of 0.827, treating bike rental counts as a continuous Gaussian 
response ignores their discrete, non-negative nature. This project explores 
whether a count-aware regression family (Poisson, Negative Binomial) provides 
better fit and more reliable inference.

The exercise follows a deliberate diagnostic chain: start with the canonical 
model (Poisson), check its assumptions, and let the data tell you when to 
move on.

## Design Decisions

**Why move to Negative Binomial?**

The Poisson assumption of equal mean and variance failed dramatically. The 
raw Variance/Mean ratio was 833, and the post-fit dispersion estimate was 
182.6. Negative Binomial (NB2) adds a dispersion parameter to absorb that 
extra variance, dropping the dispersion estimate to 1.046 and the AIC from 
137,807 to 12,193.

**Why not Zero-Inflated Poisson?**

ZIP models are designed for datasets with excess zeros, specifically days 
where no bikes are rented at all. The minimum observed count in this dataset 
is 22. There are no zeros to inflate, so ZIP is structurally inapplicable 
here.

**Why interpret coefficients as Incidence Rate Ratios?**

NB2 uses a log link, so raw coefficients represent additive changes on the 
log scale, which are not intuitive. Exponentiating them gives Incidence Rate 
Ratios (IRR), the multiplicative effect on expected count, which translates 
directly into business language ("a one-unit increase in temperature is 
associated with 4.51× higher demand").

## Key Results

**Headline finding**: Negative Binomial collapses overdispersion from 182.6 to 1.046 and AIC from 137K to 12K, with temperature (IRR = 4.51) and year-over-year growth (IRR = 1.62) as dominant demand drivers.

| Model | Dispersion | AIC | McFadden R² | CV RMSE | CV MAE |
|-------|-----------|------|-------------|---------|--------|
| Poisson | 182.596 | 137,807 | 0.805 | 1,490 | 1,143 |
| **NB2** | **1.046** | **12,193** | **0.761** | **1,660** | **1,288** |

## Reflections & Next Steps

The biggest lesson: starting with the "right" model and watching it fail 
through diagnostics is more instructive than starting with one that happens 
to work. The AIC drop from 137,807 to 12,193 made that case more convincingly 
than any textbook description could.

Next steps:
- **Compare with OLS baseline**: the [OLS version](https://github.com/ShengPeiWilliam/bikerental-ml) achieved CV RMSE of 1,166. Understanding why OLS outperforms NB2 on RMSE despite being theoretically less appropriate would be a valuable investigation.
- **Bayesian NB regression**: a Bayesian approach would quantify uncertainty around coefficient estimates, particularly useful given only two years of data where point estimates may be unstable.
- **Interaction effects**: temperature likely behaves differently across seasons. Adding `temp:season` interactions could capture more nuanced demand dynamics.

## Repository

```
report/
└── bikerental_report.pdf       # Full analysis writeup
code/
├── bikerental_analysis.ipynb   # Main analysis (R notebook)
├── bikerental_analysis.R       # Clean R script
└── config.R                    # Data path configuration
```

## Tools

**Statistical methods**: Poisson GLM, Negative Binomial GLM, Rolling-origin CV, Binned residual diagnostics  
**Language**: R  
**Libraries**: MASS, arm, car, tidyr, reshape2, ggplot2

## References

Fanaee-T, H. (2013). [Bike Sharing](https://archive.ics.uci.edu/dataset/275/bike+sharing+dataset) [Dataset]. UCI Machine Learning Repository.
