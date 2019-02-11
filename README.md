# Drugs_Ranking_Prediction
Drugs Ranking Prediction based on Machine Learning model and comments' sentiment analysis

The dataset provides patient reviews on specific drugs along with related conditions. Furthermore, reviews are grouped into reports on the three aspects benefits, side effects and overall comment. Additionally, ratings are available concerning overall satisfaction as well as a 5 step side effect rating and a 5 step effectiveness rating. The data was obtained by crawling online pharmaceutical review sites. 

# Attribute Information:

1. urlDrugName (categorical): name of drug 
2. condition (categorical): name of condition 
3. benefitsReview (text): patient on benefits 
4. sideEffectsReview (text): patient on side effects 
5. commentsReview (text): overall patient comment 
6. rating (numerical): 10 star patient rating 
7. sideEffects (categorical): 5 step side effect rating - changed to 1 to 5 rating (numerical)
8. effectiveness (categorical): 5 step effectiveness rating  - changed to 1 to 5 rating (numerical)

# Attributes built during Natural Language Processing: 

1. sideEff_num/SideEffectsSentiment (numerical) - sentiment of sideEffectsReview (from 0 to 10)
2. eff_num/BenefitsSentiment (numerical) - sentiment of benefitsReview (from 0 to 10)
3. ReviewSentiment (numerical) - sentiment of commentsReview (from 0 to 10)
4. full_commentSentiment - sentiment of merged sideEffectsReview, benefitsReview and commentsReview (from 0 to 10) 
5. sideEffects (numerical) - changed from categorical to 1 to 5 rating 
6. effectiveness (numerical) - changed from categorical to 1 to 5 rating 

# Machine Learning Model

There final model built to predict rating (based on attributes: sideEff_num, eff_num, full_commentSentiment and condition) was Random Forest Regressor due to his smallest RMSLE error (in comparison to other models tried on data). The regressor's parameters were chosen with the help of TPOT (The Tree-Based Pipeline Optimization Tool). 

Data source: https://archive.ics.uci.edu/ml/datasets/Drug+Review+Dataset+%28Druglib.com%29

# Files descriptions:

```bash
machine_learning_prediction.ipynb # prediction of ranking based on sentiment values (Python, Machine Learning)
sentiment_test.Rmd # NLP analysis based on comments of test data (R, ggplot, NLP)
sentiment_train.Rmd # NLP analysis based on comments of training data (R, ggplot, NLP)
shiny_data.Rmd # Analysis for shiny visualisation App (R, ggplot)
drugs_emotions.Rmd # Emotions analysis of drugs from test data (R, ggplot, NLP, wordloud)
app.R # Shiny Application 
  
shiny_data.csv # Data for shiny visualisation App
test_data.tsv # Raw test data
training_data.tsv # Raw training data

test_data_final.csv # Test data with sentiment values 
training_data_final.csv # Training data with sentiment values 
```
