# Bike Sharing Demand Forecasting (GLM)

Daily bike rental demand forecasting on the UCI Bike Sharing Dataset (731 observations, Washington D.C., 2011-2012). Starts from Poisson GLM as the textbook choice for count data, diagnoses severe overdispersion, and arrives at Negative Binomial regression as the final model.

## Motivation

In the [OLS version](https://github.com/ShengPeiWilliam/bikerental-ml) of this analysis, linear regression achieved strong predictive performance (CV RMSE = 1,166). But bike rental counts are non-negative integers, which makes Poisson regression a more natural starting point than OLS. "Theoretically appropriate" and "actually works" are different things. This project follows the diagnostic chain: start with the canonical model, check its assumptions, and let the data tell you when to move on. The goal was to practice the discipline of model selection driven by diagnostics, not defaults.

## Design Decisions

**Why move to Negative Binomial?**

The Poisson assumption of equal mean and variance failed dramatically. The raw Variance/Mean ratio was 833, and the post-fit dispersion estimate was 182.6. Negative Binomial (NB2) adds a dispersion parameter to absorb that extra variance, dropping the dispersion estimate to 1.046 and the AIC from 137,807 to 12,193.

**Why not Zero-Inflated Poisson?**

ZIP models are designed for datasets with excess zeros, specifically days where no bikes are rented at all. The minimum observed count in this dataset is 22. There are no zeros to inflate, so ZIP is structurally inapplicable here.


**How were features selected?**

Removed target leakage (casual + registered = total), screened for near-perfect correlation ($r = 0.99$ between `temp` and `atemp`), and used VIF to handle multicollinearity. The final model uses 8 predictors spanning temporal, weather, and calendar dimensions.

## Key Results

| Model | Dispersion | AIC | McFadden R² | CV RMSE | CV MAE |
|-------|-----------|------|-------------|---------|--------|
| Poisson | 182.596 | 137,807 | 0.805 | 1,490 | 1,143 |
| **NB2** | **1.046** | **12,193** | **0.761** | **1,660** | **1,288** |

The dominant predictors via Incidence Rate Ratios: temperature (IRR = 4.51, a full-range temperature increase multiplies expected rentals by 4.5x), year (IRR = 1.62, demand grew 62% from 2011 to 2012), and severe weather (IRR = 0.48, cuts demand roughly in half).

## Reflections & Next Steps

The biggest lesson: starting with the "right" model (Poisson for counts) and watching it fail is more instructive than starting with a model that happens to work. The diagnostic chain (fit, check assumptions, diagnose the violation, select the fix) is the real skill being practiced here. The jump from AIC 137,807 to 12,193 makes the case for overdispersion handling more convincingly than any textbook description could.

That said, the model has clear boundaries. The large `yr` coefficient likely reflects a 2011–2012 growth phase rather than a persistent trend, and extreme weather days are too rare in training data for reliable predictions.

If I were to continue:
- **Compare with OLS baseline**: the OLS version achieved CV RMSE of 1,166. Understanding why OLS outperforms NB2 on RMSE despite being theoretically less appropriate would be a valuable investigation.
- **Temporal structure**: the model assumes independence across days, but daily rentals clearly have momentum. Assessing residual autocorrelation and exploring ARIMA-GLM or GAM with temporal smoothing would be natural extensions.
- **Interaction effects**: temperature likely behaves differently across seasons. Interaction terms could capture these dynamics without leaving the GLM framework.

## Repository

- `report/bikerental_report.pdf` — Final report
- `code/bikerental_analysis.ipynb` — Main analysis notebook
- `code/bikerental_analysis.R` — Clean R script version
- `code/config.R` — Configuration file (data paths)

## Tools

R · MASS · arm · car · ggplot2 · reshape2 · tidyr

## References

Fanaee-T, H. (2013). Bike Sharing [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5W894
