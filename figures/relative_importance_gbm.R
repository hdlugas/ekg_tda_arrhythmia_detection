
######################### Gradient Boosed Model ##########################
library(caret)
library(ISLR)
library(boot)
library(disdat)
library(dplyr)
library(logistf)
library(gbm)
library(randomForest)
library(MASS)
library(ingredients)
library(DALEX)
library(ggplot2)

source('/home/hunter/ekg/afib2/scripts/plot_fi_scores.R')
set.seed(1)

path_ml_input_final = '/home/hunter/ekg/afib2/ml_input_final/input'
k_fold_cv_idxs_afib = read.csv('/home/hunter/ekg/afib2/k_fold_cv_idxs_afib.csv')
k_fold_cv_idxs_arr = read.csv('/home/hunter/ekg/afib2/k_fold_cv_idxs_arr.csv')
k_fold_cv_idxs_arr2 = read.csv('/home/hunter/ekg/afib2/k_fold_cv_idxs_arr2.csv')
ns = seq(5,30,1)

death_cols_to_rm = c()
for (i in 1:max(ns)){
  tmp = paste('death', as.character(i), sep='')
  death_cols_to_rm = rbind(death_cols_to_rm, tmp)
}


get_mean_ris_afib = function(df){
  predictors = colnames(df)[which(colnames(df) != 'afib_flag')]
  sum_ris = c()
  for (j in 1:ncol(k_fold_cv_idxs_afib)){
    print(j)
    test_idxs = k_fold_cv_idxs_afib[,j]
    train_idxs = setdiff(seq(1,10605,1), test_idxs)
    mod = gbm(afib_flag ~ ., data=df[train_idxs,], distribution='bernoulli',
              n.trees = 3000, interaction.depth = 20)
    ris_tmp = summary.gbm(mod, method = relative.influence)
    ris = c()
    for (i in 1:length(predictors)){
      idx = which(ris_tmp$var == predictors[i])
      ris = c(ris, ris_tmp$rel.inf[idx])
    } 
    if (j == 1){
      sum_ris = ris
    } else{
      sum_ris = sum_ris + ris
    }
  }
  df_out = data.frame(VAR = predictors, RI = sum_ris/5) 
  return(df_out)
}

get_mean_ris_arr = function(df){
  predictors = colnames(df)[which(colnames(df) != 'arr_flag')]
  sum_ris = c()
  for (j in 1:ncol(k_fold_cv_idxs_arr)){
    print(j)
    test_idxs = k_fold_cv_idxs_arr[,j]
    train_idxs = setdiff(seq(1,10605,1), test_idxs)
    mod = gbm(arr_flag ~ ., data=df[train_idxs,], distribution='bernoulli',
              n.trees = 3000, interaction.depth = 10)
    ris_tmp = summary.gbm(mod, method = relative.influence)
    ris = c()
    for (i in 1:length(predictors)){
      idx = which(ris_tmp$var == predictors[i])
      ris = c(ris, ris_tmp$rel.inf[idx])
    } 
    if (j == 1){
      sum_ris = ris
    } else{
      sum_ris = sum_ris + ris
    }
  }
  df_out = data.frame(VAR = predictors, RI = sum_ris/5) 
  return(df_out)
}

get_mean_ris_arr2 = function(df){
  predictors = colnames(df)[which(colnames(df) != 'arr_flag')]
  sum_ris = c()
  for (j in 1:ncol(k_fold_cv_idxs_arr2)){
    print(j)
    test_idxs = k_fold_cv_idxs_arr2[,j]
    train_idxs = setdiff(seq(1,10605,1), test_idxs)
    mod = gbm(arr_flag ~ ., data=df[train_idxs,], distribution='bernoulli',
              n.trees = 3000, interaction.depth = 20)
    ris_tmp = summary.gbm(mod, method = relative.influence)
    ris = c()
    for (i in 1:length(predictors)){
      idx = which(ris_tmp$var == predictors[i])
      ris = c(ris, ris_tmp$rel.inf[idx])
    } 
    if (j == 1){
      sum_ris = ris
    } else{
      sum_ris = sum_ris + ris
    }
  }
  df_out = data.frame(VAR = predictors, RI = sum_ris/5) 
  return(df_out)
}




