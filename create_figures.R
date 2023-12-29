library(flextable)
library(ggplot2)
library(pROC)
# library(xtable)

path_processed_sigs = '/home/hunter/ekg/afib2/processed_data_all/'
diagnostics = read.csv('/home/hunter/ekg/afib/data/diagnostics.csv')
processed_sigs = list.files(path_processed_sigs)
tmp = diagnostics[diagnostics$FileName %in% processed_sigs,]
tmp2 = data.frame(table(tmp$Rhythm))
tmp2$Var1 = c('Atrial Flutter', 'Atrial Fibrillation', 'Atrial Tachycardia',
              'Atrioventricular Node Reentrant Tachycardia', 
              'Atrioventricular Reentrant Tachycardia',
              'Sinoatrial Block', 
              'Sinus Atrium to Atrial Wandering', 
              'Sinus Bradycardia', 
              'Sinus Rhythm',
              'Sinus Rachycardia', 
              'Supraventricular Tachycardia')
  
tmp2$Prop = tmp2$Freq / sum(tmp2$Freq)
tmp2$Prop = sprintf('%0.3f', tmp2$Prop)
tmp2$Prop = paste(tmp2$Prop, '%', sep='')
# print(xtable(tmp2), type='latex', 
#       file='/home/hunter/ekg/afib2/figures/rhythm_distribution.tex')

t = flextable(tmp2)
t = set_caption(t, caption = 'Distribution of Rhythms')
t = width(t, j=c(1,2,3), width=c(2.5,2,2))
header = list(Var1 = 'Rhythm', Freq='Count (Total=10605)', Prop='Proportion')
t = set_header_labels(t, values=header)
t = align(t, j = c(1,2,3), align = 'center', part = 'body')
t = align(t, align = 'center', part = 'header')
t = fontsize(t, i = NULL, j = NULL, size = 10, part = "header")
t = fontsize(t, i = NULL, j = NULL, size = 8, part = "body")
t






afib_dir = '/home/hunter/ekg/afib2/ml_output_final/afib/'
arr_dir = '/home/hunter/ekg/afib2/ml_output_final/arr/'
arr2_dir = '/home/hunter/ekg/afib2/ml_output_final/arr2/'
ns = seq(5,30,1)

get_opt_thresh_and_N_lr = function(path){
  dir = paste(path, 'lr/', sep='')
  labels_path = paste(path, 'true/lr_true_fold', sep='')
  threshs = seq(1,99,1)
  threshs = threshs / 100
  f1_final = c()
  for (k in 1:length(threshs)){
    print(k)
    thresh = threshs[k]
    f1s = c()
    for (i in 1:length(ns)){
      f1_tmp = c()
      for (j in 1:5){
        df_tmp = read.csv(paste(dir, 'n', as.character(ns[i]), '_fold', as.character(j), '.csv', sep=''))
        preds = ifelse(df_tmp[,2] >= thresh, 1, 0)
        labels = read.csv(paste(labels_path, as.character(j), '.csv', sep=''))[,2]
        cm = table(preds, labels)
        if (nrow(cm)==2 & ncol(cm)==2){
          TP = cm[1,1]
          FP = cm[1,2]
          FN = cm[2,1]
          TN = cm[2,2]
          f1_tmp = append(f1_tmp, 2*TP / (2*TP + FP + FN))
        }
      }
      f1s = append(f1s, mean(f1_tmp))
    }
    f1_final = rbind(f1_final, c(thresh, which.max(f1s), max(f1s)))
  }
  idx_tmp = which.max(f1_final[,3])
  opt_thresh = f1_final[idx_tmp,1]
  opt_n = f1_final[idx_tmp,2] + 4
  return(c(opt_thresh, opt_n))
}



get_opt_thresh_and_N_lda = function(path){
  threshs = seq(1,99,1)
  threshs = threshs / 100
  lda_dir = paste(path, 'lda/', sep='')
  f1_final = c()
  for (k in 1:length(threshs)){
    print(k)
    thresh = threshs[k]
    f1s = c()
    for (i in 1:length(ns)){
      f1_tmp = c()
      for (j in 1:5){
        df_tmp = read.csv(paste(lda_dir, 'n', as.character(ns[i]), '_fold', as.character(j), '.csv', sep=''))
        preds = ifelse(df_tmp[,3] >= thresh, 1, 0)
        labels = read.csv(paste(path, 'true/lda_true_fold', as.character(j), '.csv', sep=''))[,2]
        cm = table(preds, labels)
        if (nrow(cm)==2 & ncol(cm)==2){
          TP = cm[1,1]
          FP = cm[1,2]
          FN = cm[2,1]
          TN = cm[2,2]
          f1_tmp = append(f1_tmp, 2*TP / (2*TP + FP + FN))
        }
      }
      f1s = append(f1s, mean(f1_tmp))
    }
    f1_final = rbind(f1_final, c(thresh, which.max(f1s), max(f1s)))
  }
  idx_tmp = which.max(f1_final[,3])
  opt_thresh = f1_final[idx_tmp,1]
  opt_n = f1_final[idx_tmp,2] + 4
  return(c(opt_thresh, opt_n))
}


get_opt_thresh_and_N_qda = function(path){
  threshs = seq(1,99,1)
  threshs = threshs / 100
  dir = paste(path, 'qda/', sep='')
  f1_final = c()
  for (k in 1:length(threshs)){
    print(k)
    thresh = threshs[k]
    f1s = c()
    for (i in 1:length(ns)){
      f1_tmp = c()
      for (j in 1:5){
        df_tmp = read.csv(paste(dir, 'n', as.character(ns[i]), '_fold', as.character(j), '.csv', sep=''))
        preds = ifelse(df_tmp[,3] >= thresh, 1, 0)
        labels = read.csv(paste(path, 'true/qda_true_fold', as.character(j), '.csv', sep=''))[,2]
        cm = table(preds, labels)
        if (nrow(cm)==2 & ncol(cm)==2){
          TP = cm[1,1]
          FP = cm[1,2]
          FN = cm[2,1]
          TN = cm[2,2]
          f1_tmp = append(f1_tmp, 2*TP / (2*TP + FP + FN))
        }
      }
      f1s = append(f1s, mean(f1_tmp))
    }
    f1_final = rbind(f1_final, c(thresh, which.max(f1s), max(f1s)))
  }
  idx_tmp = which.max(f1_final[,3])
  opt_thresh = f1_final[idx_tmp,1]
  opt_n = f1_final[idx_tmp,2] + 4
  return(c(opt_thresh, opt_n))
}



