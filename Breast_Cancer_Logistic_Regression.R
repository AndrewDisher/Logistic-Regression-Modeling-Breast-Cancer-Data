# Creator:        Andrew Disher
# Affiliation:    UMASS Dartmouth
# Course:         CIS-530 Advanced Data Mining
# Assignment:     Final Project
# Date:           4/23/2022
#
# TASK: Fit a binomial logistic regression model and perform diagnostics on the Breast Cancer Data Set. Then 
#       evaluate the performance of the final model. 
#
# Data Source: 
#
# Breast Cancer Wisconsin (Diagnostic) Data Set
# https://www.kaggle.com/datasets/uciml/breast-cancer-wisconsin-data


# Packages
library(car) # For cumsum() function; computes the cumulative sum of a vector
library(caret) # For Confusion matrix creation
library(pROC) # For creating an ROC curve and calculating Area Under Curve
library(ResourceSelection) # For goodness of fit test for the Logistic Regression model


# -------------------------------------------------------------------------
# Import the data ---------------------------------------------------------
# -------------------------------------------------------------------------

Breast_Cancer_Data_Set <- read.csv("~/UMASS Dartmouth/Classes/Spring 2022/Data Mining/Project/Data Sets/Breast Cancer Data Set/Breast_Cancer_Data_Set.csv")

# Remove the first column (X ~ it is an ID column)
Breast_Cancer_Data_Set <- Breast_Cancer_Data_Set[, -1]


# -------------------------------------------------------------------------
# Create Training/Testing Data Sets ---------------------------------------
# -------------------------------------------------------------------------

# Split Data into Training and Testing in R 
sample_size = floor(0.8*nrow(Breast_Cancer_Data_Set))
set.seed(666)

# Randomly split data
picked = sample(seq_len(nrow(Breast_Cancer_Data_Set)), size = sample_size)

# Store the Training and Testing data in their respective data frames
Training_Data <- Breast_Cancer_Data_Set[picked, ]
Test_Data <- Breast_Cancer_Data_Set[-picked, ]


# -------------------------------------------------------------------------
# Create a preliminary logistic regression model using all predictors -----
# -------------------------------------------------------------------------

Model1 <- glm(diagnosis ~., data = Training_Data, family=binomial(link = "logit"))
summary(Model1)


# NOTE: It appears that none of the predictor variables are significant, since all of their coefficient eastimates' 
#       p-values are extremely close to 1. However, this does NOT mean that none of the predictors are useful in 
#       predicting the diagnosis response variable. It is obvious from the residual deviance that using ALL of these
#       features is producing a model that perfectly fits the data, since the deviance is near 0.
#    
#       This model is heavily overfitting the data set, and many of these variables can be removed. 


# Since all of our predictor variables are continuous, we have the luxury of being able to create a correlation matrix
# to examine collinearity. This is done below. 

# Correlation Matrix
corMatrix <- cor(Training_Data[, 2:31])
View(corMatrix)

# NOTE: Clearly, there exists substantial multicollinearity within our predictors. Again, since we have all continuous
#       predictor variables, we can calculate the variance inflation factor (VIF) for each of the predictors. This is
#       done below. 


# -------------------------------------------------------------------------
# Acquire the VIF Scores for each of the predictors -----------------------
# -------------------------------------------------------------------------

vif_values <- vif(Model1)

data.frame(Predictors = colnames(Training_Data[, 2:31]), 
           VIF = vif_values)

# NOTE: Again, many of the variables are highly correlated, according to their VIF values. It is not possible
#       to choose some of the predictors over others according to their VIF scores, since it appears that they
#       are all correlated with at least 1 other variable. Therefore, it will be necessary to perform PCA on 
#       the set of predictor variables. 


# -------------------------------------------------------------------------
# Perform PCA on the training data predictors -----------------------------
# -------------------------------------------------------------------------

Training_Data_PCA <- prcomp(Training_Data[, 2:31], center = TRUE, scale. = TRUE)

summary(Training_Data_PCA)

# NOTE: Out of a total of 30 principal components, we see that by using only a few of the principal components
#       we can account for much of the variation in the data set. To decide how many to include, we should 
#       create the following plots:

# Obtain a vector for the percent explained variances
var_explained = Training_Data_PCA$sdev^2 / sum(Training_Data_PCA$sdev^2)

# Plot Proportion of variance explaiend by component
plot(c(1:15), var_explained[1:15], type = 'b', ylab = 'Proportion', 
     xlab = 'Principal Component Index', main = 'Proportion of Variance Explaiend by Component')

# Plot Cumulative Proportion of variance explained
plot(c(1:15), cumsum(var_explained[1:15]), type = 'b', ylab = 'Cumulative Proportion', 
     xlab = 'Principal Component Index', main = 'Cumulative Proportion of Variance Explaiend')

# Add lines to indicate certain noteworthy components
abline(h = .8927777, col = 'red', lty = 'dashed')
abline(v = 6, col = 'red', lty = 'dashed')
abline(h = .9540241, col = 'blue', lty = 'dashed')
abline(v = 10, col = 'blue', lty = 'dashed')

# Include arrows for clarity
arrows(x0 = 8, 
       y0 = .7, 
       x1 = 6.1, 
       y1 = .8827777)

arrows(x0 = 12, 
       y0 = .8, 
       x1 = 10.1, 
       y1 = .95)