########## Atrial fibrillation vs non-atrial fibrillation ##########
opt_n = 20
df_model_input = read.csv(paste(path_ml_input_final, as.character(opt_n), '.csv', sep=''))
df_model_input$afib_flag = ifelse(df_model_input$rhythm == 'AFIB', 1, 0)
df_model_input = df_model_input[, -which(names(df_model_input) %in% c('X', 'file_name', 'rhythm'))]
df_model_input = df_model_input[, -which(names(df_model_input) %in% death_cols_to_rm)]

df_ris = get_mean_ris_afib(df_model_input)

p = ggplot(df_ris, aes(y=reorder(VAR, -RI), x=RI)) +
  geom_bar(stat = 'identity', width=0.7) +
  theme(panel.background = element_blank(),
        axis.title = element_text(size=20),
        axis.text.x = element_text(size=14),
        axis.text.y = element_text(size=10, hjust=1)) +
  xlab('Relative Influence') +
  ylab('Variable')

ggsave(filename = '/home/hunter/ekg/afib2/figures/ri_gbm_afib.eps',
       plot = p,
       device = 'eps',
       dpi = 1200,
       width = 12,
       height = 14)








########## Arrhythmia vs non-arrhythmia ##########
opt_n = 12
df_model_input = read.csv(paste(path_ml_input_final, as.character(opt_n), '.csv', sep=''))
df_model_input$arr_flag = ifelse(df_model_input$rhythm == 'SR', 0, 1)
df_model_input = df_model_input[, -which(names(df_model_input) %in% c('X', 'file_name', 'rhythm'))]
df_model_input = df_model_input[, -which(names(df_model_input) %in% death_cols_to_rm)]

df_ris = get_mean_ris_arr(df_model_input)

p = ggplot(df_ris, aes(y=reorder(VAR, -RI), x=RI)) +
  geom_bar(stat = 'identity', width=0.7) +
  theme(panel.background = element_blank(),
        axis.title = element_text(size=20),
        axis.text.x = element_text(size=14),
        axis.text.y = element_text(size=10, hjust=1)) +
  xlab('Relative Influence') +
  ylab('Variable')

ggsave(filename = '/home/hunter/ekg/afib2/figures/ri_gbm_arr.eps',
       plot = p,
       device = 'eps',
       dpi = 1200,
       width = 12,
       height = 14)







########## Arrhythmias with Morphological Changes vs. Sinus Rhythm with Bradycardia and Tachycardia Treated as Non-Arrhythmia ##########
opt_n_log = 10
df_model_input = read.csv(paste(path_ml_input_final, as.character(opt_n_log), '.csv', sep=''))
df_model_input$arr_flag = rep(1, nrow(df_model_input))
df_model_input$arr_flag[which(df_model_input$rhythm=='SR')] = 0
df_model_input$arr_flag[which(df_model_input$rhythm=='SB')] = 0
df_model_input$arr_flag[which(df_model_input$rhythm=='ST')] = 0
df_model_input = df_model_input[, -which(names(df_model_input) %in% c('X', 'file_name', 'rhythm'))]
df_model_input = df_model_input[, -which(names(df_model_input) %in% death_cols_to_rm)]

df_ris = get_mean_ris_arr(df_model_input)

p = ggplot(fi, aes(x=reorder(variable, -mean_f1), y=mean_f1)) +
  geom_bar(stat = 'identity', width=0.7) +
  theme(panel.background = element_blank(),
        axis.text.x = element_text(angle=90, size=5, hjust=1),
        axis.text.y = element_text(size = 10)) +
  ylab('Relative Influence') +
  xlab('Variable')

ggsave(filename = '/home/hunter/ekg/afib2/figures/fi_gbm_arr2.eps',
       plot = p,
       device = 'eps',
       dpi = 1200,
       width = 12,
       height = 14)





