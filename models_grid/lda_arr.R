library(caret)
library(ISLR)
library(boot)
library(dplyr)
library(gbm)
library(randomForest)

set.seed(1)

path_ml_input_final = '/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_input_final/input'

df_tmp = read.csv(paste(path_ml_input_final, '5.csv', sep='')) 
n_sigs = 10605
k = 5
k_fold_cv_idxs = c()
idxs_all = seq(1,n_sigs,1)
idxs_arr = which(df_tmp$rhythm != 'SR')
idxs_sr = which(df_tmp$rhythm == 'SR')
for (i in 1:k){
  if (i < k){
    grp_idxs_arr = sample(idxs_arr, round(8779/k), replace = FALSE)
    grp_idxs_sr = sample(idxs_sr, round(1826/k), replace = FALSE)
    idxs_fold = append(grp_idxs_arr, grp_idxs_sr)
    idxs_arr = setdiff(idxs_arr, grp_idxs_arr)
    idxs_sr = setdiff(idxs_sr, grp_idxs_sr)
    k_fold_cv_idxs = cbind(k_fold_cv_idxs, idxs_fold)
  } else{
    grp_idxs_arr = idxs_arr
    grp_idxs_sr = idxs_sr
    idxs_fold = append(grp_idxs_arr, grp_idxs_sr)
    idxs_arr = setdiff(idxs_arr, grp_idxs_arr)
    idxs_sr = setdiff(idxs_sr, grp_idxs_sr)
    k_fold_cv_idxs = cbind(k_fold_cv_idxs, idxs_fold)
  }
}



ns = seq(5,30,1)
args = commandArgs(trailingOnly=TRUE)
idx = as.integer(args[[1]])
n = ns[idx]

death_cols_to_rm = c()
for (i in 1:n){
  tmp = paste('death', as.character(i), sep='')
  death_cols_to_rm = rbind(death_cols_to_rm, tmp)
}

############### Linear Discriminant Analysis #################
df_ml_input = read.csv(paste(path_ml_input_final, as.character(n), '.csv', sep=''))
df_model_input = df_ml_input[, -which(names(df_ml_input) %in% c('X', 'file_name', 'rhythm'))]
df_model_input = df_model_input[, -which(names(df_model_input) %in% death_cols_to_rm)]
df_model_input$arr_flag = ifelse(df_ml_input$rhythm == 'SR', 0, 1)
df_model_input$arr_flag = factor(df_model_input$arr_flag)
library(MASS)
  
ns = c()
accuracies= c()
sensitivities= c()
specificities= c()
PPVs= c()
NPVs= c()
F1s= c()

for (l in 1:k){
  test_idxs = k_fold_cv_idxs[,l]
  train_idxs = setdiff(seq(1,10605,1), test_idxs)
        
  mod.lda = lda(arr_flag ~ ., data=df_model_input[train_idxs,])
  preds_obj = predict(mod.lda, df_model_input[test_idxs,])
  probs = preds_obj$posterior
  preds = factor(preds_obj$class)

  path = paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_lda/arr/probs/n', 
                   as.character(n), '_fold', as.character(l), '.csv', sep='')
  write.csv(probs, path, row.names=TRUE)

  true_path = paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_lda/arr/lda_true_fold', as.character(l), '.csv', sep='')
  true_rhythms = df_model_input$arr_flag[test_idxs]
  write.csv(true_rhythms, true_path, row.names=TRUE)

  cm = confusionMatrix(true_rhythms, preds)$table
  
  TP = cm[1,1]
  TN = cm[2,2]
  FN = cm[1,2]
  FP = cm[2,1]
  ns = rbind(ns, n)
  accuracies = append(accuracies, (TP + TN) / (TP + TN + FN + FP))
  sensitivities = append(sensitivities, TP / (TP + FN))
  specificities = append(specificities, TN / (TN + FP))
  PPVs = append(PPVs, TP / (TP + FP))
  NPVs = append(NPVs, TN / (TN + FN))
  F1s = append(F1s, 2*TP / (2*TP + FP + FN))
}



df = data.frame(n = ns,
                accuracy = accuracies, 
                sensitivity = sensitivities, 
                specificities = specificities,
                PPV = PPVs, NPV = NPVs, F1 = F1s)
write.csv(df, paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_lda/arr/accuracies_lda_n', as.character(n), '.csv', sep=''), row.names = FALSE)









