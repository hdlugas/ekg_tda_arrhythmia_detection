library(caret)
library(ISLR)
library(boot)
library(dplyr)
library(class)

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


############### K-Nearest Neighbors ###############
accuracies = c()
sensitivities = c()
specificities = c()
PPVs = c()
NPVs = c()
F1s = c()
ns = c()
Ks = c()
param_list_Ks = c(1,2,3,4,5,6,7,8,9,10)
#param_list_Ks = c(2)

df_ml_input = read.csv(paste(path_ml_input_final, as.character(n), '.csv', sep=''))
df_model_input = df_ml_input[, -which(names(df_ml_input) %in% c('X', 'file_name', 'rhythm'))]
df_model_input = df_model_input[, -which(names(df_model_input) %in% death_cols_to_rm)]
df_model_input$afib_flag = ifelse(df_ml_input$rhythm == 'AFIB', 1, 0)
  

for (i in 1:length(param_list_Ks)){
  K = param_list_Ks[i]
  accuracies_tmp = c()
  sensitivities_tmp = c()
  specificities_tmp = c()
  PPVs_tmp = c()
  NPVs_tmp = c()
  F1s_tmp = c()
  for (l in 1:k){
    test_idxs = k_fold_cv_idxs[,l]
    train_idxs = setdiff(seq(1,10605,1), test_idxs)

    trainX = df_model_input[train_idxs, -which(names(df_model_input) %in% c('afib_flag'))]
    testX = df_model_input[test_idxs, -which(names(df_model_input) %in% c('afib_flag'))]
    trainY = df_model_input$afib_flag[train_idxs]
    testY = df_model_input$afib_flag[test_idxs]

    trainX = scale(trainX)
    testX = scale(testX)
        
    exp_preds = knn(trainX, testX, trainY, k=K)
    cm = confusionMatrix(factor(exp_preds), factor(testY))$table
    print(cm)
        
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
  Ks = rbind(Ks, K)
  accuracies = rbind(accuracies, mean(accuracies_tmp))
  sensitivities = rbind(sensitivities, mean(sensitivities_tmp))
  specificities = rbind(specificities, mean(specificities_tmp))
  PPVs = append(PPVs, TP / (TP + FP))
  NPVs = append(NPVs, TN / (TN + FN))
  F1s = append(F1s, 2*TP / (2*TP + FP + FN))
}


df_output = data.frame(n = ns, K = Ks,
                       accuracy = accuracies, 
                       sensitivity = sensitivities, 
                       specificities = specificities,
                       PPV = PPVs, NPV = NPVs, F1 = F1s)
#write.csv(df_output, paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_knn/afib/accuracies_n', as.character(n), '.csv', sep=''), row.names = FALSE)








