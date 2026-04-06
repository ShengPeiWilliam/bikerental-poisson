# ============================================================
# Bike Sharing Demand Forecasting
# Count Regression: Poisson and Negative Binomial (NB2)
# ============================================================

# ---- Libraries ----
library(car)
library(caret)
library(tidyr)
library(reshape2)
library(arm)
library(MASS)
library(pscl)
library(ggplot2)
source("config.R")

# ============================================================
# Data
# ============================================================

# ---- Load Data ----
bike.data <- read.csv(DAY_DATA)
str(bike.data)

result.na <- data.frame(
  Total_Observations = nrow(bike.data),
  Missing_Values     = sum(is.na(bike.data))
)
print(result.na, row.names = FALSE)

# ---- Preprocessing ----
preprocess <- function(df) {
  df$instant    <- NULL
  df$dteday     <- NULL
  df$casual     <- NULL
  df$registered <- NULL

  df$season     <- factor(df$season, levels = 1:4,
                          labels = c("Winter", "Spring", "Summer", "Fall"))
  df$yr         <- as.factor(df$yr)
  df$mnth       <- as.factor(df$mnth)
  df$holiday    <- factor(df$holiday,    levels = c(0, 1))
  df$weekday    <- factor(df$weekday,    levels = 0:6)
  df$workingday <- factor(df$workingday, levels = c(0, 1))
  df$weathersit <- as.factor(df$weathersit)

  return(df)
}

bike.data <- preprocess(bike.data)

check_missing <- function(df, df.name = "") {
  missing.idx <- which(!complete.cases(df))
  cat(df.name, ": Found", length(missing.idx), "missing rows\n")
  if (length(missing.idx) > 0) print(df[missing.idx, ], row.names = FALSE)
  invisible(missing.idx)
}

check_missing(bike.data, "bike.data")

# ============================================================
# Exploratory Data Analysis
# ============================================================

# ---- Feature Distribution ----
ggplot(bike.data, aes(x = cnt)) +
  geom_histogram(fill = "steelblue", bins = 30) +
  labs(title = "Distribution of Daily Bike Rentals",
       x = "", y = "Frequency")

