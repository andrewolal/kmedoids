# kmedoids

A J implementation of the Voronoi iteration k-medoid algorithm
with greedy initialisation.

# Raison d'être

k-medoids attempts to find a set of k exemplars such that the
distance between all other points and their nearest exemplar
is minimised. You might conceive the brute force version of
this problem as trying every possible combination of k points,
each time measuring the distance of the rest of the data to
the nearest point and then picking the best set. In my opinion
it is more usefully thought about as a vector quantisation -
as opposed to a clustering - technique, at least when thinking
about where it is useful over and above staple algorithms such
as k-means. I.e. I'd use it where your objective is moreso the
lossy compression of a space to fewer points. The problem can
be shown to be NP-hard but there are good approximations such
as the PAM and CLARA algorithms. The big advantage of k-medoids
is that you can bring your own distance function. This gives
flexibility regarding how you might model the relationships
that you are interested in in your data. You can't do that
with k-means. If your distances are not Euclidean, k-means
might not converge, and if it does, what you get might be
nonesense.

Why another algorithm? The problem with the popular algorithms
for k-medoids is that they have a space complexity of O(N^2)
or worse, so they don't scale well to even moderately sized
dataset. The other problem is that more efficient versions are
fairly complex to implement and I like to be able to read the
code and understand what the thing is doing. Compared to PAM,
the algorithm herein has much better space complexity
(approximately O(kN)) and will run faster but it is more
sensitive to the initialisation and will likely perform worse.
However, it will likely be quicker and be useful on datasets
which are too big for PAM.

# How it works

## Voronoi iterations

The algorithm takes a randomised stab at k exemplars and then
iteratively improves the results until converge: that's the
gist of it. In more words:

1. Initialisation - pick the first point at random, put it in
the exemplar set. If the size of the exemplar set is less than
k, pick the point furthest from the closest exemplar and add
it. Keep doing this until there are k exemplars.

2. Classify - assign all points to their closest exemplars
according to a user specified distance function.

3. Improve - Within each exemplar cluster, check to see if
there is a point other than the exemplar that minimises the
sum of distances of all points in the cluster to the exemplar.
If there is, make that the exemplar for the cluster.

4. Keep going until the exemplars stop changing.

On every change of exemplars, the sum of distances of points
to their closest exemplar has to improve, so the algorithm is
convergent.

## Goodness of fit

It so happens that k-medoids has enough in common with Gaussian
mixture models (GMM) that the latter can be used as a working
model to analyse k-medoids results. The reason this is useful
is that it allows me to build a likelihood function which I
can then in turn use to calculate the AIC score. The AIC score
takes into account both relative model fit and the number of
parameters (k) and therefore penalises complexity. This makes
it possible to compare both k-medoid runs with the same and
different k parameters.

# *Caveat emptor*

1. This class of algorithms (including PAM et al) are local
optimisers and depend heavily on the initial value. Its easy
for the algorithm to fall into a local optimum and therefore
it is necessary to try many different starting points.

2. To make it viable for at least mid-sized data
(e.g. 100k-300k rows) the distance matrix is not precomputed,
the down side of which lots and lots of recomputation.
The algorithm spends the vast majority of its run time
recomputing distances. Its fairly fast nonetheless, but not
really as fast it would be if the distance matrix was
precomputed.

# Usage

## Function syntax

    k dist_func km X - Compute k-medoids for data X using
    dist_func.

    (k;M) dist_func kmbest X - Compute k-medoids M times
    using dist_func for data X and retain the run with the
    lowest AIC.

    medoids dist_func kmlabels data - Compute labels for
    each row in X using the medoids and dist_func.

    medoids dist_func kmAIC data - Compute the AIC score
    for the model specified by medoids, dist_func for
    data X.

## A usage example

I found some data for testing clustering [here](http://cs.joensuu.fi/sipu/datasets/).
Its all synthetic, and I've left a few CSVs in the data/ folder
if you want to play around. In this example I'll use
s1_15_clusters.csv which is a bunch of Gaussians with good
separation. There are 15 clusters. First thing we nee to do
is load the data:

    require 'tables/csv'
    ex_file=: './data/s1_15_clusters.csv'
    data=: makenum readcsv ex_file

If we already knew k and just wanted to do some quantising
we could write:

    15 ed_km_ km data

This function returns the index of 15 exemplars. The key
function is **km**. It is an adverb, and takes a distance
function to its left: **ed_km_**, squared Euclidean distance.
The right most argument is the data and the left most
argument is k. If we wanted to instead to run the algorithm
many times and return just the best run we could write:

    (15;50) ed_km_ kmbest data

This is akin to running **km ** 50 times and keeping the
indexes from the run with the lowest AIC score.

But say that we didn't know what k was, we could try
various possibilities for k, plot that against the
corresponding AIC scores and then decide which to use:

    k=:(2 + i. 29)
    tests=:(ed_km_ kmbest & data) each { k;50
    aic=: ,> (ed_km_ kmAIC & data @: ,) each tests

The code above calls kmbest for 2<=k<=30. Lets graph it:

    load 'plot'
    pd 'reset'
    pd 'pensize 2.1'
    pd 'color gray'
    pd 'title k vs AIC;ycaption AIC;xcaption k'
    pd (k;aic)
    pd 'show'

![k vs AIC](https://github.com/emiruz/kmedoids/blob/main/img/s1_aic.png?raw=true)

Conveniently, AIC flat-lines at k=15, so we can just
grab the corresponding results from the tests array:

    > 13 { tests

Lets plot the elemplars on off the data:

    pd 'reset'
    pd 'title Data vs exemplars;ycaption y;xcaption x'
    pd 'type dot'
    pd 'pensize 2.0'
    pd 'color gray'
    pd ;/ |: data
    pd 'color red'
    pd 'pensize 3.1'
    pd ;/ |: (> 13 { tests) { data

![Data vs exemplars](https://github.com/emiruz/kmedoids/blob/main/img/s1_clusters.png?raw=true)

# Status

I consider it WIP at the moment until it has a test suite
against it. Its fiddly in parts so the chances of subtle bugs
is fairly high and best teased out by tests against expected
outcomes.

# Todo

- [ ] Smoke tests

- [ ] References

# Contributions

Yes please. Better, faster, stronger : I'll gratefully accept.

# License

GPL3, please see the LICENSE file for details.

# References

Data prefixed with "s1"-"s4" comes from:

    Fränti and O. Virmajoki, "Iterative shrinking method for clustering problems", Pattern Recognition, 39 (5), 761-765, May 2006.

Data prefixed "birch" comes from:

    Zhang et al., "BIRCH: A new data clustering algorithm and its applications", Data Mining and Knowledge Discovery, 1 (2), 141-182, 1997.

Data prefixed "d32" comes from:

    P. Fränti, O. Virmajoki and V. Hautamäki, "Fast agglomerative clustering using a k-nearest neighbor graph", IEEE Trans. on Pattern Analysis and Machine Intelligence, 28 (11), 1875-1881, November 2006.
