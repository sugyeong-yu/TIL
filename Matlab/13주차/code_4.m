clear all; close all; clc;

cd 'D:\study\sugyeong_github\TIL\Matlab\13주차'

TR_SET   = [];
TR_LABEL = [];

% for tr
for subj = 1:1:4
    file_name = ['ECG_PEAK' num2str(subj) '.mat'];
    load(file_name);
    
    file_name = ['sleep_score_' num2str(subj) '.mat'];
    load(file_name);
    
    r_nr_stg = ones(length(stg), 1);
    idx = find(stg == 7);
    r_nr_stg(idx, 1) = 2;
    
    
    HRV_SET = zeros(length(stg), 10);
    
    for k=1:1:length(stg)
        idx     = find(rpeak_i > (k-1)*fs*30+1 & rpeak_i <= (k)*fs*30);
        t_rpeak = rpeak_i(idx);
        
        %SDNN, RMSSD, pNN50, M_HR
        [HRV_SET(k, 1), HRV_SET(k, 2), HRV_SET(k, 3), HRV_SET(k, 4)]  =  TD_HRV(fs, t_rpeak);
    end
    
    for k=1:1:length(stg)-9
        [subj k]
        idx     = find(rpeak_i > (k-1)*fs*30+1 & rpeak_i <= (k+9)*fs*30);
        t_rpeak = rpeak_i(idx);
        
        % LF, HF, TF, VLF, nLF, nHF, LFHF.     nHF and nLF are mathmetically equal
        [HRV_SET(k+9, 5), HRV_SET(k+9, 6), HRV_SET(k+9, 7), HRV_SET(k+9, 8), HRV_SET(k+9, 9), ~, HRV_SET(k+9, 10)] = FD_HRV(fs, t_rpeak);     
    end
    
    tHRV_SET  = HRV_SET(10:end,:);
    tr_nr_stg = r_nr_stg(10:end, :);
    
    [r, c] = size(HRV_SET);
    for k=1:1:c
        tHRV_SET(:,k) = smooth(tHRV_SET(:,k), 100, 'moving');
        tHRV_SET(:,k) = (tHRV_SET(:,k) - mean(tHRV_SET(:,k)))/std(tHRV_SET(:,k));
    end
 
    TR_SET   = [TR_SET; tHRV_SET];
    TR_LABEL = [TR_LABEL; tr_nr_stg];
end

TS_SET   = [];
TS_LABEL = [];

% for ts
for subj = 5:1:5
    file_name = ['ECG_PEAK' num2str(subj) '.mat'];
    load(file_name);
    
    file_name = ['sleep_score_' num2str(subj) '.mat'];
    load(file_name);
    
    r_nr_stg = ones(length(stg), 1);
    idx = find(stg == 7);
    r_nr_stg(idx, 1) = 2;
    
    
    HRV_SET = zeros(length(stg), 10);
    
    for k=1:1:length(stg)
        idx     = find(rpeak_i > (k-1)*fs*30+1 & rpeak_i <= (k)*fs*30);
        t_rpeak = rpeak_i(idx);
        
        %SDNN, RMSSD, pNN50, M_HR
        [HRV_SET(k, 1), HRV_SET(k, 2), HRV_SET(k, 3), HRV_SET(k, 4)]  =  TD_HRV(fs, t_rpeak);
    end
    
    for k=1:1:length(stg)-9
        [subj k]
        idx     = find(rpeak_i > (k-1)*fs*30+1 & rpeak_i <= (k+9)*fs*30);
        t_rpeak = rpeak_i(idx);
        
        % LF, HF, TF, VLF, nLF, nHF, LFHF.     nHF and nLF are mathmetically equal
        [HRV_SET(k+9, 5), HRV_SET(k+9, 6), HRV_SET(k+9, 7), HRV_SET(k+9, 8), HRV_SET(k+9, 9), ~, HRV_SET(k+9, 10)] = FD_HRV(fs, t_rpeak);     
    end
    
    
    tHRV_SET  = HRV_SET(10:end,:);
    tr_nr_stg = r_nr_stg(10:end, :);
    
    [r, c] = size(HRV_SET);
    for k=1:1:c
        tHRV_SET(:,k) = smooth(tHRV_SET(:,k), 100, 'moving');
        tHRV_SET(:,k) = (tHRV_SET(:,k) - mean(tHRV_SET(:,k)))/std(tHRV_SET(:,k));
    end
        
    TS_SET   = [TS_SET; tHRV_SET];
    TS_LABEL = [TS_LABEL; tr_nr_stg];
end

%% decision tree 1
% 의사결정트리 자동화
rng(1)
Mdl = fitctree(TR_SET, TR_LABEL,'OptimizeHyperparameters','auto')
view(Mdl,'Mode','graph')

label = predict(Mdl,TS_SET);

[result, table]=multi_kappa(TS_LABEL, label, [1, 2])

