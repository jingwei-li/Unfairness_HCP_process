function HCP_FC_no_censor(outmat, fMRI_ls, ROI_file)

% HCP_FC_no_censor(outmat, fMRI_ls, ROI_file)
%
% 

script_dir = dirname(mfilename('fullpath'));
if(~exist('ROI_file', 'var') || isempty(ROI_file))
    ROI_file = fullfile(script_dir, 'Schaefer2016_400Parcels_17Networks_colors_19_09_16_subcortical.dlabel.nii');
end

CBIG_ComputeROIs2ROIsCorrelationMatrix(outmat, fMRI_ls, fMRI_ls, ...
    'NONE', ROI_file, ROI_file, 'NONE', "NONE", 1, 0)
    
end