# This script obtains the indices of the five cross-validation folds for the three different binary classifications

set.seed(1)
path_ml_input_final = '/home/hunter/ekg/afib2/ml_input_final/input'


##### Atrial fibrillation vs non-atrial fibrillation #####
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
write.csv(k_fold_cv_idxs, '/home/hunter/ekg/afib2/k_fold_cv_idxs_afib.csv', row.names = F)




##### Arrhythmia vs non-arrhythmia #####
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
write.csv(k_fold_cv_idxs, '/home/hunter/ekg/afib2/k_fold_cv_idxs_arr.csv', row.names = F)






##### Arrhythmias with Morphological Changes vs. Sinus Rhythm with Bradycardia and Tachycardia Treated as Non-Arrhythmia #####
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
write.csv(k_fold_cv_idxs, '/home/hunter/ekg/afib2/k_fold_cv_idxs_arr2.csv', row.names = F)