get_opt_thresh_and_N_nb = function(path){
  threshs = seq(1,99,1)
  threshs = threshs / 100
  dir = paste(path, 'nb/', sep='')
  f1_final = c()
  for (k in 1:length(threshs)){
    print(k)
    thresh = threshs[k]
    f1s = c()
    for (i in 1:length(ns)){
      f1_tmp = c()
      for (j in 1:5){
        df_tmp = read.csv(paste(dir, 'n', as.character(ns[i]), '_fold', as.character(j), '.csv', sep=''))
        preds = ifelse(df_tmp[,3] >= thresh, 1, 0)
        labels = read.csv(paste(path, 'true/nb_true_fold', as.character(j), '.csv', sep=''))[,2]
        cm = table(preds, labels)
        if (nrow(cm)==2 & ncol(cm)==2){
          TP = cm[1,1]
          FP = cm[1,2]
          FN = cm[2,1]
          TN = cm[2,2]
          f1_tmp = append(f1_tmp, 2*TP / (2*TP + FP + FN))
        }
      }
      f1s = append(f1s, mean(f1_tmp))
    }
    f1_final = rbind(f1_final, c(thresh, which.max(f1s), max(f1s)))
  }
  idx_tmp = which.max(f1_final[,3])
  opt_thresh = f1_final[idx_tmp,1]
  opt_n = f1_final[idx_tmp,2] + 4
  return(c(opt_thresh, opt_n))
}



get_opt_thresh_and_N_rf = function(path, opt_N, ntree, mtry){
  threshs = seq(1,99,1)
  threshs = threshs / 100
  dir = paste(path, 'rf/rf_n', as.character(opt_N), '_ntree', as.character(ntree),
              '_mtry', as.character(mtry), '_fold', sep='')
  f1_final = c()
  for (k in 1:length(threshs)){
    print(k)
    thresh = threshs[k]
    f1_tmp = c()
    for (j in 1:5){
      df_tmp = read.csv(paste(dir, as.character(j), '.csv', sep=''))
      preds = ifelse(df_tmp[2122:4242,2] >= thresh, 1, 0)
      labels = read.csv(paste(path, 'true/rf_true_fold', as.character(j), '.csv', sep=''))[,2]
      cm = table(preds, labels)
      if (nrow(cm)==2 & ncol(cm)==2){
        TP = cm[1,1]
        FP = cm[1,2]
        FN = cm[2,1]
        TN = cm[2,2]
        f1_tmp = append(f1_tmp, 2*TP / (2*TP + FP + FN))
      }
    }
  f1_final = rbind(f1_final, c(thresh, max(mean(f1_tmp))))
  }
  idx_tmp = which.max(f1_final[,2])
  opt_thresh = f1_final[idx_tmp,1]
  return(c(opt_thresh))
}


get_opt_thresh_and_N_gbm = function(path, opt_N, ntree, id){
  threshs = seq(1,99,1)
  threshs = threshs / 100
  dir = paste(path, 'gbm/gbm_pred_response_n', as.character(opt_N), '_ntree', as.character(ntree),
                    '_interactiondepth', as.character(id), '_fold', sep='')
  f1_final = c()
  for (k in 1:length(threshs)){
    print(k)
    thresh = threshs[k]
    f1_tmp = c()
    for (j in 1:5){
      df_tmp = read.csv(paste(dir, as.character(j), '.csv', sep=''))
      preds = ifelse(df_tmp[,2] >= thresh, 1, 0)
      labels = read.csv(paste(path, 'true/gbm_true_fold', as.character(j), '.csv', sep=''))[,2]
      cm = table(preds, labels)
      if (nrow(cm)==2 & ncol(cm)==2){
        TP = cm[1,1]
        FP = cm[1,2]
        FN = cm[2,1]
        TN = cm[2,2]
        f1_tmp = append(f1_tmp, 2*TP / (2*TP + FP + FN))
      }
    }
    f1_final = rbind(f1_final, c(thresh, max(mean(f1_tmp))))
  }
  idx_tmp = which.max(f1_final[,2])
  opt_thresh = f1_final[idx_tmp,1]
  return(c(opt_thresh))
}




opt_tmp = get_opt_thresh_and_N_lr(path=afib_dir)
opt_thresh_lr_afib = opt_tmp[1]
opt_N_lr_afib = opt_tmp[2]
opt_tmp = get_opt_thresh_and_N_lr(path=arr_dir)
opt_thresh_lr_arr = opt_tmp[1]
opt_N_lr_arr = opt_tmp[2]
opt_tmp = get_opt_thresh_and_N_lr(path=arr2_dir)
opt_thresh_lr_arr2 = opt_tmp[1]
opt_N_lr_arr2 = opt_tmp[2]

opt_tmp = get_opt_thresh_and_N_lda(afib_dir)
opt_thresh_lda_afib = opt_tmp[1]
opt_N_lda_afib = opt_tmp[2]
opt_tmp = get_opt_thresh_and_N_lda(arr_dir)
opt_thresh_lda_arr = opt_tmp[1]
opt_N_lda_arr = opt_tmp[2]
opt_tmp = get_opt_thresh_and_N_lda(arr2_dir)
opt_thresh_lda_arr2 = opt_tmp[1]
opt_N_lda_arr2 = opt_tmp[2]

opt_tmp = get_opt_thresh_and_N_qda(afib_dir)
opt_thresh_qda_afib = opt_tmp[1]
opt_N_qda_afib = opt_tmp[2]
opt_tmp = get_opt_thresh_and_N_qda(arr_dir)
opt_thresh_qda_arr = opt_tmp[1]
opt_N_qda_arr = opt_tmp[2]
opt_tmp = get_opt_thresh_and_N_qda(arr2_dir)
opt_thresh_qda_arr2 = opt_tmp[1]
opt_N_qda_arr2 = opt_tmp[2]

opt_tmp = get_opt_thresh_and_N_nb(afib_dir)
opt_thresh_nb_afib = opt_tmp[1]
opt_N_nb_afib = opt_tmp[2]
opt_tmp = get_opt_thresh_and_N_nb(arr_dir)
opt_thresh_nb_arr = opt_tmp[1]
opt_N_nb_arr = opt_tmp[2]
opt_tmp = get_opt_thresh_and_N_nb(arr2_dir)
opt_thresh_nb_arr2 = opt_tmp[1]
opt_N_nb_arr2 = opt_tmp[2]

opt_N_rf_afib = 14
opt_tmp = get_opt_thresh_and_N_rf(afib_dir, opt_N=opt_N_rf_afib, ntree=500, mtry=68)
opt_thresh_rf_afib = opt_tmp
opt_N_rf_arr = 8
opt_tmp = get_opt_thresh_and_N_rf(arr_dir, opt_N=opt_N_rf_arr, ntree=1250, mtry=45)
opt_thresh_rf_arr = opt_tmp
opt_N_rf_arr2 = 10
opt_tmp = get_opt_thresh_and_N_rf(arr2_dir, opt_N = opt_N_rf_arr2, ntree=3000, mtry=35)
opt_thresh_rf_arr2 = opt_tmp

opt_N_gbm_afib = 20
opt_tmp = get_opt_thresh_and_N_gbm(afib_dir, opt_N=opt_N_gbm_afib, ntree=3000, id=20)
opt_thresh_gbm_afib = opt_tmp[1]
opt_N_gbm_arr = 12
opt_tmp = get_opt_thresh_and_N_gbm(arr_dir, opt_N=opt_N_gbm_arr, ntree=3000, id=10)
opt_thresh_gbm_arr = opt_tmp[1]
opt_N_gbm_arr2 = 10
opt_tmp = get_opt_thresh_and_N_gbm(arr2_dir, opt_N=opt_N_gbm_arr2, ntree=3000, id=20)
opt_thresh_gbm_arr2 = opt_tmp[1]

