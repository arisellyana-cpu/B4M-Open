# B4M-Open

B4M-Open is a reproducible MATLAB baseline implementation of Bee for Mining (B4M) for interpretable, interval-based rule classification.

This repository accompanies the conference paper:

> Ari Sellyana and Massudi Mahmuddin, "Bee for Mining (B4M) for Rule-Based Classification: Baseline Implementation and Experimental Evaluation," CAIS 2026.

## Contents

```text
B4M-Open/
|-- main_B4M.m              Main experiment script
|-- config.m                Experimental configuration
|-- loadDataset.m           CSV/XLS/XLSX dataset loader
|-- core/                   B4M optimization and evaluation functions
|-- datasets/iris.csv       Iris benchmark dataset
|-- models/                 Supporting model constructors
|-- CITATION.cff            Citation metadata
|-- LICENSE                 MIT License
`-- README.md               Reproduction instructions
```

## Requirements

- MATLAB R2021a or later (recommended)
- Statistics and Machine Learning Toolbox is not required by the supplied implementation

The code uses `detectImportOptions`, `readtable`, and string arrays. Earlier MATLAB versions may require minor compatibility changes.

## Reproducing the experiment

1. Download or clone this repository.
2. Open MATLAB and set the current folder to the repository root.
3. Run:

```matlab
main_B4M
```

The script loads the Iris dataset, initializes the scout-bee population, performs B4M optimization, constructs a multiclass rule set, reports classification metrics, and runs stratified five-fold cross-validation.

The fixed random seed is defined in `config.m`. Runtime values can vary across computers and MATLAB versions.

## Baseline configuration

| Parameter | Value |
|---|---:|
| Scout bees | 100 |
| Maximum iterations | 10 |
| Selected sites | 10 |
| Elite sites | 10 |
| Recruited bees per elite site | 70 |
| Recruited bees per other selected site | 20 |
| Initial rule radius | 0.15 |
| Neighborhood search size | 0.10 |
| Quality weight | 0.70 |
| Coverage/support weight | 0.30 |
| Rules per class | 5 |
| Cross-validation folds | 5 |
| Random seed | 1 |

## Coverage terminology

`Rule.Coverage` is the number of covered instances (samples). `Rule.Support` is the dimensionless normalized coverage ratio:

```text
Support = Coverage / number of samples
```

The fitness function uses rule quality and normalized coverage/support:

```text
Fitness = 0.70 * Quality + 0.30 * Support
```

## Dataset

The included Iris dataset contains 150 flower instances, four measurements in centimetres (sepal length, sepal width, petal length, and petal width), and three species labels. It is included solely to reproduce the benchmark experiment.

## Scope

This release is a transparent experimental baseline. The adaptive mechanisms planned for Dynamic Bee for Mining (D-B4M), including entropy-based adaptive weighting, dynamic neighborhood search, and hybrid MDL-MI pruning, are outside the scope of this baseline release.

## License

The source code is released under the MIT License. Dataset reuse remains subject to the terms of its original provider.

## Contact

Ari Sellyana  
Department of Informatics Engineering  
Institut Teknologi dan Bisnis Riau Pesisir, Dumai, Indonesia  
Email: arisellyana@itbriaupesisir.ac.id

