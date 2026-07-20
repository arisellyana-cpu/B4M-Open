function population = initializePopulation(dataset, cfg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bee for Mining Open Version (B4M-Open)
%
% Function    : initializePopulation
% Description : Generate initial scout-bee population using data-driven
%               rule initialization.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Input validation
if nargin ~= 2
    error('initializePopulation requires dataset and cfg.');
end

if ~isfield(cfg, 'nScout')
    error('cfg.nScout is missing.');
end

if ~isfield(cfg, 'initialRadius') || isempty(cfg.initialRadius)
    cfg.initialRadius = 0.15;
end

if cfg.initialRadius <= 0 || cfg.initialRadius > 1
    error('cfg.initialRadius must be in the interval (0,1].');
end

requiredDatasetFields = { ...
    'X', 'Y', 'nSamples', 'nFeatures', ...
    'Xmin', 'Xmax'};

for k = 1:numel(requiredDatasetFields)
    if ~isfield(dataset, requiredDatasetFields{k})
        error('dataset.%s is missing.', requiredDatasetFields{k});
    end
end

nScout = cfg.nScout;

%% Preallocate population
population(1, nScout) = createBee(1);

for i = 1:nScout
    population(i) = createBee(i);
end

%% Feature range and initial radius
featureRange = dataset.Xmax - dataset.Xmin;
radius = cfg.initialRadius .* featureRange;

%% Generate scout bees
for i = 1:nScout

    % Select an actual training sample as the rule center
    sampleIndex = randi(dataset.nSamples);

    centerPoint = dataset.X(sampleIndex, :);
    classID     = dataset.Y(sampleIndex);

    % Create interval around the selected sample
    lower = centerPoint - radius;
    upper = centerPoint + radius;

    % Restrict interval to the dataset domain
    lower = max(lower, dataset.Xmin);
    upper = min(upper, dataset.Xmax);

    % Generate rule
    population(i).Rule = generateRule( ...
        lower, ...
        upper, ...
        classID, ...
        dataset);

    % Evaluate rule
    population(i) = evaluateRule( ...
        population(i), ...
        dataset);

    % Calculate fitness
    population(i) = fitnessFunction( ...
        population(i), ...
        cfg);

end

end