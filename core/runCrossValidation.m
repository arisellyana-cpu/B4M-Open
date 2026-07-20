function cvResults = runCrossValidation(dataset, cfg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bee for Mining Open Version (B4M-Open)
%
% Function    : runCrossValidation
% Description : Perform stratified k-fold cross-validation for B4M
%
% Inputs
%   dataset : Complete dataset structure
%   cfg     : B4M configuration structure
%
% Output
%   cvResults : Mean, standard deviation, and fold-level results
%
% Author      : Ari Sellyana
% Version     : 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ========================================================================
% Input validation
%% ========================================================================

if nargin ~= 2
    error('runCrossValidation requires dataset and cfg.');
end

if ~isfield(cfg, 'nFolds') || isempty(cfg.nFolds)
    cfg.nFolds = 5;
end

if ~isfield(cfg, 'nRulesPerClass') || isempty(cfg.nRulesPerClass)
    cfg.nRulesPerClass = 5;
end

nFolds = round(cfg.nFolds);

if nFolds < 2
    error('cfg.nFolds must be at least 2.');
end

if nFolds > dataset.nSamples
    error('cfg.nFolds cannot exceed the number of samples.');
end

%% ========================================================================
% Reproducibility
%% ========================================================================

rng(cfg.randomSeed);

fprintf('\n');
fprintf('==============================================\n');
fprintf(' Stratified %d-Fold Cross-Validation\n', nFolds);
fprintf('==============================================\n');

%% ========================================================================
% Generate stratified fold assignments
%% ========================================================================

foldIndex = createStratifiedFolds( ...
    dataset.Y, ...
    dataset.nClasses, ...
    nFolds);

%% ========================================================================
% Allocate result arrays
%% ========================================================================

accuracyValues  = zeros(nFolds, 1);
precisionValues = zeros(nFolds, 1);
recallValues    = zeros(nFolds, 1);
f1Values        = zeros(nFolds, 1);
runtimeValues   = zeros(nFolds, 1);
ruleCountValues = zeros(nFolds, 1);

confusionMatrices = zeros( ...
    dataset.nClasses, ...
    dataset.nClasses, ...
    nFolds);

%% ========================================================================
% Cross-validation loop
%% ========================================================================

for fold = 1:nFolds

    fprintf('\n');
    fprintf('----------------------------------------------\n');
    fprintf(' Fold %d of %d\n', fold, nFolds);
    fprintf('----------------------------------------------\n');

    testMask  = foldIndex == fold;
    trainMask = ~testMask;

    XTrain = dataset.X(trainMask, :);
    YTrain = dataset.Y(trainMask);

    XTest = dataset.X(testMask, :);
    YTest = dataset.Y(testMask);

    trainDataset = createDatasetSubset( ...
        XTrain, ...
        YTrain, ...
        dataset);

    fprintf('Training samples : %d\n', size(XTrain, 1));
    fprintf('Testing samples  : %d\n', size(XTest, 1));

    %% Start runtime measurement

    foldStartTime = tic;

    %% Initialize B4M population

    population = initializePopulation( ...
        trainDataset, ...
        cfg);

    %% Run B4M optimization

    globalBestFitness = -inf;

    for iteration = 1:cfg.maxIteration

        [population, iterationBestBee] = eliteSelection( ...
            population, ...
            trainDataset, ...
            cfg);

        if iterationBestBee.Rule.Fitness > globalBestFitness
            globalBestFitness = iterationBestBee.Rule.Fitness;
        end

    end

    %% Test-set prediction

    [yPred, foldMetrics, selectedRuleSet] = ...
        predictTestSet( ...
            population, ...
            XTest, ...
            YTest, ...
            trainDataset, ...
            cfg);

    runtimeValues(fold) = toc(foldStartTime);

    %% Store fold results

    accuracyValues(fold)  = foldMetrics.Accuracy;
    precisionValues(fold) = foldMetrics.Precision;
    recallValues(fold)    = foldMetrics.Recall;
    f1Values(fold)        = foldMetrics.F1Score;

    ruleCountValues(fold) = numel(selectedRuleSet);

    confusionMatrices(:, :, fold) = ...
        foldMetrics.ConfusionMatrix;

    fprintf('Accuracy  : %.4f\n', accuracyValues(fold));
    fprintf('Precision : %.4f\n', precisionValues(fold));
    fprintf('Recall    : %.4f\n', recallValues(fold));
    fprintf('F1-Score  : %.4f\n', f1Values(fold));
    fprintf('Rules     : %d\n', ruleCountValues(fold));
    fprintf('Runtime   : %.4f seconds\n', runtimeValues(fold));

    fprintf('Confusion Matrix:\n');
    disp(foldMetrics.ConfusionMatrix);

end

%% ========================================================================
% Aggregate results
%% ========================================================================

cvResults = struct();

cvResults.FoldAccuracy  = accuracyValues;
cvResults.FoldPrecision = precisionValues;
cvResults.FoldRecall    = recallValues;
cvResults.FoldF1Score   = f1Values;
cvResults.FoldRuntime   = runtimeValues;
cvResults.FoldRuleCount = ruleCountValues;

cvResults.MeanAccuracy  = mean(accuracyValues);
cvResults.StdAccuracy   = std(accuracyValues);

cvResults.MeanPrecision = mean(precisionValues);
cvResults.StdPrecision  = std(precisionValues);

cvResults.MeanRecall    = mean(recallValues);
cvResults.StdRecall     = std(recallValues);

cvResults.MeanF1Score   = mean(f1Values);
cvResults.StdF1Score    = std(f1Values);

cvResults.MeanRuntime   = mean(runtimeValues);
cvResults.StdRuntime    = std(runtimeValues);

cvResults.MeanRuleCount = mean(ruleCountValues);
cvResults.StdRuleCount  = std(ruleCountValues);

cvResults.TotalConfusionMatrix = ...
    sum(confusionMatrices, 3);

%% ========================================================================
% Display summary
%% ========================================================================

fprintf('\n');
fprintf('==============================================\n');
fprintf(' Cross-Validation Summary\n');
fprintf('==============================================\n');

fprintf('Accuracy  : %.4f +/- %.4f\n', ...
    cvResults.MeanAccuracy, ...
    cvResults.StdAccuracy);

fprintf('Precision : %.4f +/- %.4f\n', ...
    cvResults.MeanPrecision, ...
    cvResults.StdPrecision);

fprintf('Recall    : %.4f +/- %.4f\n', ...
    cvResults.MeanRecall, ...
    cvResults.StdRecall);

fprintf('F1-Score  : %.4f +/- %.4f\n', ...
    cvResults.MeanF1Score, ...
    cvResults.StdF1Score);

fprintf('Runtime   : %.4f +/- %.4f seconds\n', ...
    cvResults.MeanRuntime, ...
    cvResults.StdRuntime);

fprintf('Rule Count: %.2f +/- %.2f\n', ...
    cvResults.MeanRuleCount, ...
    cvResults.StdRuleCount);

fprintf('\nAggregated Confusion Matrix:\n');
disp(cvResults.TotalConfusionMatrix);

end


%% =========================================================================
% LOCAL FUNCTION: CREATE STRATIFIED FOLDS
%% =========================================================================

function foldIndex = createStratifiedFolds(Y, nClasses, nFolds)

Y = Y(:);

nSamples = numel(Y);

foldIndex = zeros(nSamples, 1);

for classID = 1:nClasses

    classSampleIndex = find(Y == classID);

    classSampleIndex = ...
        classSampleIndex(randperm(numel(classSampleIndex)));

    for i = 1:numel(classSampleIndex)

        assignedFold = mod(i - 1, nFolds) + 1;

        foldIndex(classSampleIndex(i)) = assignedFold;

    end

end

end


%% =========================================================================
% LOCAL FUNCTION: CREATE TRAINING DATASET STRUCTURE
%% =========================================================================

function subset = createDatasetSubset(X, Y, originalDataset)

subset = struct();

subset.X = X;
subset.Y = Y(:);

subset.nSamples  = size(X, 1);
subset.nFeatures = size(X, 2);
subset.nClasses  = originalDataset.nClasses;

subset.FeatureNames = originalDataset.FeatureNames;
subset.classNames   = originalDataset.classNames;

subset.Xmin = min(X, [], 1);
subset.Xmax = max(X, [], 1);

subset.XminK = zeros( ...
    subset.nClasses, ...
    subset.nFeatures);

subset.XmaxK = zeros( ...
    subset.nClasses, ...
    subset.nFeatures);

for classID = 1:subset.nClasses

    classMask = subset.Y == classID;

    if any(classMask)

        subset.XminK(classID, :) = ...
            min(X(classMask, :), [], 1);

        subset.XmaxK(classID, :) = ...
            max(X(classMask, :), [], 1);

    else

        subset.XminK(classID, :) = subset.Xmin;
        subset.XmaxK(classID, :) = subset.Xmax;

    end

end

end


%% =========================================================================
% LOCAL FUNCTION: PREDICT TEST SET
%% =========================================================================

function [yPred, metrics, ruleSet] = predictTestSet( ...
    population, XTest, YTest, trainDataset, cfg)

nClasses  = trainDataset.nClasses;
nFeatures = trainDataset.nFeatures;
nSamples  = size(XTest, 1);

nRulesPerClass = cfg.nRulesPerClass;

%% Select best rules for every class

ruleSet = struct( ...
    'Class', {}, ...
    'Fitness', {}, ...
    'Quality', {}, ...
    'Support', {}, ...
    'LowerBound', {}, ...
    'UpperBound', {});

ruleCounter = 0;

for classID = 1:nClasses

    matchingBeeIndex = find(arrayfun( ...
        @(bee) bee.Rule.Class == classID, ...
        population));

    if isempty(matchingBeeIndex)
        continue;
    end

    classFitness = arrayfun( ...
        @(idx) population(idx).Rule.Fitness, ...
        matchingBeeIndex);

    [~, sortedOrder] = sort( ...
        classFitness, ...
        'descend');

    numberSelected = min( ...
        nRulesPerClass, ...
        numel(matchingBeeIndex));

    selectedBeeIndex = ...
        matchingBeeIndex(sortedOrder(1:numberSelected));

    for r = 1:numberSelected

        sourceRule = population(selectedBeeIndex(r)).Rule;

        ruleCounter = ruleCounter + 1;

        ruleSet(ruleCounter).Class = ...
            sourceRule.Class;

        ruleSet(ruleCounter).Fitness = ...
            sourceRule.Fitness;

        ruleSet(ruleCounter).Quality = ...
            sourceRule.Quality;

        ruleSet(ruleCounter).Support = ...
            sourceRule.Support;

        ruleSet(ruleCounter).LowerBound = ...
            sourceRule.LowerBound;

        ruleSet(ruleCounter).UpperBound = ...
            sourceRule.UpperBound;

    end

end

if isempty(ruleSet)
    error('No rules were selected for test-set prediction.');
end

%% Prediction

featureRange = trainDataset.Xmax - trainDataset.Xmin;
featureRange(featureRange == 0) = 1;

majorityClass = mode(trainDataset.Y);

yPred = zeros(nSamples, 1);

for i = 1:nSamples

    sample = XTest(i, :);

    classScore = -inf(nClasses, 1);
    classDistance = inf(nClasses, 1);

    for r = 1:numel(ruleSet)

        classID = ruleSet(r).Class;

        lower = ruleSet(r).LowerBound;
        upper = ruleSet(r).UpperBound;

        covered = all( ...
            sample(1:nFeatures) >= lower & ...
            sample(1:nFeatures) <= upper);

        if covered

            candidateScore = ...
                ruleSet(r).Fitness + ...
                0.001 * ruleSet(r).Quality + ...
                0.0001 * ruleSet(r).Support;

            classScore(classID) = max( ...
                classScore(classID), ...
                candidateScore);

        else

            belowDistance = max(lower - sample, 0);
            aboveDistance = max(sample - upper, 0);

            normalizedDistance = ...
                (belowDistance + aboveDistance) ./ featureRange;

            distanceValue = mean(normalizedDistance);

            classDistance(classID) = min( ...
                classDistance(classID), ...
                distanceValue);

        end

    end

    if any(isfinite(classScore))

        [~, predictedClass] = max(classScore);

    elseif any(isfinite(classDistance))

        [~, predictedClass] = min(classDistance);

    else

        predictedClass = majorityClass;

    end

    yPred(i) = predictedClass;

end

%% Metrics

metrics = calculateMetrics( ...
    YTest, ...
    yPred, ...
    nClasses);

end


%% =========================================================================
% LOCAL FUNCTION: CALCULATE METRICS
%% =========================================================================

function metrics = calculateMetrics(YActual, YPredicted, nClasses)

YActual = YActual(:);
YPredicted = YPredicted(:);

confusionMatrix = zeros(nClasses, nClasses);

for i = 1:numel(YActual)

    confusionMatrix( ...
        YActual(i), ...
        YPredicted(i)) = ...
        confusionMatrix( ...
            YActual(i), ...
            YPredicted(i)) + 1;

end

accuracy = ...
    sum(diag(confusionMatrix)) / numel(YActual);

precisionPerClass = zeros(nClasses, 1);
recallPerClass    = zeros(nClasses, 1);
f1PerClass        = zeros(nClasses, 1);

for classID = 1:nClasses

    truePositive = ...
        confusionMatrix(classID, classID);

    falsePositive = ...
        sum(confusionMatrix(:, classID)) - ...
        truePositive;

    falseNegative = ...
        sum(confusionMatrix(classID, :)) - ...
        truePositive;

    if truePositive + falsePositive > 0

        precisionPerClass(classID) = ...
            truePositive / ...
            (truePositive + falsePositive);

    end

    if truePositive + falseNegative > 0

        recallPerClass(classID) = ...
            truePositive / ...
            (truePositive + falseNegative);

    end

    precisionValue = precisionPerClass(classID);
    recallValue = recallPerClass(classID);

    if precisionValue + recallValue > 0

        f1PerClass(classID) = ...
            2 * precisionValue * recallValue / ...
            (precisionValue + recallValue);

    end

end

metrics = struct();

metrics.Accuracy = accuracy;
metrics.Precision = mean(precisionPerClass);
metrics.Recall = mean(recallPerClass);
metrics.F1Score = mean(f1PerClass);

metrics.PrecisionPerClass = precisionPerClass;
metrics.RecallPerClass = recallPerClass;
metrics.F1PerClass = f1PerClass;

metrics.ConfusionMatrix = confusionMatrix;

end