%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bee for Mining Open Version (B4M-Open)
%
% File        : config.m
% Description : Global configuration
%
% Author      : Ari Sellyana
% Version     : 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cfg = config()

%% ==========================
% Dataset
% ===========================

cfg.datasetFile = fullfile("datasets","iris.csv");

cfg.classColumn = "last";

%% ==========================
% Bees Algorithm
% ===========================

cfg.nScout = 100;

cfg.maxIteration = 10;

cfg.nSelectedSites = 10;

cfg.nEliteSites = 10;

cfg.nEliteRecruit = 70;

cfg.nOtherRecruit = 20;

cfg.neighborhoodSize = 0.10;

%% ==========================
% Fitness
% ===========================

cfg.alpha = 0.5;

cfg.beta = 0.5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fitness Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfg.weightQuality = 0.70;

cfg.weightSupport = 0.30;

%% ==========================
% Rule
% ===========================

cfg.enablePruning = true;

cfg.maxRuleLength = inf;

%% ==========================
% Initial Rule Generation
% ===========================

cfg.initialRadius = 0.15;

%% ==========================
% Random
% ===========================

cfg.randomSeed = 1;

%% ==========================
% Display
% ===========================

cfg.verbose = true;

%% ==========================
% Prediction
% ===========================

cfg.nRulesPerClass = 5;

cfg.nFolds = 5;

end
