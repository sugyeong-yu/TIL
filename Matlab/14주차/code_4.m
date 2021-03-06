% HRV REM수면 데이터로 해보기.
% HRV지표뽑는 코드
clear all; close all; clc;

cd 'D:\study\sugyeong_github\TIL\Matlab\14주차'

TR_SET   = {};
TR_LABEL = {};

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
    
    HRV_SET(:,2) = -HRV_SET(:,2);
    HRV_SET(:,3) = -HRV_SET(:,3);
    HRV_SET(:,6) = -HRV_SET(:,6);
    
    tHRV_SET  = HRV_SET(10:end,:);
    tr_nr_stg = r_nr_stg(10:end, :);
    
    [r, c] = size(HRV_SET);
    for k=1:1:c
        tHRV_SET(:,k) = (tHRV_SET(:,k) - mean(tHRV_SET(:,k)))/std(tHRV_SET(:,k));
    end
 
    TR_SET{subj}   = tHRV_SET;
    TR_LABEL{subj} = tr_nr_stg;
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
    
    % REM일때 값이작아지는 지표들의 값들을 키우기위해서 부호를 반대로.
    %부교감 신경계활성화됐을때 값이 커지는 애들을 -로 바꿔놓았다는것.
    HRV_SET(:,2) = -HRV_SET(:,2);
    HRV_SET(:,3) = -HRV_SET(:,3);
    HRV_SET(:,6) = -HRV_SET(:,6);
    
    
    tHRV_SET  = HRV_SET(10:end,:);
    tr_nr_stg = r_nr_stg(10:end, :);
    
    [r, c] = size(HRV_SET);
    for k=1:1:c
        tHRV_SET(:,k) = (tHRV_SET(:,k) - mean(tHRV_SET(:,k)))/std(tHRV_SET(:,k));
    end
    
    TS_SET   = tHRV_SET;
    TS_LABEL = tr_nr_stg;

end
%%
close all; figure;
subplot(611); plot(smooth(TR_SET{3}(:,1), 100, 'moving')); axis tight;
subplot(612); plot(smooth(TR_SET{3}(:,2), 100, 'moving')); axis tight;
subplot(613); plot(smooth(TR_SET{3}(:,3), 100, 'moving')); axis tight;
subplot(614); plot(smooth(TR_SET{3}(:,4), 100, 'moving')); axis tight;
subplot(615); plot(smooth(TR_SET{3}(:,5), 100, 'moving')); axis tight;
subplot(616); bar(TR_LABEL{3}); axis tight;
figure;
subplot(611); plot(smooth(TR_SET{3}(:,6), 100, 'moving')); axis tight;
subplot(612); plot(smooth(TR_SET{3}(:,7), 100, 'moving')); axis tight;
subplot(613); plot(smooth(TR_SET{3}(:,8), 100, 'moving')); axis tight;
subplot(614); plot(smooth(TR_SET{3}(:,9), 100, 'moving')); axis tight;
subplot(615); plot(smooth(TR_SET{3}(:,10), 100, 'moving')); axis tight;
subplot(616); bar(TR_LABEL{3}); axis tight;
%% 뽑은 HRV feature로 PCA돌려보기
% 4명의데이터에 대해서 각각 모든 경우의수를 가지고 분석할것.
% 10개의 지표를 위에서 뽑았었음
comb = nchoosek(1:1:10, 4); % 1에서 10까지 3개의 지표를 뽑을 수 있는 것의 모든 경우의수를 만들어놓은것. 이 조합의 갯수(120)만큼 지표를 사용> 4명 각각 120개의 결과
RES_OUT = zeros(4, length(comb));

% 120개의 결과를 전체평균내서 어떤조합일떄 가장 결과가 좋은지를 알아보고자 하는것. 
% 최종적으로 뽑힌 지표를 가져와서 test에 사용하는 것.
for subj = 1:1:4
    Feature  =  TR_SET{subj};
    LABEL    = TR_LABEL{subj};
    
    for k=1:1:length(comb)
        [subj k]
        REM_FEATURE   =  Feature(:,comb(k,:));
        [nSET_PARAM]  =  (REM_FEATURE-mean(REM_FEATURE))/std(REM_FEATURE); % normalization
        [~,SCORE,~, ~, ~, ~]     =  pca(nSET_PARAM);%pca 수행
        
        %pca를 가져와서 smoothing하고 norm
        F_REM_TREND        =   smooth(SCORE(:, 1), 100, 'moving');%rloess
        
        F_REM_TREND        =   (F_REM_TREND-mean(F_REM_TREND))/std(F_REM_TREND);
        [b, a]             =   butter(5, 2/(length(F_REM_TREND)/2), 'low');
        TH_B               =   filtfilt(b, a, F_REM_TREND)+0.6; % 0.6을 임계값으로. 0.6이상은 REM이다.
        
        EST_REM            =  ones(1, length(LABEL));
        
        idx                =   find(F_REM_TREND >=TH_B);
        EST_REM(idx)       =   2;
        
        % heuristic 보통 REM수면은 잠 초반에 잘안나옴 따라서 40분정도의 데이터에서 REM인게나오면 무시하도록
        % 휴리스틱1
        EST_REM(1:80)      =  1; % 초반 40분동안나오는건 무조건 Non Rem

        [re1, re2]        =  multi_kappa(EST_REM, LABEL, [1 2]); % 결과 distance구하기
    
        RES_OUT(subj, k) = re1.kappa;
    end
end

m_RES_OUT = mean(RES_OUT);
[mv, mi] = max(m_RES_OUT)

comb(mi,:)

%%
Feature  =  TS_SET;
LABEL    =  TS_LABEL;

REM_FEATURE   =  Feature(:,comb(mi,:));
[nSET_PARAM]  = (REM_FEATURE-mean(REM_FEATURE))/std(REM_FEATURE);;
[~,SCORE,~, ~, ~, ~]     =  pca(nSET_PARAM);

F_REM_TREND        =   smooth(SCORE(:, 1), 100, 'moving');%rloess

F_REM_TREND        =   (F_REM_TREND-mean(F_REM_TREND))/std(F_REM_TREND);
[b, a]             =   butter(5, 2/(length(F_REM_TREND)/2), 'low');
TH_B               =   filtfilt(b, a, F_REM_TREND)+0.6;

EST_REM            =  ones(1, length(LABEL));

idx                =   find(F_REM_TREND >=TH_B);
EST_REM(idx)       =   2;

% heuristic
EST_REM(1:80)      =  1;

[re1, re2]        =  multi_kappa(EST_REM, LABEL, [1 2])

figure;
subplot(211); bar(EST_REM); axis tight;
subplot(212); bar(LABEL); axis tight;