opt_N_knn_afib = 23
opt_K_knn_afib = 10
opt_N_knn_arr = 5
opt_K_knn_arr = 10
opt_N_knn_arr2 = 19
opt_K_knn_arr2 = 9

opt_N_svm_lin_afib = 29
opt_N_svm_lin_arr = 20
opt_N_svm_lin_arr2 = 29

opt_N_svm_rad_afib = 5
opt_G_svm_rad_afib = 0.5
opt_N_svm_rad_arr = 5
opt_G_svm_rad_arr = 0.5
opt_N_svm_rad_arr2 = 5
opt_G_svm_rad_arr2 = 0.5

opt_N_svm_poly_afib = 17
opt_D_svm_poly_afib = 2
opt_N_svm_poly_arr = 21
opt_D_svm_poly_arr = 2
opt_N_svm_poly_arr2 = 16
opt_D_svm_poly_arr2 = 2


get_col_lr = function(path, opt_thresh, opt_N){
  accs_tmp = c()
  sens_tmp = c()
  spec_tmp = c()
  ppv_tmp = c()
  npv_tmp = c()
  f1_tmp = c()
  dir = paste(path, 'lr/', sep='')
  for (j in 1:5){
    df_tmp = read.csv(paste(dir, 'n', as.character(opt_N), '_fold', as.character(j), '.csv', sep=''))
    preds = ifelse(df_tmp[,2] >= opt_thresh, 1, 0)
    labels = read.csv(paste(path, 'true/lr_true_fold', as.character(j), '.csv', sep=''))[,2]
    cm = table(preds, labels)
    if (nrow(cm)==2 & ncol(cm)==2){
      TP = cm[1,1]
      FP = cm[1,2]
      FN = cm[2,1]
      TN = cm[2,2]
      accs_tmp = append(accs_tmp, (TP + TN) / (TP + TN + FN + FP))
      sens_tmp = append(sens_tmp, TP / (TP + FN))
      spec_tmp = append(spec_tmp, TN / (TN + FP))
      ppv_tmp = append(ppv_tmp, TP / (TP + FP))
      npv_tmp = append(npv_tmp, TN / (TN + FN))
      f1_tmp = append(f1_tmp, 2*TP / (2*TP + FP + FN))
    }
  }
  return(c(mean(f1_tmp), mean(accs_tmp), mean(sens_tmp), mean(spec_tmp), mean(ppv_tmp), mean(npv_tmp), opt_N))
}


get_col_lda = function(path, opt_thresh, opt_N){
  accs_tmp = c()
  sens_tmp = c()
  spec_tmp = c()
  ppv_tmp = c()
  npv_tmp = c()
  f1_tmp = c()
  dir = paste(path, 'lda/', sep='')
  for (j in 1:5){
    df_tmp = read.csv(paste(dir, 'n', as.character(opt_N), '_fold', as.character(j), '.csv', sep=''))
    preds = ifelse(df_tmp[,3] >= opt_thresh, 1, 0)
    labels = read.csv(paste(path, 'true/lda_true_fold', as.character(j), '.csv', sep=''))[,2]
    cm = table(preds, labels)
    if (nrow(cm)==2 & ncol(cm)==2){
      TP = cm[1,1]
      FP = cm[1,2]
      FN = cm[2,1]
      TN = cm[2,2]
      accs_tmp = append(accs_tmp, (TP + TN) / (TP + TN + FN + FP))
      sens_tmp = append(sens_tmp, TP / (TP + FN))
      spec_tmp = append(spec_tmp, TN / (TN + FP))
      ppv_tmp = append(ppv_tmp, TP / (TP + FP))
      npv_tmp = append(npv_tmp, TN / (TN + FN))
      f1_tmp = append(f1_tmp, 2*TP / (2*TP + FP + FN))
    }
  }
  return(c(mean(f1_tmp), mean(accs_tmp), mean(sens_tmp), mean(spec_tmp), mean(ppv_tmp), mean(npv_tmp), opt_N))
}


get_col_qda = function(path, opt_thresh, opt_N){
  accs_tmp = c()
  sens_tmp = c()
  spec_tmp = c()
  ppv_tmp = c()
  npv_tmp = c()
  f1_tmp = c()
  dir = paste(path, 'qda/', sep='')
  for (j in 1:5){
    df_tmp = read.csv(paste(dir, 'n', as.character(opt_N), '_fold', as.character(j), '.csv', sep=''))
    preds = ifelse(df_tmp[,3] >= opt_thresh, 1, 0)
    labels = read.csv(paste(path, 'true/qda_true_fold', as.character(j), '.csv', sep=''))[,2]
    cm = table(preds, labels)
    if (nrow(cm)==2 & ncol(cm)==2){
      TP = cm[1,1]
      FP = cm[1,2]
      FN = cm[2,1]
      TN = cm[2,2]
      accs_tmp = append(accs_tmp, (TP + TN) / (TP + TN + FN + FP))
      sens_tmp = append(sens_tmp, TP / (TP + FN))
      spec_tmp = append(spec_tmp, TN / (TN + FP))
      ppv_tmp = append(ppv_tmp, TP / (TP + FP))
      npv_tmp = append(npv_tmp, TN / (TN + FN))
      f1_tmp = append(f1_tmp, 2*TP / (2*TP + FP + FN))
    }
  }
  return(c(mean(f1_tmp), mean(accs_tmp), mean(sens_tmp), mean(spec_tmp), mean(ppv_tmp), mean(npv_tmp), opt_N))
}


get_col_nb = function(path, opt_thresh, opt_N){
  accs_tmp = c()
  sens_tmp = c()
  spec_tmp = c()
  ppv_tmp = c()
  npv_tmp = c()
  f1_tmp = c()
  dir = paste(path, 'nb/', sep='')
  for (j in 1:5){
    df_tmp = read.csv(paste(dir, 'n', as.character(opt_N), '_fold', as.character(j), '.csv', sep=''))
    preds = ifelse(df_tmp[,3] >= opt_thresh, 1, 0)
    labels = read.csv(paste(path, 'true/nb_true_fold', as.character(j), '.csv', sep=''))[,2]
    cm = table(preds, labels)
    if (nrow(cm)==2 & ncol(cm)==2){
      TP = cm[1,1]
      FP = cm[1,2]
      FN = cm[2,1]
      TN = cm[2,2]
      accs_tmp = append(accs_tmp, (TP + TN) / (TP + TN + FN + FP))
      sens_tmp = append(sens_tmp, TP / (TP + FN))
      spec_tmp = append(spec_tmp, TN / (TN + FP))
      ppv_tmp = append(ppv_tmp, TP / (TP + FP))
      npv_tmp = append(npv_tmp, TN / (TN + FN))
      f1_tmp = append(f1_tmp, 2*TP / (2*TP + FP + FN))
    }
  }
  return(c(mean(f1_tmp), mean(accs_tmp), mean(sens_tmp), mean(spec_tmp), mean(ppv_tmp), mean(npv_tmp), opt_N))
}


