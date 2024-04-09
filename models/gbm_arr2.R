library(caret)
library(ISLR)
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


############### Gradient Boosted Model ###############
accuracies_gbm = c()
sensitivities_gbm = c()
specificities_gbm = c()
PPVs_gbm = c()
NPVs_gbm = c()
F1s_gbm = c()
ns_gbm = c()
ntrees_gbm = c()
interaction_depths_gbm = c()
param_list_ntrees = c(500,1250,2000,3000)
param_list_interaction_depths = c(5,10,15,20)
#param_list_ntrees = c(20)
#param_list_interaction_depths = c(3)

df_ml_input = read.csv(paste(path_ml_input_final, as.character(n), '.csv', sep=''))
df_model_input = df_ml_input[, -which(names(df_ml_input) %in% c('X', 'file_name', 'rhythm'))]
df_model_input = df_model_input %>% select(-contains('death1'))
df_model_input = df_model_input %>% select(-contains('death2'))
df_model_input = df_model_input %>% select(-contains('death3'))
df_model_input$arr_flag = rep(1, nrow(df_model_input))
df_model_input$arr_flag[which(df_ml_input$rhythm=='SR')] = 0
df_model_input$arr_flag[which(df_ml_input$rhythm=='SB')] = 0
df_model_input$arr_flag[which(df_ml_input$rhythm=='ST')] = 0

mtry = as.integer((ncol(df_model_input) - 1))
for (j in 1:length(param_list_ntrees)){
  ntree = param_list_ntrees[j]
  for (m in 1:length(param_list_interaction_depths)){
    interaction_depth = param_list_interaction_depths[m]
    accuracies_tmp = c()
    sensitivities_tmp = c()
    specificities_tmp = c()
    PPVs_tmp = c()
    NPVs_tmp = c()
    F1s_tmp = c()
      
    for (l in 1:k){
      test_idxs = k_fold_cv_idxs[,l]
      train_idxs = setdiff(seq(1,10605,1), test_idxs)
  
      mod.gbm = gbm(arr_flag ~ ., data=df_model_input[train_idxs,], distribution='bernoulli', 
                      n.trees = ntree, interaction.depth = interaction_depth)
      pred_probs_response = predict(mod.gbm, newdata = df_model_input[test_idxs,], n.trees = ntree, type='response')
      pred_probs_link = predict(mod.gbm, newdata = df_model_input[test_idxs,], n.trees = ntree, type='link')
        
      pred_path_response = paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_arr_vs_sr2/gbm_probs/gbm_pred_response_n', 
                                 as.character(n), '_ntree', as.character(ntree), '_interactiondepth',
                                 as.character(interaction_depth), '_fold', as.character(l), '.csv', sep='')
      pred_path_link = paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_arr_vs_sr2/gbm_probs/gbm_pred_link_n', 
                                 as.character(n), '_ntree', as.character(ntree), '_interactiondepth',
                                 as.character(interaction_depth), '_fold', as.character(l), '.csv', sep='')
      write.csv(pred_probs_response, pred_path_response, row.names=TRUE)
      write.csv(pred_probs_link, pred_path_link, row.names=TRUE)

      if (j==1 & m==1){
        true_rhythms = factor(df_model_input$arr_flag[test_idxs])
        true_path = paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_arr_vs_sr2/true/gbm_true_fold', as.character(l), '.csv', sep='')
        write.csv(true_rhythms, true_path, row.names=TRUE)
      }

      pred_probs = predict(mod.gbm, newdata = df_model_input[test_idxs,], n.trees = ntree)
      exp_preds = factor(ifelse(pred_probs >= 0.5, 1, 0))
        
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
    ns_gbm = rbind(ns_gbm, ns[i])
    ntrees_gbm = rbind(ntrees_gbm, ntree)
    interaction_depths_gbm = rbind(interaction_depths_gbm, interaction_depth)
    accuracies_gbm = rbind(accuracies_gbm, mean(accuracies_tmp))
    sensitivities_gbm = rbind(sensitivities_gbm, mean(sensitivities_tmp))
    specificities_gbm = rbind(specificities_gbm, mean(specificities_tmp))
    PPVs_gbm = rbind(PPVs_gbm, mean(PPVs_tmp))
    NPVs_gbm = rbind(NPVs_gbm, mean(NPVs_tmp))
    F1s_gbm = rbind(F1s_gbm, mean(F1s_tmp))
  }
}

df_output_gbm = data.frame(n = ns_gbm, ntree = ntrees_gbm, 
                          interaction_depth = interaction_depths_gbm, 
                          accuracy = accuracies_gbm,
                          sensitivity = sensitivities_gbm,
                          specificities = specificities_gbm,
                          PPV = PPVs_gbm, NPV = NPVs_gbm, F1 = F1s_gbm)
write.csv(df_output_gbm, paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_arr_vs_sr2/gbm/accs_gbm_n', as.character(n), '.csv', sep=''), row.names = FALSE)






