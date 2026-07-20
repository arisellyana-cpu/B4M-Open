%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bee for Mining Open Version (B4M-Open)
%
% Main Program
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;

clc;

close all;

addpath(genpath(pwd))

fprintf('\n');
fprintf('==============================================\n');
fprintf(' Bee for Mining Open Version (B4M-Open)\n');
fprintf('==============================================\n');

%% Load Configuration

cfg = config();

rng(cfg.randomSeed);

%% Load Dataset

dataset = loadDataset(cfg);

% fieldnames(dataset)

%% Initialize Population

population = initializePopulation(dataset,cfg);

disp(' ');
disp('================ FIRST BEE ================')

population(1)

disp(' ')

disp('================ FIRST RULE ================')

population(1).Rule

fprintf('\n');
fprintf('Population Successfully Generated\n');

fprintf('Scout Bees : %d\n',length(population));

fprintf('\n');

disp('Initialization Finished.');


disp(' ');
disp('========== FIRST FITNESS ==========')

disp(population(1).Rule.Fitness)

%% Test Bee Dance

parentBee = population(1);

improvedBee = beeDance( ...
    parentBee, ...
    dataset, ...
    cfg, ...
    cfg.nOtherRecruit);

fprintf('\n');
fprintf('========== BEE DANCE TEST ==========\n');
fprintf('Parent Fitness   : %.4f\n', ...
    parentBee.Rule.Fitness);

fprintf('Improved Fitness : %.4f\n', ...
    improvedBee.Rule.Fitness);

fprintf('Parent Coverage  : %d\n', ...
    parentBee.Rule.Coverage);

fprintf('New Coverage     : %d\n', ...
    improvedBee.Rule.Coverage);

fprintf('Parent Quality   : %.4f\n', ...
    parentBee.Rule.Quality);

fprintf('New Quality      : %.4f\n', ...
    improvedBee.Rule.Quality);

%% ==========================================================
% Main Optimization Loop
% ===========================================================

fprintf('\n');
fprintf('==============================================\n');
fprintf(' Starting B4M Optimization\n');
fprintf('==============================================\n');

bestFitnessHistory = zeros(cfg.maxIteration, 1);

globalBestBee = population(1);

for iteration = 1:cfg.maxIteration

    [population, iterationBestBee] = eliteSelection( ...
        population, ...
        dataset, ...
        cfg);

    if iterationBestBee.Rule.Fitness > ...
            globalBestBee.Rule.Fitness

        globalBestBee = iterationBestBee;

    end

    bestFitnessHistory(iteration) = ...
        globalBestBee.Rule.Fitness;

    fprintf( ...
        'Iteration %3d/%3d | Fitness: %.4f | Quality: %.4f | Coverage: %3d\n', ...
        iteration, ...
        cfg.maxIteration, ...
        globalBestBee.Rule.Fitness, ...
        globalBestBee.Rule.Quality, ...
        globalBestBee.Rule.Coverage);

end

%% ==========================================================
% Final Result
% ===========================================================

fprintf('\n');
fprintf('==============================================\n');
fprintf(' Best Rule Found\n');
fprintf('==============================================\n');

fprintf('Class      : %d\n', ...
    globalBestBee.Rule.Class);

fprintf('Fitness    : %.4f\n', ...
    globalBestBee.Rule.Fitness);

fprintf('Quality    : %.4f\n', ...
    globalBestBee.Rule.Quality);

fprintf('Coverage   : %d\n', ...
    globalBestBee.Rule.Coverage);

fprintf('Support    : %.4f\n', ...
    globalBestBee.Rule.Support);

fprintf('Confidence : %.4f\n', ...
    globalBestBee.Rule.Confidence);

disp('Lower Bound:');
disp(globalBestBee.Rule.LowerBound);

disp('Upper Bound:');
disp(globalBestBee.Rule.UpperBound);

%% ==========================================================
% Multiclass Prediction
% ===========================================================

fprintf('\n');
fprintf('==============================================\n');
fprintf(' Multiclass Classification Evaluation\n');
fprintf('==============================================\n');

[yPred, metrics, ruleSet] = prediction( ...
    population, ...
    dataset, ...
    cfg);

fprintf('Selected Rules : %d\n', ...
    metrics.NumberOfRules);

fprintf('Accuracy       : %.4f\n', ...
    metrics.Accuracy);

fprintf('Precision      : %.4f\n', ...
    metrics.Precision);

fprintf('Recall         : %.4f\n', ...
    metrics.Recall);

fprintf('F1-Score       : %.4f\n', ...
    metrics.F1Score);

fprintf('\nConfusion Matrix:\n');
disp(metrics.ConfusionMatrix);

fprintf('Class-wise Precision:\n');
disp(metrics.PrecisionPerClass');

fprintf('Class-wise Recall:\n');
disp(metrics.RecallPerClass');

fprintf('Class-wise F1-Score:\n');
disp(metrics.F1PerClass');

%% ==========================================================
% Cross-Validation Evaluation
% ===========================================================

cvResults = runCrossValidation(dataset, cfg);