get_col_rf = function(path, opt_thresh, opt_N, ntree, mtry){
  accs_tmp = c()
  sens_tmp = c()
  spec_tmp = c()
  ppv_tmp = c()
  npv_tmp = c()
  f1_tmp = c()
  dir = paste(path, 'rf/rf_n', as.character(opt_N), '_ntree', as.character(ntree), 
              '_mtry', as.character(mtry), '_fold', sep='')
  for (j in 1:5){
    df_tmp = read.csv(paste(dir, as.character(j), '.csv', sep=''))
    preds = ifelse(df_tmp[2122:4242,2] >= opt_thresh, 1, 0)
    labels = read.csv(paste(path, 'true/rf_true_fold', as.character(j), '.csv', sep=''))[,2]
    cm = table(preds, labels)
    if (nrow(cm)==2 & ncol(cm)==2){
      TP = cm[1,1]
      FP = cm[1,2]
      FN = cm[2,1]
      TN = cm[2,2]
      accs_tmp = append(accs_tmp, (TP + TN) / (TP + TN + FN + FP))
      sens_tmp = append(sens_tmp, TP / (TP + FN))
      spec_tmp = append(spec_tmp, TN / (TN + FP))
      ppv_tmp = append(ppv_tmp, TP / (TP + FP))
      npv_tmp = append(npv_tmp, TN / (TN + FN))
      f1_tmp = append(f1_tmp, 2*TP / (2*TP + FP + FN))
    }
  }
  return(c(mean(f1_tmp), mean(accs_tmp), mean(sens_tmp), mean(spec_tmp), mean(ppv_tmp), mean(npv_tmp), opt_N))
}


get_col_gbm = function(path, opt_thresh, opt_N, ntree, id){
  accs_tmp = c()
  sens_tmp = c()
  spec_tmp = c()
  ppv_tmp = c()
  npv_tmp = c()
  f1_tmp = c()
  dir = paste(path, 'gbm/gbm_pred_response_n', as.character(opt_N), '_ntree',
                     as.character(ntree), '_interactiondepth', as.character(id), '_fold', sep='')
  for (j in 1:5){
    df_tmp = read.csv(paste(dir, as.character(j), '.csv', sep=''))
    preds = ifelse(df_tmp[,2] >= opt_thresh, 1, 0)
    labels = read.csv(paste(path, 'true/gbm_true_fold', as.character(j), '.csv', sep=''))[,2]
    cm = table(preds, labels)
    if (nrow(cm)==2 & ncol(cm)==2){
      TP = cm[1,1]
      FP = cm[1,2]
      FN = cm[2,1]
      TN = cm[2,2]
      accs_tmp = append(accs_tmp, (TP + TN) / (TP + TN + FN + FP))
      sens_tmp = append(sens_tmp, TP / (TP + FN))
      spec_tmp = append(spec_tmp, TN / (TN + FP))
      ppv_tmp = append(ppv_tmp, TP / (TP + FP))
      npv_tmp = append(npv_tmp, TN / (TN + FN))
      f1_tmp = append(f1_tmp, 2*TP / (2*TP + FP + FN))
    }
  }
  return(c(mean(f1_tmp), mean(accs_tmp), mean(sens_tmp), mean(spec_tmp), mean(ppv_tmp), mean(npv_tmp), opt_N))
}



get_col_knn = function(path, opt_K, opt_N){
  dir = paste(path, 'knn/accuracies_n', as.character(opt_N), '.csv', sep='')
  df = read.csv(dir)
  idx = which(df$K == opt_K)
  return(c(df$F1[idx], df$accuracy[idx], df$sensitivity[idx], df$specificities[idx], df$PPV[idx], df$NPV[idx], opt_N))
}

get_col_svm_lin = function(path, opt_N){
  dir = paste(path, 'svm_lin/accuracies_n', as.character(opt_N), '.csv', sep='')
  df = read.csv(dir)
  idx = 1
  return(c(df$F1[idx], df$accuracy[idx], df$sensitivity[idx], df$specificities[idx], df$PPV[idx], df$NPV[idx], opt_N))
}

get_col_svm_rad = function(path, opt_N, opt_G){
  dir = paste(path, 'svm_rad/accuracies_n', as.character(opt_N), '.csv', sep='')
  df = read.csv(dir)
  idx = which(df$gamma == opt_G)
  return(c(df$F1[idx], df$accuracy[idx], df$sensitivity[idx], df$specificities[idx], df$PPV[idx], df$NPV[idx], opt_N))
}

get_col_svm_poly = function(path, opt_N, opt_D){
  dir = paste(path, 'svm_poly/accuracies_n', as.character(opt_N), '.csv', sep='')
  df = read.csv(dir)
  idx = which(df$degree == opt_D)
  return(c(df$F1[idx], df$accuracy[idx], df$sensitivity[idx], df$specificities[idx], df$PPV[idx], df$NPV[idx], opt_N))
}



