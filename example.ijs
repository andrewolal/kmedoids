load 'plot'
require 'voronoi.ijs'
require 'tables/csv'


NB. Make AIC dataset
ex_file=: './data/s2_15_clusters.csv'
data=: makenum readcsv ex_file                          NB. Read the CSV
k=: (2 + i. 29)                                         NB. Cluster sizes to test
tests=: (ed_km_ kmbest & data) each { k;20              NB. Best of 10 for each size
aic=: ,> (ed_km_ kmAIC & data @: ,) each tests          NB. AIC for each size


NB. Plot k vs AIC to discover number of clusters.
pd 'reset'
pd 'pensize 2.1'
pd 'color gray'
pd 'title k vs AIC;ycaption AIC;xcaption k'
pd (k;aic)
pd 'show'
pd 'save png img/s1_aic.png'


NB. Plot data and cluster centers.
pd 'reset'
pd 'title Data vs exemplars;ycaption y;xcaption x'
pd 'type dot'
pd 'pensize 2.0'
pd 'color gray'
pd ;/ |: data
pd 'color red'
pd 'pensize 3.1'
pd ;/ |: (> 13 { tests) { data                          NB. k=15 medoids
pd 'show'
pd 'save png img/s1_clusters.png'
