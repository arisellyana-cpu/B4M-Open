function bestBee = beeDance(parentBee, dataset, cfg, nRecruit)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bee for Mining Open Version (B4M-Open)
%
% Function    : beeDance
% Description : Perform local neighborhood search around one selected bee
%
% Inputs
%   parentBee : selected bee used as the center of local search
%   dataset   : dataset structure
%   cfg       : algorithm configuration
%   nRecruit  : number of recruited bees/candidate solutions
%
% Output
%   bestBee   : best bee obtained from neighborhood search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ------------------------------------------------------------------------
% Input validation
%% ------------------------------------------------------------------------

if nargin ~= 4
    error('beeDance requires parentBee, dataset, cfg, and nRecruit.');
end

if nRecruit < 1 || floor(nRecruit) ~= nRecruit
    error('nRecruit must be a positive integer.');
end

if ~isfield(parentBee, 'Rule')
    error('parentBee.Rule is missing.');
end

if ~isfield(cfg, 'neighborhoodSize')
    error('cfg.neighborhoodSize is missing.');
end

%% ------------------------------------------------------------------------
% Initialization
%% ------------------------------------------------------------------------

bestBee = parentBee;

featureRange = dataset.Xmax - dataset.Xmin;

% Prevent zero movement for constant-valued features
featureRange(featureRange == 0) = 1;

% Convert neighborhood size into a useful radius
if cfg.neighborhoodSize <= 1
    searchRadius = cfg.neighborhoodSize .* featureRange;
else
    searchRadius = 0.10 .* featureRange;
end

%% ------------------------------------------------------------------------
% Recruited-bee neighborhood search
%% ------------------------------------------------------------------------

for r = 1:nRecruit

    candidateBee = parentBee;

    lower = parentBee.Rule.LowerBound;
    upper = parentBee.Rule.UpperBound;

    % Select at least one feature to modify
    featureIndex = randi(dataset.nFeatures);

    % Randomly perturb lower and upper bounds
    lowerShift = (2 * rand - 1) * searchRadius(featureIndex);
    upperShift = (2 * rand - 1) * searchRadius(featureIndex);

    lower(featureIndex) = lower(featureIndex) + lowerShift;
    upper(featureIndex) = upper(featureIndex) + upperShift;

    % Restrict bounds to dataset domain
    lower(featureIndex) = max( ...
        lower(featureIndex), ...
        dataset.Xmin(featureIndex));

    upper(featureIndex) = min( ...
        upper(featureIndex), ...
        dataset.Xmax(featureIndex));

    % Repair interval if lower exceeds upper
    if lower(featureIndex) > upper(featureIndex)

        midpoint = ...
            (lower(featureIndex) + upper(featureIndex)) / 2;

        halfWidth = 0.05 * featureRange(featureIndex);

        lower(featureIndex) = max( ...
            midpoint - halfWidth, ...
            dataset.Xmin(featureIndex));

        upper(featureIndex) = min( ...
            midpoint + halfWidth, ...
            dataset.Xmax(featureIndex));

    end

    % Generate candidate rule
    candidateBee.Rule = generateRule( ...
        lower, ...
        upper, ...
        parentBee.Rule.Class, ...
        dataset);

    % Evaluate candidate
    candidateBee = evaluateRule( ...
        candidateBee, ...
        dataset);

    % Calculate candidate fitness
    candidateBee = fitnessFunction( ...
        candidateBee, ...
        cfg);

    % Retain candidate when fitness improves
    if candidateBee.Rule.Fitness > bestBee.Rule.Fitness

        bestBee = candidateBee;
        bestBee.LocalSearch = true;
        bestBee.Trial = 0;

    end

end

%% ------------------------------------------------------------------------
% Update bee state
%% ------------------------------------------------------------------------

bestBee.Age = parentBee.Age + 1;

if bestBee.Rule.Fitness <= parentBee.Rule.Fitness
    bestBee.Trial = parentBee.Trial + 1;
end

end