figure;
subplot(211); bar(label); axis tight;
subplot(212); bar(TS_LABEL); axis tight;


%% Decision tree 베이스, 10fold
Mdl2 = fitctree(TR_SET, TR_LABEL);
view(Mdl2,'Mode','graph');

cp = cvpartition(TR_LABEL,'KFold',10);

dtResubErr = resubLoss(Mdl2) % 그냥만들었던거 에러

cvt = crossval(Mdl2,'CVPartition',cp); % 크로스val해봤더니 
dtCVErr = kfoldLoss(cvt) % error가 6배 증가. > 과적합

resubcost = resubLoss(Mdl2,'Subtrees','all');
[cost,secost,ntermnodes,bestlevel] = cvloss(Mdl2,'Subtrees','all');
plot(ntermnodes,cost,'b-', ntermnodes,resubcost,'r--')
figure(gcf);
xlabel('Number of terminal nodes');
ylabel('Cost (misclassification error)')
legend('Cross-validation','Resubstitution')

[mincost,minloc] = min(cost);
cutoff = mincost + secost(minloc);
hold on
plot([0 70], [cutoff cutoff], 'k:')
plot(ntermnodes(bestlevel+1), cost(bestlevel+1), 'mo')
legend('Cross-validation','Resubstitution','Min + 1 std. err.','Best choice')
hold off

pt = prune(Mdl2,'Level',bestlevel);
view(pt,'Mode','graph')

label = predict(pt,TS_SET);

[result, table]=multi_kappa(TS_LABEL, label, [1, 2])

figure;
subplot(211); bar(label); axis tight;
subplot(212); bar(TS_LABEL); axis tight;

%% MaxNumSplits을 opt해보면 좋겠음. 아래는 샘플 코드
for k=1:1:50
    Mdl = fitctree(TR_SET, TR_LABEL,'MaxNumSplits',k,'CrossVal','on', 'Prior', [0.8 0.2]);
    classError(k,1) = kfoldLoss(Mdl);
end

[mv, mi] = min(classError);

Mdl2 = fitctree(TR_SET, TR_LABEL,'MaxNumSplits', mi, 'Prior', [0.8 0.2]);

label = predict(Mdl2,TS_SET);

[result, table]=multi_kappa(TS_LABEL, label, [1, 2])

figure;
subplot(211); bar(label); axis tight;
subplot(212); bar(TS_LABEL); axis tight;


%% Random Forest
Mdl = TreeBagger(50,TR_SET, TR_LABEL,'OOBPrediction','On','Method','classification');

label = predict(Mdl,TS_SET);
label = str2num(cell2mat(label)); % treebagger은 cell형태로 반환해주므로 이를 metrix로 변환

[result, table]=multi_kappa(TS_LABEL, label, [1, 2])

figure;
subplot(211); bar(label); axis tight;
subplot(212); bar(TS_LABEL); axis tight;

%% SVM linear

rng(1);
SVMModel = fitcsvm(TR_SET, TR_LABEL,'KernelFunction', 'linear', 'Prior', [0.8 0.2], 'KernelScale','auto','Standardize',true, 'OutlierFraction',0.05);% 0.05는 약간의 여지를 준것 5%정도는 이상값일 수 있으니 이를 반영해서 모델을 만들어라 라는것

label = predict(SVMModel,TS_SET);

[result, table]=multi_kappa(TS_LABEL, label, [1, 2])

figure;
subplot(211); bar(label); axis tight;
subplot(212); bar(TS_LABEL); axis tight;

%% SVM 최적의파라미터 자동화 (시간오래걸림)
rng default
Mdl = fitcsvm(TR_SET, TR_LABEL,'OptimizeHyperparameters','auto',...
    'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
    'expected-improvement-plus'))


label = predict(Mdl,TS_SET);

[result, table]=multi_kappa(TS_LABEL, label, [1, 2])

figure;
subplot(211); bar(label); axis tight;
subplot(212); bar(TS_LABEL); axis tight;

%% 다음 시간에 다시 말씀드리겠습니다.
classError  = [];
for k=1:1:10
    tic;
    SVMModel         = fitcsvm(TR_SET(:,k), TR_LABEL,'KernelFunction', 'linear', 'Prior', [0.8 0.2], 'KernelScale','auto','Standardize',true, 'OutlierFraction',0.05,'CrossVal','on');
    classError(k, 1) = kfoldLoss(SVMModel);
    toc;
end

[sv, si] = sort(classError, 'ascend');

SVMModel2         = fitcsvm(TR_SET(:,si(1:4)), TR_LABEL,'KernelFunction', 'linear', 'Prior', [0.8 0.2], 'KernelScale','auto','Standardize',true, 'OutlierFraction',0.05);
    
label = predict(SVMModel2,TS_SET(:,si(1:4)));

[result, table]=multi_kappa(TS_LABEL, label, [1, 2])

figure;
subplot(211); bar(label); axis tight;
subplot(212); bar(TS_LABEL); axis tight;