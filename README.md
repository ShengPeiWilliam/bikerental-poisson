# Bike Sharing Demand Forecasting
Daily bike rental demand forecasting using the UCI Bike Sharing Dataset (731 observations, 2011–2012). Applies Poisson GLM as the canonical count regression model, diagnoses severe overdispersion (Variance/Mean ratio = 833), and adopts Negative Binomial regression (NB2) as the final model. Zero-Inflated Poisson (ZIP) is considered but found inapplicable given the absence of zero counts.

## Key Techniques
- Feature removal: target leakage detection, correlation screening ($r = 0.99$), aliased variable identification
- Multicollinearity assessment via VIF
- Overdispersion diagnosis: raw Variance/Mean ratio and post-fit dispersion estimate (Residual Deviance / df)
- Poisson GLM with equidispersion assumption check
- Negative Binomial (NB2) regression with dispersion parameter estimation
- Coefficient interpretation via Incidence Rate Ratios
- Binned residual plots for model fit diagnostics
- Rolling-origin cross-validation (5 expanding windows) for out-of-sample RMSE and MAE
- Model comparison: AIC, BIC, Dispersion, McFadden R², CV RMSE, CV MAE

## Tools
R &bull; MASS &bull; caret &bull; arm &bull; car &bull; ggplot2 &bull; reshape2 &bull; tidyr

## Repository
- `report/bikerental_report.tex` &mdash; LaTeX source file
- `report/bikerental_report.pdf` &mdash; Final report
- `code/bikerental_analysis.ipynb` &mdash; Main analysis notebook
- `code/bikerental_analysis.R` &mdash; Clean R script version of the analysis  
- `code/config.R` &mdash; Configuration file (data paths)

## References

Fanaee-T, H. (2013). Bike Sharing [Dataset]. UCI Machine Learning Repository.
https://doi.org/10.24432/C5W894
