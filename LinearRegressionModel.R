

# Set seed for reproducibility
set.seed(92265)  # Use any integer value

# Get the total number of rows in the dataset
total_rows <- nrow(filtered_data)

# Calculate the number of rows for the training set (80%)
train_size <- floor(0.8 * total_rows)

# Randomly sample row indices for the training set
train_indices <- sample(seq_len(total_rows), size = train_size)

# Split the dataset
train_data <- filtered_data[train_indices, ]  # 80% training data
test_data <- filtered_data[-train_indices, ]  # 20% test data


df_factor_encoded <- train_data

# Apply transformation only to character columns
df_factor_encoded[sapply(df_factor_encoded, is.character)] <- 
  lapply(df_factor_encoded[sapply(df_factor_encoded, is.character)], function(col) as.numeric(as.factor(col)))

df_test_encoded <- test_data

# Apply transformation only to character columns
df_test_encoded[sapply(df_test_encoded, is.character)] <- 
  lapply(df_test_encoded[sapply(df_test_encoded, is.character)], function(col) as.numeric(as.factor(col)))



model <- lm(Price ~ ., data = df_factor_encoded)


summary(model)

#residual plots
plot(fitted(model), residuals(model),
     main = "Residuals vs Fitted",
     xlab = "Fitted Values",
     ylab = "Residuals",
     pch = 20, col = "blue")
abline(h = 0, col = "red", lwd = 2) 


qqnorm(residuals(model), 
       main = "QQ Plot of Residuals", 
       xlab = "Theoretical Quantiles", 
       ylab = "Sample Quantiles", 
       pch = 20, 
       col = "blue")  # Blue points
qqline(residuals(model), 
       col = "red", 
       lwd = 2)  # Red reference line



#removing outliers using Z score
residuals_values <- residuals(model)
z_scores <- scale(residuals_values)
threshold <- 3

outliers <- abs(z_scores) > threshold
train_data_clean <- df_factor_encoded[!outliers, ]
cat("Rows before removing outliers: ", nrow(df_factor_encoded), "\n")
cat("Rows after removing outliers: ", nrow(train_data_clean), "\n")


#doing box cox 
library(MASS)
boxcox(model, lambda = seq(-2, 2, by = 0.1))

#lambda=0
train_data_clean$Price <- log(train_data_clean$Price)


model <- lm(Price ~ ., data = train_data_clean)

summary(model)

#residual plots
plot(fitted(model), residuals(model),
     main = "Residuals vs Fitted",
     xlab = "Fitted Values",
     ylab = "Residuals",
     pch = 20, col = "blue")
abline(h = 0, col = "red", lwd = 2) 


qqnorm(residuals(model), 
       main = "QQ Plot of Residuals", 
       xlab = "Theoretical Quantiles", 
       ylab = "Sample Quantiles", 
       pch = 20, 
       col = "blue")  # Blue points
qqline(residuals(model), 
       col = "red", 
       lwd = 2)  # Red reference line




library(leaps)

best_subset <- regsubsets(Price ~ ., data = train_data_clean, nbest = 1, nvmax = 16) 

best_subset_summary <- summary(best_subset)

# Extract the predictor names for each model
predictor_matrix <- best_subset_summary$which[, -1]  # Remove intercept column
predictor_names <- colnames(predictor_matrix)


selected_predictors <- apply(predictor_matrix, 1, function(row) {
  paste(predictor_names[which(row)], collapse = ", ")
})


results <- data.frame(
  ModelSize = 1:16,  # Models with 1 to 16 predictors
  AdjR2 = best_subset_summary$adjr2,
  Cp = best_subset_summary$cp,
  Predictors = selected_predictors  # Add predictor names
)

# Sort models based on Adjusted R-squared (descending) and Cp (ascending)
results_sorted <- results[order(-results$AdjR2, results$Cp), ]

# Select the top 5 models excluding the full model
top_5_models <- head(results_sorted, 5)