V_lr_afib = get_col_lr(afib_dir, opt_thresh_lr_afib, opt_N_lr_afib)
V_lr_arr = get_col_lr(arr_dir, opt_thresh_lr_arr, opt_N_lr_arr)
V_lr_arr2 = get_col_lr(arr2_dir, opt_thresh_lr_arr2, opt_N_lr_arr2)
V_lda_afib = get_col_lda(afib_dir, opt_thresh_lda_afib, opt_N_lda_afib)
V_lda_arr = get_col_lda(arr_dir, opt_thresh_lda_arr, opt_N_lda_arr)
V_lda_arr2 = get_col_lda(arr2_dir, opt_thresh_lda_arr2, opt_N_lda_arr2)
V_qda_afib = get_col_qda(afib_dir, opt_thresh_qda_afib, opt_N_qda_afib)
V_qda_arr = get_col_qda(arr_dir, opt_thresh_qda_arr, opt_N_qda_arr)
V_qda_arr2 = get_col_qda(arr2_dir, opt_thresh_qda_arr2, opt_N_qda_arr2)
V_nb_afib = get_col_nb(afib_dir, opt_thresh_nb_afib, opt_N_nb_afib)
V_nb_arr = get_col_nb(arr_dir, opt_thresh_nb_arr, opt_N_nb_arr)
V_nb_arr2 = get_col_nb(arr2_dir, opt_thresh_nb_arr2, opt_N_nb_arr2)
V_rf_afib = get_col_rf(afib_dir, opt_thresh_rf_afib, opt_N_rf_afib, ntree=500, mtry=68)
V_rf_arr = get_col_rf(arr_dir, opt_thresh_rf_arr, opt_N_rf_arr, ntree=1250, mtry=45)
V_rf_arr2 = get_col_rf(arr2_dir, opt_thresh_rf_arr2, opt_N_rf_arr2, ntree=3000, mtry=35)
V_gbm_afib = get_col_gbm(afib_dir, opt_thresh_gbm_afib, opt_N_gbm_afib, ntree=3000, id=20)
V_gbm_arr = get_col_gbm(arr_dir, opt_thresh_gbm_arr, opt_N_gbm_arr, ntree=3000, id=10)
V_gbm_arr2 = get_col_gbm(arr2_dir, opt_thresh_gbm_arr2, opt_N_gbm_arr2, ntree=3000, id=20)
V_knn_afib = get_col_knn(afib_dir, opt_K_knn_afib, opt_N_knn_afib)
V_knn_arr = get_col_knn(arr_dir, opt_K_knn_arr, opt_N_knn_arr)
V_knn_arr2 = get_col_knn(arr2_dir, opt_K_knn_arr2, opt_N_knn_arr2)
V_svm_lin_afib = get_col_svm_lin(afib_dir, opt_N_svm_lin_afib)
V_svm_lin_arr = get_col_svm_lin(arr_dir, opt_N_svm_lin_arr)
V_svm_lin_arr2 = get_col_svm_lin(arr2_dir, opt_N_svm_lin_arr2)
V_svm_rad_afib = get_col_svm_rad(afib_dir, opt_N_svm_rad_afib, opt_G_svm_rad_afib)
V_svm_rad_arr = get_col_svm_rad(arr_dir, opt_N_svm_rad_arr, opt_G_svm_rad_arr)
V_svm_rad_arr2 = get_col_svm_rad(arr2_dir, opt_N_svm_rad_arr2, opt_G_svm_rad_arr2)
V_svm_poly_afib = get_col_svm_poly(afib_dir, opt_N_svm_poly_afib, opt_D_svm_poly_afib)
V_svm_poly_arr = get_col_svm_poly(arr_dir, opt_N_svm_poly_arr, opt_D_svm_poly_arr)
V_svm_poly_arr2 = get_col_svm_poly(arr2_dir, opt_N_svm_poly_arr2, opt_D_svm_poly_arr2)


V_lr_afib = sprintf('%0.3f', V_lr_afib)
V_lr_arr = sprintf('%0.3f', V_lr_arr)
V_lr_arr2 = sprintf('%0.3f', V_lr_arr2)
V_lda_afib = sprintf('%0.3f', V_lda_afib)
V_lda_arr = sprintf('%0.3f', V_lda_arr)
V_lda_arr2 = sprintf('%0.3f', V_lda_arr2)
V_qda_afib = sprintf('%0.3f', V_qda_afib)
V_qda_arr = sprintf('%0.3f', V_qda_arr)
V_qda_arr2 = sprintf('%0.3f', V_qda_arr2)
V_nb_afib = sprintf('%0.3f', V_nb_afib)
V_nb_arr = sprintf('%0.3f', V_nb_arr)
V_nb_arr2 = sprintf('%0.3f', V_nb_arr2)
V_rf_afib = sprintf('%0.3f', V_rf_afib)
V_rf_arr = sprintf('%0.3f', V_rf_arr)
V_rf_arr2 = sprintf('%0.3f', V_rf_arr2)
V_gbm_afib = sprintf('%0.3f', V_gbm_afib)
V_gbm_arr = sprintf('%0.3f', V_gbm_arr)
V_gbm_arr2 = sprintf('%0.3f', V_gbm_arr2)
V_knn_afib = sprintf('%0.3f', V_knn_afib)
V_knn_arr = sprintf('%0.3f', V_knn_arr)
V_knn_arr2 = sprintf('%0.3f', V_knn_arr2)
V_svm_lin_afib = sprintf('%0.3f', V_svm_lin_afib)
V_svm_lin_arr = sprintf('%0.3f', V_svm_lin_arr)
V_svm_lin_arr2 = sprintf('%0.3f', V_svm_lin_arr2)
V_svm_rad_afib = sprintf('%0.3f', V_svm_rad_afib)
V_svm_rad_arr = sprintf('%0.3f', V_svm_rad_arr)
V_svm_rad_arr2 = sprintf('%0.3f', V_svm_rad_arr2)
V_svm_poly_afib = sprintf('%0.3f', V_svm_poly_afib)
V_svm_poly_arr = sprintf('%0.3f', V_svm_poly_arr)
V_svm_poly_arr2 = sprintf('%0.3f', V_svm_poly_arr2)

df_afib = data.frame(V_lr_afib, V_lda_afib, V_qda_afib, V_nb_afib, V_rf_afib, 
                     V_gbm_afib, V_knn_afib, V_svm_lin_afib, V_svm_rad_afib, V_svm_poly_afib)
df_arr = data.frame(V_lr_arr, V_lda_arr, V_qda_arr, V_nb_arr, V_rf_arr, 
                     V_gbm_arr, V_knn_arr, V_svm_lin_arr, V_svm_rad_arr, V_svm_poly_arr)
df_arr2 = data.frame(V_lr_arr2, V_lda_arr2, V_qda_arr2, V_nb_arr2, V_rf_arr2, 
                     V_gbm_arr2, V_knn_arr2, V_svm_lin_arr2, V_svm_rad_arr2, V_svm_poly_arr2)
df_afib = as.data.frame(t(df_afib))
df_arr = as.data.frame(t(df_arr))
df_arr2 = as.data.frame(t(df_arr2))

rownames(df_afib) = c('Logistic Regression', 'Linear Discriminant Analysis', 'Quadratic Discriminant Analysis',
                      'Naive Bayes', 'Random Forest', 'Gradient Boosted Model', 'K-Nearest Neighbors',
                      'Support Vector Machine: Linear Kernel', 'Support Vector Machine: Radial Kernel',
                      'Support Vector Machine: Polynomial Kernel')
rownames(df_arr) = c('Logistic Regression', 'Linear Discriminant Analysis', 'Quadratic Discriminant Analysis',
                      'Naive Bayes', 'Random Forest', 'Gradient Boosted Model', 'K-Nearest Neighbors',
                      'Support Vector Machine: Linear Kernel', 'Support Vector Machine: Radial Kernel',
                      'Support Vector Machine: Polynomial Kernel')
rownames(df_arr2) = c('Logistic Regression', 'Linear Discriminant Analysis', 'Quadratic Discriminant Analysis',
                      'Naive Bayes', 'Random Forest', 'Gradient Boosted Model', 'K-Nearest Neighbors',
                      'Support Vector Machine: Linear Kernel', 'Support Vector Machine: Radial Kernel',
                      'Support Vector Machine: Polynomial Kernel')
colnames(df_afib) = c('F1-Score', 'Accuracy', 'Sensitivity', 'Specificity', 'PPV', 'NPV', 'Optimal N')
colnames(df_arr) = c('F1-Score', 'Accuracy', 'Sensitivity', 'Specificity', 'PPV', 'NPV', 'Optimal N')
colnames(df_arr2) = c('F1-Score', 'Accuracy', 'Sensitivity', 'Specificity', 'PPV', 'NPV', 'Optimal N')

