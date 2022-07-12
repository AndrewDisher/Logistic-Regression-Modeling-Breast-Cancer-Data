This is a readMe file for the project, which contains an application of logistic regression classification to a breast cancer data set.

------------------------------
The Data Set -----------------
------------------------------

The data set can be found at the following link, along with a descriptions regarding the variables contained within it:
https://www.kaggle.com/datasets/uciml/breast-cancer-wisconsin-data


The data set contains a response variable, and many predictors variables (features). The response variable is a binary variable representing 
whether an individual has breast cancer or not. A value of 1 corresponds to a positive result (the individual has heart disease) and a value 
of 0 corresponds to a negative (the individual does not have heart disease). 

There are a variety of other variables that were deemed key indicators by the CDC, and each one can be found described in detail when viewing the 
Kaggle link provided above. 

-------------------------------
The Model ---------------------
-------------------------------

The model fit in this project was a simple binary logistic regression model, which was fit and evaluated using 

1) a Hoslem-Lemshowe test for goodness of fit
2) a confusion matrix showing the results of predictions (on test data)
3) sensitivity and specificity metrics (and others).

It is important to note that the sensitivity of our model was of the highest importance among the different metrics used to evaluate in (3), since 
failing to detect cases of breast cancer would be more detrimental than falsely classifying a negative case as positive, in this health related setting. 

-------------------------------
Additional Info ---------------
-------------------------------

Many, if not the majority, of the predictors/features were correlated with one another, which posed an issue in fitting a logistic regression model. In the preliminary model, using all predictors, most of the significance tests (with null hypothesis stating the predictor coefficient = 0) resulted in P-Values far above our designated alpha = .05 threshold, i.e. the predictor variables/features were insignificant. This was counterintuitive, especially since we determined that many of the predictors were highly correlated with the class variable/output variable. Consequently, Principal Compenent Analysis (PCA) was performed on the training data set, and this refining of predictors helped identify useful information to more adequately predict the class variable, resulting in a more suitable model. 
