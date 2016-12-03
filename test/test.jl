__precompile__()

using Plots
Plots.plotlyjs()

module TestCompilierWarnings
    Plots.bar(randn(99))
end