# Add annotations
text(x = 8, y = .65, # Coordinates
     label = "6 PCs explain 89.27% \n of total variance")

text(x = 12, y = .75, # Coordinates
     label = "10 PCs explain 95.40% \n of total variance")


# NOTE: We notice that much of the variance is explained by including just 6 components, and including 10 will
#       bring us to a very comfortable threshold. We can try using between 6 and 10 principal components in our
#       regression models, and make our decision which number to include based on our prediction results. 



# -------------------------------------------------------------------------
# Fitting Models Using Data Set with Reduced Dimensions -------------------
# -------------------------------------------------------------------------

# First, create a data frame that contains the labels for the training data and principal components.
PCA_Data_Frame <- cbind(data.frame(diagnosis = Training_Data$diagnosis), Training_Data_PCA$x)
PCA_Data_Frame

# First, fit a model with 6 PCs
Model2 <- glm(diagnosis ~., data = PCA_Data_Frame[, 1:7], family=binomial(link = "logit"))
summary(Model2)

# Goodness of fit test for model with 6 PCs
hoslem.test(Training_Data$diagnosis, fitted(Model2))
# X-squared = 0.82595, df = 8, p-value = 0.9991
# Model2 is very suitable for our data

# -------------------------------------------------------------------------

# First, fit a model with 7 PCs
Model3 <- glm(diagnosis ~., data = PCA_Data_Frame[1:8], family=binomial(link = "logit"))
summary(Model3)

# Goodness of fit test for model with 7 PCs
hoslem.test(Training_Data$diagnosis, fitted(Model3))
# X-squared = 0.82595, df = 8, p-value = 0.9085
# Model2 is very suitable for our data

# -------------------------------------------------------------------------

# First, fit a model with 8 PCs
Model4 <- glm(diagnosis ~., data = PCA_Data_Frame[1:9], family=binomial(link = "logit"))
summary(Model4)

# Goodness of fit test for model with 8 PCs
hoslem.test(Training_Data$diagnosis, fitted(Model4))
# X-squared = 0.82595, df = 8, p-value = 0.9991
# Model2 is very suitable for our data

# -------------------------------------------------------------------------

# First, fit a model with 9 PCs
Model5 <- glm(diagnosis ~., data = PCA_Data_Frame[1:10], family=binomial(link = "logit"))
summary(Model5)

# Goodness of fit test for model with 9 PCs
hoslem.test(Training_Data$diagnosis, fitted(Model5))
# X-squared = 0.82595, df = 8, p-value = 0.9912
# Model2 is very suitable for our data

# -------------------------------------------------------------------------

# First, fit a model with 10 PCs
Model6 <- glm(diagnosis ~., data = PCA_Data_Frame[1:11], family=binomial(link = "logit"))
summary(Model6)

# Goodness of fit test for model with 10 PCs
hoslem.test(Training_Data$diagnosis, fitted(Model6))
# X-squared = 0.82595, df = 8, p-value = 0.9871
# Model2 is very suitable for our data


# Conclusion about model fitting: The more principal components we include does improve the model, according
#                                 to the AIC (sometimes) and the deviance, however, each of the models that use
#                                 more than 6 PCs have insignificant predictors. These models may not generalize 
#                                 well, so we will choose the model with 6 PCs (Model2).




# -------------------------------------------------------------------------
# Computing Evaluation Metrics --------------------------------------------
# -------------------------------------------------------------------------

# Transform the predictor variables in the test data set using rotation matrix produced by our PCA analysis
Test_Data_X <- predict(Training_Data_PCA, newdata = Test_Data[, -1])
Test_Data_X <- as.data.frame(Test_Data_X)

# Using Model with 6 principal components, predict the response variable diagnosis with test set
Test_Predictions <- round(predict(Model2, Test_Data_X, type = 'response'))

# Compare predicted and test labels, and produce accuracy
number_correct = 0
for (value in 1:(length(Test_Predictions))) {
    if(Test_Data[value, 1] == Test_Predictions[value]){
      
      number_correct = number_correct + 1
      
      }
  }

accuracy = number_correct/length(Test_Predictions)
accuracy # 96.49123%

# Produce a confusion matrix for the predictions
Confusion_Matrix <- confusionMatrix(data = as.factor(Test_Predictions), reference = as.factor(Test_Data$diagnosis), 
                                    positive = c("1"))
Confusion_Matrix
Confusion_Matrix$byClass
Confusion_Matrix$table

# Sensitivity/Recall
Recall = 46/(46+2) # 0.9583333

# Precision
Precision = 46/(46+2) # 0.9583333

# F1-Measure (weight Recall and Precision equally)
2*((Precision*Recall)/((1*Precision) + Recall)) # 0.9583333

# F2-Measure (weight Recall Higher than Precision)
5*((Precision*Recall)/((4*Precision) + Recall)) # 0.9583333

# Creating an ROC curve and calculating area under curve (using test predictions before rounding)
roc_score = roc(Test_Data$diagnosis, predict(Model2, Test_Data_X, type = 'response'))
roc_score$auc
plot(roc_score ,main ="ROC curve -- BreastCancer -- Logistic Regression ",legacy.axes = TRUE)




# Computing the cost of our final model (for comparison with other models/types of models, using a predetermined cost matrix)

# create a cost matrix to visualize
matrix(c(0, 1, 100, -1), nrow = 2, ncol = 2)

# Computing cost
0*64 + 1*2 + 100*2 + -1*46
