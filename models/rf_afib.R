library(caret)
library(ISLR)
library(boot)
library(dplyr)
library(gbm)
library(randomForest)

set.seed(1)
path_ml_input_final = '/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_input_final/input'
k_fold_cv_idxs = read.csv('/home/hunter/ekg/afib2/k_fold_cv_idxs_afib.csv')

ns = seq(5,30,1)
args = commandArgs(trailingOnly=TRUE)
idx = as.integer(args[[1]])
n = ns[idx]


############### Random Forest ###############
param_list_ntrees = c(500,1250,2000,3000)
param_list_mtrys = c(0.25, 0.5, 0.75, 1)

df_ml_input = read.csv(paste(path_ml_input_final, as.character(n), '.csv', sep=''))
df_model_input = df_ml_input[, -which(names(df_ml_input) %in% c('X', 'file_name', 'rhythm'))]
df_model_input = df_model_input %>% select(-contains('death1'))
df_model_input = df_model_input %>% select(-contains('death2'))
df_model_input = df_model_input %>% select(-contains('death3'))
df_model_input$afib_flag = ifelse(df_ml_input$rhythm == 'AFIB', 1, 0)
df_model_input$afib_flag = factor(df_model_input$afib_flag)  

for (j in 1:length(param_list_ntrees)){
  ntree = param_list_ntrees[j]
  for (i in 1:length(param_list_mtrys)){
    mtry = as.integer((ncol(df_model_input) - 1) * param_list_mtrys[i])
    for (l in 1:k){
      test_idxs = k_fold_cv_idxs[,l]
      train_idxs = setdiff(seq(1,10605,1), test_idxs)
        
      mod.rf = randomForest(afib_flag ~ ., data=df_model_input[train_idxs,], mtry=mtry, ntree=ntree)
      exp_probs = factor(predict(mod.rf, newdata = df_model_input[test_idxs,], type='prob'))

      path = paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_probs/rf/rf_n', 
                   as.character(n), '_ntree', as.character(ntree), '_mtry',
                   as.character(mtry), '_fold', as.character(l), '.csv', sep='')
      write.csv(exp_probs, path, row.names=TRUE)

      if (j==1 & i==1){
        true_rhythms = factor(df_model_input$afib_flag[test_idxs])
        true_path = paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_probs/true/rf_true_fold', as.character(l), '.csv', sep='')
        write.csv(true_rhythms, true_path, row.names=TRUE)
      }
    }
  }
}







