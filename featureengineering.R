##
## Feature Engineering
##

# Ideas: distinguish between weekends, holidays, seasons, success of store, peak sales for each item, 
# 
# How would you figure out when each item peaks in sales? 

library(timeDate)
library(parallel)
library(doParallel)
library(forecast)
library(tidyverse)
library(lubridate)

cl <- makeCluster(8)
registerDoParallel(cl)

  
store.train <- vroom::vroom("./train.csv")
store.test <- vroom::vroom("./test.csv")
store <- bind_rows(train = store.train, test = store.test, .id = 'id')

store <- store %>% mutate(month=as.factor(month(date)))



# #Looking at peak sales for each item
# a <- store %>%
#   filter(id == 'train')
#   group_by(month, item) %>% 
#   summarize(totSales = sum(sales)) 
#   # ungroup() %>% 
#   # group_by(month) %>% 
#   # summarise(peakMonth = sum(totSales))
# 
# ggplot(a, aes(x = month, y = totSales)) +
#   geom_col() +
#   facet_wrap(~item)
# 
# 
# #Feature Engineering
store <- store %>% mutate(weekend = as.numeric(isWeekend(date)))
# 
# y <- store %>% filter(id == 'train') %>% group_by(month) %>% pull(sales) %>% ts(data=., start=1, frequency=365)
# 
# store.model <- auto.arima(y=y, max.p = 5, max.q = 5, max.P = 5, max.Q = 5)
# 
# y.two <- store.train %>% filter(item==1, store==1) %>%
#   pull(sales) %>% ts(data=., start=1, frequency=365)
# 
# y.a.two <- auto.arima(y=y, max.p = 5, max.q = 5, max.P = 5, max.Q = 5)
# 
# y.three <- store.train %>% filter(item==7, store==7) %>%
#   pull(sales) %>% ts(data=., start=c(1,1), frequency=365)
# 
# y.a.three <- auto.arima(y=y, max.p = 10, max.q = 5, max.P = 10, max.Q = 10)
# 
# #For loop for storing data
# q <- as.data.frame()

list.item <- 0
tbats.preds <- list()

system.time({
  for (i in 1:max(store$item)){
    for (j in 1:max(store$store)){
      list.item <- list.item + 1
      y <- store %>% filter(id == 'train', item==i, store==j) %>%
        pull(sales) %>% msts(data=., seasonal.periods=c(7,365.25))
      tbats.mod <- tbats(y, use.box.cox = F, use.trend = F, use.arma.errors = F, use.parallel=T)
      tbats.preds[[list.item]] <- as.numeric(forecast(tbats.mod, h=90)$mean)
    }
  }
})


tbats.preds <- cbind(store.test$id, do.call("c", tbats.preds))

colnames(tbats.preds) <- c("id", "sales")

write.csv(tbats.preds, "./submission.csv", row.names = F)

stopCluster(cl)
# y <- store.train %>% filter(item==17, store==7) %>%
#   pull(sales) %>% msts(data=., seasonal.periods=c(7,365.25))
# tbats.mod <- tbats(y, use.parallel=FALSE)
# tbats.preds <- forecast(tbats.mod, h=90)