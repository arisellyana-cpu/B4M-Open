function dataset = loadDataset(cfg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bee for Mining Open Version (B4M-Open)
%
% Function : loadDataset
% Purpose  : Load CSV/XLS/XLSX dataset and prepare metadata
%
% Input
%   cfg.datasetFile
%
% Output
%   dataset structure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nLoading dataset...\n');

%% ------------------------------------------------------------------------
% Check File
%% ------------------------------------------------------------------------

if ~isfile(cfg.datasetFile)
    error('Dataset file not found:\n%s', cfg.datasetFile);
end

%% ------------------------------------------------------------------------
% Read Dataset
%% ------------------------------------------------------------------------

[~,~,ext] = fileparts(cfg.datasetFile);

switch lower(ext)

    case '.csv'

        opts = detectImportOptions(cfg.datasetFile,...
            'VariableNamingRule','preserve');

        T = readtable(cfg.datasetFile,opts);

    case {'.xls','.xlsx'}

        T = readtable(cfg.datasetFile);

    otherwise

        error('Unsupported dataset format.');

end

%% ------------------------------------------------------------------------
% Check Dataset
%% ------------------------------------------------------------------------

if width(T) < 2
    error('Dataset must contain at least one feature and one class.');
end

%% ------------------------------------------------------------------------
% Feature Names
%% ------------------------------------------------------------------------

dataset.FeatureNames = string(T.Properties.VariableNames(1:end-1));

%% ------------------------------------------------------------------------
% Feature Matrix
%% ------------------------------------------------------------------------

X = zeros(height(T),width(T)-1);

for i = 1:width(T)-1

    col = T{:,i};

    if iscell(col)
        col = str2double(col);
    end

    if isstring(col)
        col = str2double(col);
    end

    if iscategorical(col)
        col = double(col);
    end

    X(:,i) = double(col);

end


%% ------------------------------------------------------------------------
% Class Label
%% ------------------------------------------------------------------------

label = T{:,end};

% Jika label berupa text
if iscell(label) || isstring(label)

    [classNames,~,classIndex] = unique(label,'stable');

    dataset.Y = classIndex;

    dataset.classNames = classNames;

else

    dataset.Y = double(label);

    dataset.classNames = unique(label);

end

if ~isnumeric(dataset.Y)
    error('Class label gagal dikonversi menjadi numerik.');
end

%% ------------------------------------------------------------------------
% Store Dataset
%% ------------------------------------------------------------------------

dataset.X = X;

dataset.nSamples  = size(dataset.X,1);
dataset.nFeatures = size(dataset.X,2);

dataset.nClasses = numel(dataset.classNames);


%% ------------------------------------------------------------------------
% Global Min-Max
%% ------------------------------------------------------------------------

dataset.Xmin = min(dataset.X,[],1);

dataset.Xmax = max(dataset.X,[],1);

%% ------------------------------------------------------------------------
% Class-wise Min-Max
%% ------------------------------------------------------------------------

dataset.XminK = zeros(dataset.nClasses,dataset.nFeatures);

dataset.XmaxK = zeros(dataset.nClasses,dataset.nFeatures);

for k = 1:dataset.nClasses

    idx = dataset.Y==k;

    dataset.XminK(k,:) = min(dataset.X(idx,:),[],1);

    dataset.XmaxK(k,:) = max(dataset.X(idx,:),[],1);

end

%% ------------------------------------------------------------------------
% Display
%% ------------------------------------------------------------------------

fprintf('Dataset Successfully Loaded\n');

fprintf('Samples  : %d\n',dataset.nSamples);

fprintf('Features : %d\n',dataset.nFeatures);

fprintf('Classes  : %d\n',dataset.nClasses);

end