# print(xtable(df_afib), type='latex', 
#       file='/home/hunter/ekg/afib2/figures/outcomes_afib.tex')
# print(xtable(df_arr), type='latex', 
#       file='/home/hunter/ekg/afib2/figures/outcomes_arr.tex')
# print(xtable(df_arr2), type='latex', 
#       file='/home/hunter/ekg/afib2/figures/outcomes_arr2.tex')


df_ft = data.frame(V_lr_afib, V_lda_afib, V_qda_afib, V_nb_afib, V_rf_afib, 
                   V_gbm_afib, V_knn_afib, V_svm_lin_afib, V_svm_rad_afib, V_svm_poly_afib,
                   V_lr_arr, V_lda_arr, V_qda_arr, V_nb_arr, V_rf_arr, 
                   V_gbm_arr, V_knn_arr, V_svm_lin_arr, V_svm_rad_arr, V_svm_poly_arr,
                   V_lr_arr2, V_lda_arr2, V_qda_arr2, V_nb_arr2, V_rf_arr2, 
                   V_gbm_arr2, V_knn_arr2, V_svm_lin_arr2, V_svm_rad_arr2, V_svm_poly_arr2)
df_ft = data.frame(t(df_ft))
df_ft$X7 = sprintf('%0.0f', as.numeric(df_ft$X7))
X0 = rep(c('Logistic Regression', 'Linear Discriminant Analysis', 'Quadratic Discriminant Analysis',
             'Naive Bayes', 'Random Forest', 'Gradient Boosted Model', 'K-Nearest Neighbors',
             'Support Vector Machine: Linear Kernel', 'Support Vector Machine: Radial Kernel',
             'Support Vector Machine: Polynomial Kernel'), 3)
X00 = c(rep('Atrial Fibrillation vs. Non-Atrial Fibrillation', 10),
        rep('Arrhythmia vs. Sinus Rhythm', 10),
        rep('Arrhythmia with Morphological Changes vs. Sinus Rhythm with Bradycardia and Tachycardia Considered as Non-Arrhythmia',10))
df_ft = cbind(X00, X0, df_ft)
# print(xtable(df_ft), type='latex', 
#       file='/home/hunter/ekg/afib2/figures/outcomes.tex')

t = flextable(df_ft)
t = set_caption(t, caption = 'Title')
t = width(t, j = seq(1,9,1), width = c(1.5,1.5,1,1,1,1,1,1,1))
t = merge_v(t, j=1, part='body')
t = hline(t, i=c(10,20))
header = list(X00='Classification', X0='Model', X1='F1-Score', X2='Accuracy', 
              X3='Sensitivity', X4='Specificity', X5='PPV', X6='NPV', X7='Optimal N')
t = set_header_labels(t, values=header)
t = align(t, j = seq(1,9,1), align = 'center', part = 'body')
t = align(t, align = 'center', part = 'header')
t = fix_border_issues(t, part='all')
t = footnote(t, i=1, j=c(7,8),
             value = as_paragraph('PPV, positive predictive value; NPV, negative predictive value'), 
             ref_symbols = '*', part = 'header')
t = fontsize(t, i = NULL, j = NULL, size = 10, part = "header")
t = fontsize(t, i = NULL, j = NULL, size = 8, part = "body")
t = fontsize(t, i = NULL, j = NULL, size = 8, part = "footer")
t




get_curve_pts_lr = function(dir){
  sens_tmp = c()
  spec_tmp = c()
  auc_tmp = c()
  for (i in 1:5){
    df = read.csv(paste(dir, as.character(i), '.csv', sep=''))
    true_labels = read.csv(paste(afib_dir, 'true/lr_true_fold', as.character(i), '.csv', sep=''))[,2]
    if (i == 1){
      roc_obj = roc(true_labels, df[,2])
      sens_tmp = roc_obj$sensitivities
      spec_tmp = roc_obj$specificities
      auc_tmp = as.numeric(auc(roc_obj))
    } else{
      sens_tmp = sens_tmp + roc_obj$sensitivities
      spec_tmp = spec_tmp + roc_obj$specificities
      auc_tmp = auc_tmp + as.numeric(auc(roc_obj))
    }
  }
  return(list(auc_tmp/5, data.frame(sensitivity=sens_tmp/5, specificity=spec_tmp/5)))
}


get_curve_pts_lda = function(dir){
  sens_tmp = c()
  spec_tmp = c()
  auc_tmp = c()
  for (i in 1:5){
    df = read.csv(paste(dir, as.character(i), '.csv', sep=''))
    true_labels = read.csv(paste(afib_dir, 'true/lda_true_fold', as.character(i), '.csv', sep=''))[,2]
    if (i == 1){
      roc_obj = roc(true_labels, df[,3])
      sens_tmp = roc_obj$sensitivities
      spec_tmp = roc_obj$specificities
      auc_tmp = as.numeric(auc(roc_obj))
    } else{
      sens_tmp = sens_tmp + roc_obj$sensitivities
      spec_tmp = spec_tmp + roc_obj$specificities
      auc_tmp = auc_tmp + as.numeric(auc(roc_obj))
    }
  }
  return(list(auc_tmp/5, data.frame(sensitivity=sens_tmp/5, specificity=spec_tmp/5)))
}


get_curve_pts_qda = function(dir){
  sens_tmp = c()
  spec_tmp = c()
  auc_tmp = c()
  for (i in 1:5){
    df = read.csv(paste(dir, as.character(i), '.csv', sep=''))
    true_labels = read.csv(paste(afib_dir, 'true/qda_true_fold', as.character(i), '.csv', sep=''))[,2]
    if (i == 1){
      roc_obj = roc(true_labels, df[,3])
      sens_tmp = roc_obj$sensitivities
      spec_tmp = roc_obj$specificities
      auc_tmp = as.numeric(auc(roc_obj))
    } else{
      sens_tmp = sens_tmp + roc_obj$sensitivities
      spec_tmp = spec_tmp + roc_obj$specificities
      auc_tmp = auc_tmp + as.numeric(auc(roc_obj))
    }
  }
  return(list(auc_tmp/5, data.frame(sensitivity=sens_tmp/5, specificity=spec_tmp/5)))
}


get_curve_pts_nb = function(dir){
  sens_tmp = c()
  spec_tmp = c()
  auc_tmp = c()
  for (i in 1:5){
    df = read.csv(paste(dir, as.character(i), '.csv', sep=''))
    true_labels = read.csv(paste(afib_dir, 'true/nb_true_fold', as.character(i), '.csv', sep=''))[,2]
    if (i == 1){
      roc_obj = roc(true_labels, df[,3])
      sens_tmp = roc_obj$sensitivities
      spec_tmp = roc_obj$specificities
      auc_tmp = as.numeric(auc(roc_obj))
    } else{
      sens_tmp = sens_tmp + roc_obj$sensitivities
      spec_tmp = spec_tmp + roc_obj$specificities
      auc_tmp = auc_tmp + as.numeric(auc(roc_obj))
    }
  }
  return(list(auc_tmp/5, data.frame(sensitivity=sens_tmp/5, specificity=spec_tmp/5)))
}

