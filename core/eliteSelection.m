function [population, bestBee] = eliteSelection(population, dataset, cfg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bee for Mining Open Version (B4M-Open)
%
% Function    : eliteSelection
% Description : Sort population, select elite/selected sites, perform
%               neighborhood search, and replace unselected bees with
%               new scout bees.
%
% Inputs
%   population : Current bee population
%   dataset    : Dataset structure
%   cfg        : Algorithm configuration
%
% Outputs
%   population : Updated population
%   bestBee    : Best bee in the updated population
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ------------------------------------------------------------------------
% Input validation
%% ------------------------------------------------------------------------

if nargin ~= 3
    error('eliteSelection requires population, dataset, and cfg.');
end

nPopulation = numel(population);

if nPopulation < 1
    error('Population cannot be empty.');
end

requiredFields = { ...
    'nSelectedSites', ...
    'nEliteSites', ...
    'nEliteRecruit', ...
    'nOtherRecruit'};

for k = 1:numel(requiredFields)

    if ~isfield(cfg, requiredFields{k})
        error('cfg.%s is missing.', requiredFields{k});
    end

end

nSelectedSites = min(cfg.nSelectedSites, nPopulation);
nEliteSites    = min(cfg.nEliteSites, nSelectedSites);

%% ------------------------------------------------------------------------
% Sort population according to fitness
%% ------------------------------------------------------------------------

fitnessValues = arrayfun( ...
    @(bee) bee.Rule.Fitness, ...
    population);

[~, sortIndex] = sort(fitnessValues, 'descend');

population = population(sortIndex);

%% ------------------------------------------------------------------------
% Reset state information
%% ------------------------------------------------------------------------

for i = 1:nPopulation

    population(i).Rank = i;
    population(i).EliteFlag = false;
    population(i).LocalSearch = false;

end

%% ------------------------------------------------------------------------
% Search elite sites
%% ------------------------------------------------------------------------

for i = 1:nEliteSites

    population(i).EliteFlag = true;

    population(i) = beeDance( ...
        population(i), ...
        dataset, ...
        cfg, ...
        cfg.nEliteRecruit);

end

%% ------------------------------------------------------------------------
% Search other selected sites
%% ------------------------------------------------------------------------

for i = nEliteSites + 1:nSelectedSites

    population(i).EliteFlag = false;

    population(i) = beeDance( ...
        population(i), ...
        dataset, ...
        cfg, ...
        cfg.nOtherRecruit);

end

%% ------------------------------------------------------------------------
% Replace unselected sites with new scout bees
%% ------------------------------------------------------------------------

nNewScouts = nPopulation - nSelectedSites;

if nNewScouts > 0

    scoutCfg = cfg;
    scoutCfg.nScout = nNewScouts;

    newScouts = initializePopulation( ...
        dataset, ...
        scoutCfg);

    for i = 1:nNewScouts

        destinationIndex = nSelectedSites + i;

        newScouts(i).ID = destinationIndex;

        population(destinationIndex) = newScouts(i);

    end

end

%% ------------------------------------------------------------------------
% Sort updated population again
%% ------------------------------------------------------------------------

fitnessValues = arrayfun( ...
    @(bee) bee.Rule.Fitness, ...
    population);

[~, sortIndex] = sort(fitnessValues, 'descend');

population = population(sortIndex);

%% ------------------------------------------------------------------------
% Update rank and identification
%% ------------------------------------------------------------------------

for i = 1:nPopulation

    population(i).Rank = i;
    population(i).ID = i;

    population(i).EliteFlag = ...
        i <= nEliteSites;

end

%% ------------------------------------------------------------------------
% Return best bee
%% ------------------------------------------------------------------------

bestBee = population(1);

end