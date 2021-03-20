# Store-Item-Demand-Forecasting

a.	What is the overall purpose of this project?
  This project was an attempt to learn new coding skills and apply them to a time-series data set.

b.	What do each file in your repository do?
  test.csv and train.csv are the data sets
  submission.csv is the table of values forecasted by the model I built.
  featureengineering.R is where I have all the code I wrote.

c.	What methods did you use to clean the data or do feature engineering?
  I created two new variables: month, and weekend. I made month a factor and weekend numeric. 
  This didn't have any effect the outcome.
  

d.	What methods did you use to generate predictions?
  I explored the tbats package. It worked well.