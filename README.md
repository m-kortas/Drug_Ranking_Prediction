# Drugs_Ranking_Prediction
Drugs Ranking Prediction based on Machine Learning model and comments' sentiment analysis


The dataset provides patient reviews on specific drugs along with related conditions. Furthermore, reviews are grouped into reports on the three aspects benefits, side effects and overall comment. Additionally, ratings are available concerning overall satisfaction as well as a 5 step side effect rating and a 5 step effectiveness rating. The data was obtained by crawling online pharmaceutical review sites. 

Attribute Information:

1. urlDrugName (categorical): name of drug 
2. condition (categorical): name of condition 
3. benefitsReview (text): patient on benefits 
4. sideEffectsReview (text): patient on side effects 
5. commentsReview (text): overall patient comment 
6. rating (numerical): 10 star patient rating 
7. sideEffects (categorical): 5 step side effect rating 
8. effectiveness (categorical): 5 step effectiveness rating

Data source: https://archive.ics.uci.edu/ml/datasets/Drug+Review+Dataset+%28Druglib.com%29

Files descriptions:

```bash
machine_learning_prediction.ipynb # prediction of ranking based on sentiment values (Python, Machine Learning)
sentiment_test.Rmd # NLP analysis based on comments of test data (R, ggplot, NLP)
sentiment_train.Rmd # NLP analysis based on comments of training data (R, ggplot, NLP)
shiny_data.Rmd # Analysis for shiny visualisation App (R, ggplot)
  
shiny_data.csv # Data for shiny visualisation App
test_data.tsv # Raw test data
training_data.tsv # Raw training data

test_data_final.csv # Test data with sentiment values 
training_data_final.csv # Training data with sentiment values 
```