ggplot(bike.data, aes(x = season, y = cnt, fill = season)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Bike Rentals by Season", x = "Season", y = "Count") +
  theme(legend.position = "none")

ggplot(bike.data, aes(x = yr, y = cnt, fill = yr)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Bike Rentals by Year", x = "Year", y = "Count") +
  theme(legend.position = "none")

ggplot(bike.data, aes(x = mnth, y = cnt, fill = mnth)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Bike Rentals by Month", x = "Month", y = "Count") +
  theme(legend.position = "none")

cat.group2 <- c("weathersit", "holiday", "weekday", "workingday")

df.cat2 <- pivot_longer(
  data = bike.data[, c("cnt", cat.group2)],
  cols = -cnt,
  names_to = "feature",
  values_to = "value",
  values_transform = list(value = as.character)
)

df.cat2$value <- factor(df.cat2$value,
                        levels = as.character(sort(unique(as.numeric(df.cat2$value)))))

ggplot(df.cat2, aes(x = value, y = cnt, fill = value)) +
  geom_boxplot(alpha = 0.7) +
  facet_wrap(~feature, scales = "free_x") +
  labs(title = "Bike Rentals by Weather and Day Type",
       x = "", y = "Count") +
  theme(legend.position = "none")

# ---- Numeric Features ----
numeric.features <- c("temp", "atemp", "hum", "windspeed")

df.num.long <- pivot_longer(data = bike.data[, c("cnt", numeric.features)],
                            cols = -cnt,
                            names_to = "feature",
                            values_to = "value")

ggplot(df.num.long, aes(x = value, y = cnt)) +
  geom_point(alpha = 0.3, color = "steelblue") +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  facet_wrap(~feature, scales = "free_x") +
  labs(title = "Bike Rentals vs Numeric Features",
       x = "", y = "Count")

# ---- Feature Correlation ----
numeric.features <- c("temp", "atemp", "hum", "windspeed", "cnt")
cor.data <- bike.data[, numeric.features]

cor.matrix <- cor(cor.data, use = "complete.obs")
cor.melted <- melt(cor.matrix)

ggplot(cor.melted, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile() +
  geom_text(aes(label = round(value, 2)), size = 3, color = "white") +
  scale_fill_gradient2(low = "grey90", mid = "steelblue", high = "navy",
                       midpoint = 0, limits = c(-1, 1)) +
  labs(title = "Correlation Matrix", x = "", y = "") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# ---- Multicollinearity Check (VIF) ----
compute_vif <- function(data) {
  lm.proxy <- lm(cnt ~ . - atemp - mnth - workingday, data = data)
  vif.result <- vif(lm.proxy)
  vif.data <- data.frame(
    Feature = rownames(vif.result),
    VIF     = round(vif.result[, 1], 3)
  )
  print(vif.data, row.names = FALSE)
  invisible(vif.data)
}

compute_vif(bike.data)

# ============================================================
# Modelling
# ============================================================

# ---- Poisson GLM: Dispersion Check (Raw Data) ----
result.dispersion <- data.frame(
  Metric = c("Mean", "Variance", "Variance/Mean Ratio"),
  Value  = c(mean(bike.data$cnt), var(bike.data$cnt),
             var(bike.data$cnt) / mean(bike.data$cnt))
)
print(result.dispersion, row.names = FALSE)

# ---- Poisson GLM: Model Fitting ----
poisson.model <- glm(cnt ~ season + yr + holiday + weekday +
                       weathersit + temp + hum + windspeed,
                     data = bike.data,
                     family = poisson(link = "log"))

summary(poisson.model)

# ---- Poisson GLM: Dispersion Check (Model) ----
result.dispersion.model <- data.frame(
  Metric = c("Residual Deviance", "Degrees of Freedom", "Dispersion Estimate"),
  Value  = c(
    round(poisson.model$deviance, 3),
    poisson.model$df.residual,
    round(poisson.model$deviance / poisson.model$df.residual, 3)
  )
)
print(result.dispersion.model, row.names = FALSE)

# ---- Poisson GLM: Binned Residual Plot ----
binnedplot(fitted(poisson.model),
           resid(poisson.model, type = "pearson"),
           main = "Binned Residual Plot - Poisson",
           xlab = "Fitted Values",
           ylab = "Average Pearson Residuals")

# ---- Negative Binomial (NB2): Model Fitting ----
nb.model <- glm.nb(cnt ~ season + yr + holiday + weekday +
                     weathersit + temp + hum + windspeed,
                   data = bike.data)

summary(nb.model)

null_dev   <- nb.model$null.deviance
resid_dev  <- nb.model$deviance
mcfadden_r2 <- 1 - (resid_dev / null_dev)
round(mcfadden_r2, 3)

# ---- Negative Binomial (NB2): Dispersion Check ----
result.dispersion.nb <- data.frame(
  Metric = c("Residual Deviance", "Degrees of Freedom", "Dispersion Estimate"),
  Value  = c(
    round(nb.model$deviance, 3),
    nb.model$df.residual,
    round(nb.model$deviance / nb.model$df.residual, 3)
  )
)
print(result.dispersion.nb, row.names = FALSE)

# ---- Negative Binomial (NB2): Binned Residual Plot ----
binnedplot(fitted(nb.model),
           resid(nb.model, type = "pearson"),
           main = "Binned Residual Plot - NB2",
           xlab = "Fitted Values",
           ylab = "Average Pearson Residuals")

# ---- Negative Binomial (NB2): Actual vs Predicted ----
pred.nb <- predict(nb.model, type = "response")

result.pred <- data.frame(
  actual    = bike.data$cnt,
  predicted = round(pred.nb, 0)
)

ggplot(result.pred, aes(x = actual, y = predicted)) +
  geom_point(alpha = 0.4, color = "steelblue") +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Actual vs Predicted (Negative Binomial)",
       x = "Actual Count", y = "Predicted Count") +
  theme_minimal()

# ---- Negative Binomial (NB2): IRR Table ----
result.irr <- data.frame(
  Variable = names(coef(nb.model)),
  IRR      = round(exp(coef(nb.model)), 3),
  CI_Lower = round(exp(confint(nb.model))[, 1], 3),
  CI_Upper = round(exp(confint(nb.model))[, 2], 3)
)
print(result.irr, row.names = FALSE)

# ============================================================
# Model Comparison
# ============================================================

# ---- In-Sample Metrics ----
result.compare <- data.frame(
  Model       = c("Poisson", "NB2"),
  AIC         = c(round(AIC(poisson.model), 2),
                  round(AIC(nb.model), 2)),
  BIC         = c(round(BIC(poisson.model), 2),
                  round(BIC(nb.model), 2)),
  Dispersion  = c(round(poisson.model$deviance / poisson.model$df.residual, 3),
                  round(nb.model$deviance / nb.model$df.residual, 3)),
  McFadden_R2 = c(round(1 - poisson.model$deviance / poisson.model$null.deviance, 3),
                  round(1 - nb.model$deviance / nb.model$null.deviance, 3))
)
print(result.compare, row.names = FALSE)

# ---- Rolling-Origin CV: RMSE and MAE ----
train_sizes <- floor(seq(0.6, 0.9, length.out = 5) * nrow(bike.data))

cv.results.poisson <- sapply(train_sizes, function(n) {
  train.data <- bike.data[1:n, ]
  test.data  <- bike.data[(n+1):nrow(bike.data), ]
  fit  <- glm(cnt ~ season + yr + holiday + weekday +
                weathersit + temp + hum + windspeed,
              data = train.data, family = poisson(link = "log"))
  pred <- predict(fit, newdata = test.data, type = "response")
  c(RMSE = sqrt(mean((test.data$cnt - pred)^2)),
    MAE  = mean(abs(test.data$cnt - pred)))
})

cv.results.nb <- sapply(train_sizes, function(n) {
  train.data <- bike.data[1:n, ]
  test.data  <- bike.data[(n+1):nrow(bike.data), ]
  fit  <- glm.nb(cnt ~ season + yr + holiday + weekday +
                   weathersit + temp + hum + windspeed,
                 data = train.data)
  pred <- predict(fit, newdata = test.data, type = "response")
  c(RMSE = sqrt(mean((test.data$cnt - pred)^2)),
    MAE  = mean(abs(test.data$cnt - pred)))
})

result.cv <- data.frame(
  Model   = c("Poisson", "NB2"),
  CV_RMSE = round(c(rowMeans(cv.results.poisson)["RMSE"],
                    rowMeans(cv.results.nb)["RMSE"]), 3),
  CV_MAE  = round(c(rowMeans(cv.results.poisson)["MAE"],
                    rowMeans(cv.results.nb)["MAE"]), 3)
)
print(result.cv, row.names = FALSE)
