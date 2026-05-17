using RDatasets
using Clustering
using Plots

iris = dataset("datasets", "iris")
classes = describe(iris[:, [:Species]], :nunique)[:, :nunique][1]
features = collect(Matrix(iris[:, 1:4])')
R = kmeans(features, classes)

nclusters(R) == 3
scatter(iris.PetalLength, iris.PetalWidth, marker_z=R.assignments, color=:lightrainbow, legend=false)