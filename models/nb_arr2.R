library(caret)
library(ISLR)
library(e1071)
library(boot)
library(dplyr)
library(gbm)
library(randomForest)

set.seed(1)
path_ml_input_final = '/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_input_final/input'
k_fold_cv_idxs = read.csv('/home/hunter/ekg/afib2/k_fold_cv_idxs_arr2.csv')

ns = seq(5,30,1)
args = commandArgs(trailingOnly=TRUE)
idx = as.integer(args[[1]])
n = ns[idx]

death_cols_to_rm = c()
for (i in 1:n){
  tmp = paste('death', as.character(i), sep='')
  death_cols_to_rm = rbind(death_cols_to_rm, tmp)
}


############### Naive Bayes #################
df_ml_input = read.csv(paste(path_ml_input_final, as.character(n), '.csv', sep=''))
df_model_input = df_ml_input[, -which(names(df_ml_input) %in% c('X', 'file_name', 'rhythm'))]
df_model_input = df_model_input[, -which(names(df_model_input) %in% death_cols_to_rm)]
df_model_input$arr_flag = rep(1, nrow(df_model_input))
df_model_input$arr_flag[which(df_ml_input$rhythm=='SR')] = 0
df_model_input$arr_flag[which(df_ml_input$rhythm=='SB')] = 0
df_model_input$arr_flag[which(df_ml_input$rhythm=='ST')] = 0
df_model_input$arr_flag = factor(df_model_input$arr_flag)  

for (l in 1:k){
  test_idxs = k_fold_cv_idxs[,l]
  train_idxs = setdiff(seq(1,10605,1), test_idxs)
        
  mod = naiveBayes(arr_flag ~ ., data=df_model_input[train_idxs,])
  probs = predict(mod, df_model_input[test_idxs,], type='raw')

  path = paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_nb/arr2/probs/n', 
                   as.character(n), '_fold', as.character(l), '.csv', sep='')
  write.csv(probs, path, row.names=TRUE)

  true_path = paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_nb/arr2/nb_true_fold', as.character(l), '.csv', sep='')
  true_rhythms = df_model_input$arr_flag[test_idxs]
  write.csv(true_rhythms, true_path, row.names=TRUE)
}







