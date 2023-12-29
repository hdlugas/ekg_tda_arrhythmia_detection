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


############### Gradient Boosted Model ###############
param_list_ntrees = c(500,1250,2000,3000)
param_list_interaction_depths = c(5,10,15,20)
#param_list_ntrees = c(50)
#param_list_interaction_depths = c(3)

df_ml_input = read.csv(paste(path_ml_input_final, as.character(n), '.csv', sep=''))
df_model_input = df_ml_input[, -which(names(df_ml_input) %in% c('X', 'file_name', 'rhythm'))]
df_model_input = df_model_input %>% select(-contains('death1'))
df_model_input = df_model_input %>% select(-contains('death2'))
df_model_input = df_model_input %>% select(-contains('death3'))
df_model_input$afib_flag = ifelse(df_ml_input$rhythm == 'AFIB', 1, 0)

for (j in 1:length(param_list_ntrees)){
  ntree = param_list_ntrees[j]
  for (i in 1:length(param_list_interaction_depths)){
    interaction_depth = param_list_interaction_depths[i]
    for (l in 1:k){
      test_idxs = k_fold_cv_idxs[,l]
      train_idxs = setdiff(seq(1,10605,1), test_idxs)
  
      mod.gbm = gbm(afib_flag ~ ., data=df_model_input[train_idxs,], distribution='bernoulli', 
                      n.trees = ntree, interaction.depth = interaction_depth)
      pred_probs_response = predict(mod.gbm, newdata = df_model_input[test_idxs,], n.trees = ntree, type='response')
      pred_probs_link = predict(mod.gbm, newdata = df_model_input[test_idxs,], n.trees = ntree, type='link')
        
      pred_path_response = paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_probs/gbm/gbm_pred_response_n', 
                                 as.character(n), '_ntree', as.character(ntree), '_interactiondepth',
                                 as.character(interaction_depth), '_fold', as.character(l), '.csv', sep='')
      pred_path_link = paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_probs/gbm/gbm_pred_link_n', 
                                 as.character(n), '_ntree', as.character(ntree), '_interactiondepth',
                                 as.character(interaction_depth), '_fold', as.character(l), '.csv', sep='')
      write.csv(pred_probs_response, pred_path_response, row.names=TRUE)
      write.csv(pred_probs_link, pred_path_link, row.names=TRUE)

      if (j==1 & i==1){
        true_rhythms = factor(df_model_input$afib_flag[test_idxs])
        true_path = paste('/wsu/home/fy/fy73/fy7392/ekg/afib2/ml_output_probs/true/gbm_true_fold', as.character(l), '.csv', sep='')
        write.csv(true_rhythms, true_path, row.names=TRUE)
      }
    }
  }
}





