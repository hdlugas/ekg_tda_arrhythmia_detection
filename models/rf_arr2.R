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
idxs_arr = which(df_tmp$rhythm != 'SR' & df_tmp$rhythm != 'SB' & df_tmp$rhythm != 'ST')
idxs_sr = which(df_tmp$rhythm == 'SR' | df_tmp$rhythm == 'SB' | df_tmp$rhythm == 'ST')
for (i in 1:k){
  if (i < k){
    grp_idxs_arr = sample(idxs_arr, round(3323/k), replace = FALSE)
    grp_idxs_sr = sample(idxs_sr, round(7282/k), replace = FALSE)
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


############### Random Forest ###############
accuracies_rf = c()
sensitivities_rf = c()
specificities_rf = c()
PPVs_rf = c()
NPVs_rf = c()
F1s_rf = c()
ns_rf = c()
ntrees_rf = c()
mtrys_rf = c()
param_list_ntrees = c(500,1250,2000,3000)
param_list_mtrys = c(0.25, 0.5, 0.75, 1)
#param_list_ntrees = c(10)
#param_list_mtrys = c(0.1)

df_ml_input = read.csv(paste(path_ml_input_final, as.character(n), '.csv', sep=''))
df_model_input = df_ml_input[, -which(names(df_ml_input) %in% c('X', 'file_name', 'rhythm'))]
df_model_input = df_model_input %>% select(-contains('death1'))
df_model_input = df_model_input %>% select(-contains('death2'))
df_model_input = df_model_input %>% select(-contains('death3'))
df_model_input$arr_flag = rep(1, nrow(df_model_input))
df_model_input$arr_flag[which(df_ml_input$rhythm=='SR')] = 0
df_model_input$arr_flag[which(df_ml_input$rhythm=='SB')] = 0
df_model_input$arr_flag[which(df_ml_input$rhythm=='ST')] = 0
df_model_input$arr_flag = factor(df_model_input$arr_flag)
  

for (j in 1:length(param_list_ntrees)){
  ntree = param_list_ntrees[j]
  for (i in 1:length(param_list_mtrys)){
    mtry = as.integer((ncol(df_model_input) - 1) * param_list_mtrys[i])
    accuracies_tmp = c()
    sensitivities_tmp = c()
    specificities_tmp = c()
    PPVs_tmp = c()
    NPVs_tmp = c()
    F1s_tmp = c()
    for (l in 1:k){
      test_idxs = k_fold_cv_idxs[,l]
      train_idxs = setdiff(seq(1,10605,1), test_idxs)
        
      mod.rf = randomForest(arr_flag ~ ., data=df_model_input[train_idxs,], mtry=mtry, ntree=ntree)
      exp_probs = factor(predict(mod.rf, newdata = df_model_input[test_idxs,], type='prob'))
      path = paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_arr_vs_sr2/rf_probs/rf_n', 
                   as.character(n), '_ntree', as.character(ntree), '_mtry',
                   as.character(mtry), '_fold', as.character(l), '.csv', sep='')
      write.csv(exp_probs, path, row.names=TRUE)

      if (j==1 & i==1){
        true_rhythms = factor(df_model_input$arr_flag[test_idxs])
        true_path = paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_arr_vs_sr2/true/rf_true_fold', as.character(l), '.csv', sep='')
        write.csv(true_rhythms, true_path, row.names=TRUE)
      }

      exp_preds = factor(predict(mod.rf, newdata = df_model_input[test_idxs,], type='response'))
      true_preds = factor(df_model_input$arr_flag[test_idxs])
      cm = confusionMatrix(true_preds, exp_preds)$table
        
      TP = cm[1,1]
      TN = cm[2,2]
      FN = cm[1,2]
      FP = cm[2,1]
      accuracies_tmp = append(accuracies_tmp, (TP + TN) / (TP + TN + FN + FP))
      sensitivities_tmp = append(sensitivities_tmp, TP / (TP + FN))
      specificities_tmp = append(specificities_tmp, TN / (TN + FP))
      PPVs_tmp = append(PPVs_tmp, TP / (TP + FP))
      NPVs_tmp = append(NPVs_tmp, TN / (TN + FN))
      F1s_tmp = append(F1s_tmp, 2*TP / (2*TP + FP + FN))
    }
    ns_rf = rbind(ns_rf, n)
    ntrees_rf = rbind(ntrees_rf, ntree)
    mtrys_rf = rbind(mtrys_rf, mtry)
    accuracies_rf = rbind(accuracies_rf, mean(accuracies_tmp))
    sensitivities_rf = rbind(sensitivities_rf, mean(sensitivities_tmp))
    specificities_rf = rbind(specificities_rf, mean(specificities_tmp))
    PPVs_rf = append(PPVs_rf, TP / (TP + FP))
    NPVs_rf = append(NPVs_rf, TN / (TN + FN))
    F1s_rf = append(F1s_rf, 2*TP / (2*TP + FP + FN))
  }
}


df_output_rf = data.frame(n = ns_rf, ntree = ntrees_rf, mtry = mtrys_rf,
                          accuracy = accuracies_rf, 
                          sensitivity = sensitivities_rf, 
                          specificities = specificities_rf,
                          PPV = PPVs_rf, NPV = NPVs_rf, F1 = F1s_rf)
write.csv(df_output_rf, paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_arr_vs_sr2/rf/accs_rf_n', as.character(n), '.csv', sep=''), row.names = FALSE)








