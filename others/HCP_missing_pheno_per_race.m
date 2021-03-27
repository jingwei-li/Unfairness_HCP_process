function [nan_per_race, nonnan_per_race] = HCP_missing_pheno_per_race(...
    restricted_csv, unrestricted_csv, bhvr_ls)

% [nan_per_race, nonnan_per_race] = HCP_missing_pheno_per_race(...
%     restricted_csv, unrestricted_csv, bhvr_ls)
%
% Check if minorities have more missing values of behavioral measures, compared to white Americans.
% 
% Inputs:
%   - restricted_csv (optional)
%     Full path of the HCP restricted CSV file. "Race" information needs to be read from this file.
%     Default (on the CSC server):
%     '/mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/scripts/restricted_hcp_data/...
%     RESTRICTED_jingweili_4_12_2017_1200subjects_fill_empty_zygosityGT_by_zygositySR.csv'
%   - unrestricted_csv (optional)
%     Full path of the HCP unrestricted CSV file. Behavioral scores needed for this study are 
%     contained in this file. Default (on the CSC server):
%     '/mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/scripts/subject_measures/...
%     unrestricted_jingweili_12_7_2017_21_0_16_NEO_A_corrected.csv'
%   - bhvr_ls (optional)
%     Full path of the list containing all behavioral measures for this study.
%
% Outputs:
%   - nan_per_race
%     A #behavior x #race matrix. Entry (i,j) represents the number of missing values for the i-th 
%     behavioral measure in the j-th racial/ethnic group.
%   - nonnan_per_race
%     A #behavior x #race matrix. Entry (i,j) represents the number of subjects who have been recorded
%     for the i-th behavioral measures in the j-th racial/ethnic group.
%
% Author: Jingwei Li

HCP_dir = '/mnt/isilon/CSC1/Yeolab/Data/HCP/S1200';
if(~exist('restricted_csv', 'var') || isempty(restricted_csv))
    restricted_csv = fullfile(HCP_dir, 'scripts', 'restricted_hcp_data', ...
        'RESTRICTED_jingweili_4_12_2017_1200subjects_fill_empty_zygosityGT_by_zygositySR.csv');
end
if(~exist('unrestricted_csv', 'var') || isempty(unrestricted_csv))
    unrestricted_csv = fullfile(HCP_dir, 'scripts', 'subject_measures', ...
        'unrestricted_jingweili_12_7_2017_21_0_16_NEO_A_corrected.csv');
end

if(~exist('bhvr_ls', 'var') || isempty(bhvr_ls))
    bhvr_ls = fullfile(getenv('HOME'), 'storage', 'MyProject', 'fairAI', 'HCP_race', 'scripts', ...
        'lists', 'Cognitive_Personality_Task_Social_Emotion_58.txt');
end
[bhvr_nm, nbhvr] = CBIG_text2cell(bhvr_ls);

d_rstr = readtable(restricted_csv);
d_unrstr = readtable(unrestricted_csv);

subj = d_rstr.Subject;
uq_race = unique(d_rstr.Race);

%% indicies of subjects in each race category
idx_per_race = cell(length(uq_race));
for r = 1:length(uq_race)
    idx_per_race{r} = find(strcmp(d_rstr.Race, uq_race{r}));
end

%% collect nan
nan_per_race = zeros(nbhvr, length(uq_race));
nonnan_per_race = zeros(nbhvr, length(uq_race));
for b = 1:nbhvr
    pheno = d_unrstr.(bhvr_nm{b});
    nan_idx = find(isnan(pheno));
    nonnan_idx = find(~isnan(pheno));

    for r = 1:length(uq_race)
        nan_per_race(b,r) = length(intersect(idx_per_race{r}, nan_idx));
        nonnan_per_race(b,r) = length(intersect(idx_per_race{r}, nonnan_idx));
    end
end


end