get_curve_pts_rf = function(dir, opt_N, ntree, mtry){
  sens_tmp = c()
  spec_tmp = c()
  auc_tmp = c()
  for (i in 1:5){
    df = read.csv(paste(dir, 'rf/rf_n', as.character(opt_N), '_ntree', as.character(ntree), 
                         '_mtry', as.character(mtry), '_fold', as.character(i), '.csv', sep=''))
    true_labels = read.csv(paste(afib_dir, 'true/rf_true_fold', as.character(i), '.csv', sep=''))[,2]
    if (i == 1){
      roc_obj = roc(true_labels, df[2122:4242,2])
      sens_tmp = roc_obj$sensitivities
      spec_tmp = roc_obj$specificities
      auc_tmp = as.numeric(auc(roc_obj))
    } else{
      sens_tmp = sens_tmp + roc_obj$sensitivities
      spec_tmp = spec_tmp + roc_obj$specificities
      auc_tmp = auc_tmp + as.numeric(auc(roc_obj))
    }
  }
  return(list(auc_tmp/5, data.frame(sensitivity=sens_tmp/5, specificity=spec_tmp/5)))
}


get_curve_pts_gbm = function(dir, opt_N, ntree, id){
  sens_tmp = c()
  spec_tmp = c()
  auc_tmp = c()
  for (i in 1:5){
    df = read.csv(paste(dir, 'gbm/gbm_pred_response_n', as.character(opt_N), '_ntree',
                        as.character(ntree), '_interactiondepth', as.character(id), '_fold', 
                        as.character(i), '.csv', sep=''))
    true_labels = read.csv(paste(afib_dir, 'true/gbm_true_fold', as.character(i), '.csv', sep=''))[,2]
    if (i == 1){
      roc_obj = roc(true_labels, df[,2])
      sens_tmp = roc_obj$sensitivities
      spec_tmp = roc_obj$specificities
      auc_tmp = as.numeric(auc(roc_obj))
    } else{
      sens_tmp = sens_tmp + roc_obj$sensitivities
      spec_tmp = spec_tmp + roc_obj$specificities
      auc_tmp = auc_tmp + as.numeric(auc(roc_obj))
    }
  }
  return(list(auc_tmp/5, data.frame(sensitivity=sens_tmp/5, specificity=spec_tmp/5)))
}



path_afib_lr = paste(afib_dir, 'lr/n', as.character(opt_N_lr_afib), '_fold', sep='')
path_arr_lr = paste(arr_dir, 'lr/n', as.character(opt_N_lr_arr), '_fold', sep='')
path_arr2_lr = paste(arr2_dir, 'lr/n', as.character(opt_N_lr_arr2), '_fold', sep='')
output_afib_lr = get_curve_pts_lr(path_afib_lr)
output_arr_lr = get_curve_pts_lr(path_arr_lr)
output_arr2_lr = get_curve_pts_lr(path_arr2_lr)
auc_afib_lr = output_afib_lr[[1]]
auc_arr_lr = output_arr_lr[[1]]
auc_arr2_lr = output_arr2_lr[[1]]
df_auc_afib_lr = output_afib_lr[[2]]
df_auc_arr_lr = output_arr_lr[[2]]
df_auc_arr2_lr = output_arr2_lr[[2]]

path_afib_lda = paste(afib_dir, 'lda/n', as.character(opt_N_lda_afib), '_fold', sep='')
path_arr_lda = paste(arr_dir, 'lda/n', as.character(opt_N_lda_arr), '_fold', sep='')
path_arr2_lda = paste(arr2_dir, 'lda/n', as.character(opt_N_lda_arr2), '_fold', sep='')
output_afib_lda = get_curve_pts_lda(path_afib_lda)
output_arr_lda = get_curve_pts_lda(path_arr_lda)
output_arr2_lda = get_curve_pts_lda(path_arr2_lda)
auc_afib_lda = output_afib_lda[[1]]
auc_arr_lda = output_arr_lda[[1]]
auc_arr2_lda = output_arr2_lda[[1]]
df_auc_afib_lda = output_afib_lda[[2]]
df_auc_arr_lda = output_arr_lda[[2]]
df_auc_arr2_lda = output_arr2_lda[[2]]

path_afib_qda = paste(afib_dir, 'qda/n', as.character(opt_N_qda_afib), '_fold', sep='')
path_arr_qda = paste(arr_dir, 'qda/n', as.character(opt_N_qda_arr), '_fold', sep='')
path_arr2_qda = paste(arr2_dir, 'qda/n', as.character(opt_N_qda_arr2), '_fold', sep='')
output_afib_qda = get_curve_pts_qda(path_afib_qda)
output_arr_qda = get_curve_pts_qda(path_arr_qda)
output_arr2_qda = get_curve_pts_qda(path_arr2_qda)
auc_afib_qda = output_afib_qda[[1]]
auc_arr_qda = output_arr_qda[[1]]
auc_arr2_qda = output_arr2_qda[[1]]
df_auc_afib_qda = output_afib_qda[[2]]
df_auc_arr_qda = output_arr_qda[[2]]
df_auc_arr2_qda = output_arr2_qda[[2]]

path_afib_nb = paste(afib_dir, 'nb/n', as.character(opt_N_nb_afib), '_fold', sep='')
path_arr_nb = paste(arr_dir, 'nb/n', as.character(opt_N_nb_arr), '_fold', sep='')
path_arr2_nb = paste(arr2_dir, 'nb/n', as.character(opt_N_nb_arr2), '_fold', sep='')
output_afib_nb = get_curve_pts_nb(path_afib_nb)
output_arr_nb = get_curve_pts_nb(path_arr_nb)
output_arr2_nb = get_curve_pts_nb(path_arr2_nb)
auc_afib_nb = output_afib_nb[[1]]
auc_arr_nb = output_arr_nb[[1]]
auc_arr2_nb = output_arr2_nb[[1]]
df_auc_afib_nb = output_afib_nb[[2]]
df_auc_arr_nb = output_arr_nb[[2]]
df_auc_arr2_nb = output_arr2_nb[[2]]

output_afib_rf = get_curve_pts_rf(afib_dir, opt_N_rf_afib, 500, 68)
output_arr_rf = get_curve_pts_rf(arr_dir, opt_N_rf_arr, 1250, 45)
output_arr2_rf = get_curve_pts_rf(arr2_dir, opt_N_rf_arr2, 3000, 35)
auc_afib_rf = output_afib_rf[[1]]
auc_arr_rf = output_arr_rf[[1]]
auc_arr2_rf = output_arr2_rf[[1]]
df_auc_afib_rf = output_afib_rf[[2]]
df_auc_arr_rf = output_arr_rf[[2]]
df_auc_arr2_rf = output_arr2_rf[[2]]

