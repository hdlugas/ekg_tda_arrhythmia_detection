library(caret)
library(ISLR)
library(boot)
library(dplyr)
library(e1071)
library(class)


set.seed(1)

path_ml_input_final = '/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_input_final/input'

df_tmp = read.csv(paste(path_ml_input_final, '5.csv', sep='')) 
n_sigs = 10605
k = 5
k_fold_cv_idxs = c()
idxs_all = seq(1,n_sigs,1)
idxs_afib = which(df_tmp$rhythm == 'AFIB')
idxs_nonafib = which(df_tmp$rhythm != 'AFIB')
for (i in 1:k){
  grp_idxs_afib = sample(idxs_afib, round(1780/k), replace = FALSE)
  grp_idxs_nonafib = sample(idxs_nonafib, round(8825/k), replace = FALSE)
  idxs_fold = append(grp_idxs_afib, grp_idxs_nonafib)
  idxs_afib = setdiff(idxs_afib, grp_idxs_afib)
  idxs_nonafib = setdiff(idxs_nonafib, grp_idxs_nonafib)
  k_fold_cv_idxs = cbind(k_fold_cv_idxs, idxs_fold)
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


ns = c()
Ds = c()
accuracies = c()
sensitivities = c()
specificities = c()
PPVs = c()
NPVs = c()
F1s = c()
param_list_degrees = c(2,3,4,5)

df_ml_input = read.csv(paste(path_ml_input_final, as.character(n), '.csv', sep=''))
df_model_input = df_ml_input[, -which(names(df_ml_input) %in% c('X', 'file_name', 'rhythm'))]
df_model_input = df_model_input[, -which(names(df_model_input) %in% death_cols_to_rm)]
df_model_input$afib_flag = ifelse(df_ml_input$rhythm == 'AFIB', 1, 0)
df_model_input$afib_flag = factor(df_model_input$afib_flag)
  
accuracies_tmp = c()
sensitivities_tmp = c()
specificities_tmp = c()
PPVs_tmp = c()
NPVs_tmp = c()
F1s_tmp = c()

for (i in 1:length(param_list_degrees)){
  D = param_list_degrees[i]
  for (l in 1:k){
    test_idxs = k_fold_cv_idxs[,l]
    train_idxs = setdiff(seq(1,10605,1), test_idxs)

    mod = svm(afib_flag ~ ., data=df_model_input[train_idxs,], kernel='polynomial', degree=D)
    preds = predict(mod, df_model_input[test_idxs,])

    cm = confusionMatrix(preds, df_model_input$afib_flag[test_idxs])$table
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
  ns = rbind(ns, n)
  Ds = rbind(Ds, D)
  accuracies = rbind(accuracies, mean(accuracies_tmp))
  sensitivities = rbind(sensitivities, mean(sensitivities_tmp))
  specificities = rbind(specificities, mean(specificities_tmp))
  PPVs = append(PPVs, TP / (TP + FP))
  NPVs = append(NPVs, TN / (TN + FN))
  F1s = append(F1s, 2*TP / (2*TP + FP + FN))
}


df_output = data.frame(n = ns, degree = Ds,
                       accuracy = accuracies, 
                       sensitivity = sensitivities, 
                       specificities = specificities,
                       PPV = PPVs, NPV = NPVs, F1 = F1s)
write.csv(df_output, paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_svm_poly/afib/accuracies_n', as.character(n), '.csv', sep=''), row.names = FALSE)







