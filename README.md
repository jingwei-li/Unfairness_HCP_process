# Fairness between African Americans (AA) and white Americans  (WA) in RSFC-based behavioral prediction using the HCP dataset

## Reference

Jingwei Li, Danilo Bzdok, Jianzhong Chen, Angela Tam, Leon Qi Rong Ooi, Avram J. Holmes, Tian Ge, Kaustubh R. Patil, Simon B. Eickhoff, B.T. Thomas Yeo*, Sarah Genon*, _**Cross-ethnicity/race generalization failure of behavioral prediction from resting-state functional connectivity**_, under review.

## Background

Machine learning is expected to play a crucial role in precision medicine, yet algorithmic biases towards majority populations may pose a key challenge towards this goal. Here, we assessed such bias in prediction models of behavioral phenotypes from brain functional magnetic resonance imaging. We examined this question using two independent pre-adolescent and adult, respectively, datasets of mixed ethnic/racial composition. When predictive models were trained on data dominated by white Americans (WA), out-of-sample prediction errors were generally higher in African Americans (AA) than for WA. This bias towards WA corresponds to more WA-like brain-behavioral association patterns learned by models. When models were trained on AA only, compared to training only on WA or an equal number of AA and WA participants, AA prediction accuracy improved but stayed below that for WA. Overall, the results point to the need for caution and further research regarding the application of current brain-behavior prediction models in minority population.

## Usage

First, this repository relies on multiple utility functions in the Computational Brain Imaging Group repository (CBIG; https://github.com/ThomasYeoLab/CBIG), e.g. kernel ridge regression package. Please follow the configuration instructions of CBIG repository before you use the current repository. Also, make sure you have the HCP csv files prepared on your devices.

After that, this repository should be used as the following steps:

1. Follow the README in `match_split` folder to find matched AA and WA pairs, and split all subjects into multiple folds to facilitate the nested cross-validation procedure for later steps.

2. Follow the README in `KRR` folder to run kernel ridge regression in a nested cross-validation manner as split in step 1.

3. Follow the README in `AAvsWA` folder to calculate the out-of-sample prediction accuracy of matched AA and WA, and test the significancy of the accuracy difference.

4. Follow the README in `plot` folder to plot the accuracy differencies.