# Print the top 5 models
print("Top 5 Models based on Adjusted R-squared and Cp values:")
print(top_5_models)


#dropping city and State
train_data_clean <- train_data_clean[, !(colnames(train_data_clean) %in% c("City", "State"))]


library(reshape2) 
cor_matrix <- cor(select_if(train_data_clean, is.numeric))  # Only numeric columns

melted_cor <- melt(cor_matrix)

ggplot(data = melted_cor, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile(color = "white") +  # Tile with white borders
  scale_fill_gradient2(
    low = "blue", high = "red", mid = "white", midpoint = 0, 
    limit = c(-1, 1), space = "Lab", name = "Correlation"
  ) +
  geom_text(aes(label = sprintf("%.2f", value)), color = "black", size = 3) +  
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),  
    axis.title.x = element_blank(),
    axis.title.y = element_blank()
  ) +
  labs(title = "Correlation Heatmap for Sale Price and Predictors")



base_model <- lm(Price~ ., data = train_data_clean)

# Summary of the base model
summary(base_model)


interaction_model <- lm(Price ~ EngineCapacity * CylindersinEngine , data = train_data_clean)
interaction_model_2 <-lm(Price~ EngineCapacity * FuelConsumptionPer100km, data=train_data_clean)
# Summary of the interaction model


anova(base_model, interaction_model)
anova(base_model, interaction_model_2)

AIC(base_model, interaction_model)
BIC(base_model, interaction_model)


# Generate a formula-friendly string of all column names
columns_string <- paste(colnames(train_data_clean), collapse = " + ")

interaction_string <- "EngineCapacity * CylindersinEngine"

# Combine main effects and interaction terms
full_formula_string <- paste(columns_string, "+", interaction_string)

# Create the final formula
final_formula <- as.formula(paste("Price ~", full_formula_string))

# Fit the linear model
final_interaction_model <- lm(final_formula, data = train_data_clean)

# Print the summary
summary(final_interaction_model)


#final model without considering interaction()

final_base_model<-lm(Price~., data=train_data_clean)




plot(fitted(final_base_model), residuals(final_base_model),
     main = "Residuals vs Fitted",
     xlab = "Fitted Values",
     ylab = "Residuals",
     pch = 20, col = "blue")
abline(h = 0, col = "red", lwd = 2) 


qqnorm(residuals(final_base_model), 
       main = "QQ Plot of Residuals", 
       xlab = "Theoretical Quantiles", 
       ylab = "Sample Quantiles", 
       pch = 20, 
       col = "blue")  # Blue points
qqline(residuals(final_base_model), 
       col = "red", 
       lwd = 2)  # Red reference line


summary(final_base_model)



#Testing on test data 

df_test_encoded <- df_test_encoded[, !(colnames(test_data) %in% c("City", "State"))]

df_test_encoded$Price<-test_data$Price


predictions <- predict(final_base_model, newdata = df_test_encoded)
predictions<-exp(predictions)
# Calculate Mean Squared Error (MSE)
actual_prices <- df_test_encoded$Price
mse <- mean((predictions - actual_prices)^2)

# Print the MSE
cat("Mean Squared Error (MSE):", mse, "\n")





######################################################

confidence_intervals <- predict(base_model, 
                                 newdata = test_data[1:3, ], 
                                 interval = "confidence", 
                                 level = 0.95)  # 95% confidence level

# Compute predictions with prediction intervals for the 1st, 2nd, and 3rd rows
prediction_intervals <- predict(base_model, 
                                 newdata = test_data[1:3, ], 
                                 interval = "prediction", 
                                 level = 0.95)  # 95% prediction level

# Combine the results into a data frame
results_specific <- data.frame(
  Row = 1:3,
  Predicted = prediction_intervals[, "fit"],
  Confidence_Lower = confidence_intervals[, "lwr"],
  Confidence_Upper = confidence_intervals[, "upr"],
  Prediction_Lower = prediction_intervals[, "lwr"],
  Prediction_Upper = prediction_intervals[, "upr"]
)