output_afib_gbm = get_curve_pts_gbm(afib_dir, opt_N_gbm_afib, 3000, 20)
output_arr_gbm = get_curve_pts_gbm(arr_dir, opt_N_gbm_arr, 3000, 10)
output_arr2_gbm = get_curve_pts_gbm(arr2_dir, opt_N_gbm_arr2, 3000, 20)
auc_afib_gbm = output_afib_gbm[[1]]
auc_arr_gbm = output_arr_gbm[[1]]
auc_arr2_gbm = output_arr2_gbm[[1]]
df_auc_afib_gbm = output_afib_gbm[[2]]
df_auc_arr_gbm = output_arr_gbm[[2]]
df_auc_arr2_gbm = output_arr2_gbm[[2]]


df_roc_afib = data.frame(sensitivity = c(df_auc_afib_lr$sensitivity, df_auc_afib_lda$sensitivity,
                                         df_auc_afib_qda$sensitivity, df_auc_afib_nb$sensitivity,
                                         df_auc_afib_rf$sensitivity, df_auc_afib_gbm$sensitivity),
                         specificity = c(df_auc_afib_lr$specificity, df_auc_afib_lda$specificity,
                                         df_auc_afib_qda$specificity, df_auc_afib_nb$specificity,
                                         df_auc_afib_rf$specificity, df_auc_afib_gbm$specificity),
                         model = c(rep('Logistic Regression, AUC=0.925', length(df_auc_afib_lr$sensitivity)),
                                   rep('Linear Discriminant Analysis, AUC=0.928', length(df_auc_afib_lda$sensitivity)),
                                   rep('Quadratic Discriminant Analysis, AUC=0.884', length(df_auc_afib_qda$sensitivity)),
                                   rep('Naive Bayes, AUC=0.794', length(df_auc_afib_nb$sensitivity)),
                                   rep('Random Forest, AUC=0.964', length(df_auc_afib_rf$sensitivity)),
                                   rep('Gradient Boosted Model, AUC=0.975', length(df_auc_afib_gbm$sensitivity))))

df_roc_arr = data.frame(sensitivity = c(df_auc_arr_lr$sensitivity, df_auc_arr_lda$sensitivity,
                                         df_auc_arr_qda$sensitivity, df_auc_arr_nb$sensitivity,
                                         df_auc_arr_rf$sensitivity, df_auc_arr_gbm$sensitivity),
                         specificity = c(df_auc_arr_lr$specificity, df_auc_arr_lda$specificity,
                                         df_auc_arr_qda$specificity, df_auc_arr_nb$specificity,
                                         df_auc_arr_rf$specificity, df_auc_arr_gbm$specificity),
                         model = c(rep('Logistic Regression, AUC=0.559', length(df_auc_arr_lr$sensitivity)),
                                   rep('Linear Discriminant Analysis, AUC=0.574', length(df_auc_arr_lda$sensitivity)),
                                   rep('Quadratic Discriminant Analysis, AUC=0.551', length(df_auc_arr_qda$sensitivity)),
                                   rep('Naive Bayes, AUC=0.544', length(df_auc_arr_nb$sensitivity)),
                                   rep('Random Forest, AUC=0.591', length(df_auc_arr_rf$sensitivity)),
                                   rep('Gradient Boosted Model, AUC=0.575', length(df_auc_arr_gbm$sensitivity))))

df_roc_arr2 = data.frame(sensitivity = c(df_auc_arr2_lr$sensitivity, df_auc_arr2_lda$sensitivity,
                                         df_auc_arr2_qda$sensitivity, df_auc_arr2_nb$sensitivity,
                                         df_auc_arr2_rf$sensitivity, df_auc_arr2_gbm$sensitivity),
                         specificity = c(df_auc_arr2_lr$specificity, df_auc_arr2_lda$specificity,
                                         df_auc_arr2_qda$specificity, df_auc_arr2_nb$specificity,
                                         df_auc_arr2_rf$specificity, df_auc_arr2_gbm$specificity),
                         model = c(rep('Logistic Regression, AUC=0.841', length(df_auc_arr2_lr$sensitivity)),
                                   rep('Linear Discriminant Analysis, AUC=0.840', length(df_auc_arr2_lda$sensitivity)),
                                   rep('Quadratic Discriminant Analysis, AUC=0.776', length(df_auc_arr2_qda$sensitivity)),
                                   rep('Naive Bayes, AUC=0.771', length(df_auc_arr2_nb$sensitivity)),
                                   rep('Random Forest, AUC=0.882', length(df_auc_arr2_rf$sensitivity)),
                                   rep('Gradient Boosted Model, AUC=0.887', length(df_auc_arr2_gbm$sensitivity))))




ggplot(data=df_roc_afib, aes(x=1-specificity, y=sensitivity, col=model)) +
  geom_line(linewidth=1) +
  theme(panel.background=element_blank(), 
        panel.border = element_rect(color="black", fill=NA, linewidth = 1),
        plot.title = element_text(hjust = 0.5, size=22),
        legend.key = element_rect(fill='white'),
        axis.title = element_text(size = 20),
        axis.text = element_text(size = 15),
        legend.text = element_text(size = 16), 
        legend.key.size = unit(1.5,'cm'),
        legend.title = element_text(size = 20)) +
  geom_segment(aes(x=0, y=0, xend=1, yend=1), color='black', alpha=0.005) +
  labs(col = 'Model:') +
  xlab('1 - Specificity') +
  ylab('Sensitivity')


ggplot(data=df_roc_arr, aes(x=1-specificity, y=sensitivity, col=model)) +
  geom_line(linewidth=1) +
  theme(panel.background=element_blank(), 
        panel.border = element_rect(color="black", fill=NA, linewidth = 1),
        plot.title = element_text(hjust = 0.5, size=22),
        legend.key = element_rect(fill='white'),
        axis.title = element_text(size = 20),
        axis.text = element_text(size = 15),
        legend.text = element_text(size = 16), 
        legend.key.size = unit(1.5,'cm'),
        legend.title = element_text(size = 20)) +
  geom_segment(aes(x=0, y=0, xend=1, yend=1), color='black', alpha=0.005) +
  labs(col = 'Model:') +
  xlab('1 - Specificity') +
  ylab('Sensitivity')


ggplot(data=df_roc_arr2, aes(x=1-specificity, y=sensitivity, col=model)) +
  geom_line(linewidth=1) +
  theme(panel.background=element_blank(), 
        panel.border = element_rect(color="black", fill=NA, linewidth = 1),
        plot.title = element_text(hjust = 0.5, size=22),
        legend.key = element_rect(fill='white'),
        axis.title = element_text(size = 20),
        axis.text = element_text(size = 15),
        legend.text = element_text(size = 16), 
        legend.key.size = unit(1.5,'cm'),
        legend.title = element_text(size = 20)) +
  geom_segment(aes(x=0, y=0, xend=1, yend=1), color='black', alpha=0.005) +
  labs(col = 'Model:') +
  xlab('1 - Specificity') +
  ylab('Sensitivity')


  


