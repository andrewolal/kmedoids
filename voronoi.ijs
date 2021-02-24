NB. k-medoids: Voronoi iteration algorithm with kmeans++ initialisation.

require 'stats/base'

cocurrent 'z'

NB. Utility functions
small_km_=: 0.00000001
ed_km_=: 4 : 0                                             NB. Euclidean distance
row=. +/ @: *: @: (- & (|: y))
row "1 x
)
id_km_=: 3 : '(y,y) $ ((y+1){.1)'                          NB. Identity matrix
rng_km_=: ?                                                NB. Override to set seed
dot_km_=: +/ . *                                           NB. Dot product
det_km_=: -/ . *                                           NB. Determinant


NB. k-medoids Voronoi iteration algorithm
NB. Usage: k dist_func km data -> medoids
NB. Usage: medoids dist_func kmlabels data -> labels
inits_km_=: 1 : 'y,(i. >./) <./ (y { x) u x'
init_km_=: 1 : '}. y (u inits_km_)^:(x-1) 2 $ rng_km_ #y'
kmlabels=: 1 : '(i. <./) "1 |: (x { y) u y'
step_km_=: 1 : 0
vec=. x u kmlabels y
argm=. 1 : '{ & x (i. <./) (+/ u~ x { y)'
vec ((u argm) & y)/. i. #vec
)
km=: 1 : '((u step_km_) & y)^:_ (x (u init_km_) y)'


NB. GMM based AIC calculation.
NB. Usage: medoids dist_func kmAIC data -> AIC
liks_km_=: 4 : 0
m=. (stddev y)+small_km_
cov=. %. (id_km_ #x) * m                                  NB. Inverse cov. of Gaussian
det=. ^. (*/ m)                                           NB. Determinant of diagonal matrix
lik=. dot_km_ (cov & dot_km_)
lik=. +/(lik @:-&x) "1 y
lik=. lik +(det * #x)+(*/$y)*(^.o.2)
-0.5 * lik                                                NB. MV Gaussian log likelihood
)
kmAIC=: 1 : 0
lb=. x u kmlabels y
pars=. (;/ x),.(lb </. i. #lb)                            NB. Partition data by medoid cluster
lik=. (({&y@:>@:{.) liks_km_ ({&y@:>@:{:)) "1 pars        NB. Apply lik_step for each medoid
(2*#x)-2*(+/lik)                                          NB. Sum likelihood, calc. AIC
)

NB. Best of N.
NB. Usage: (k;reps) dist_func kmbest data -> medoids
kmbest=: 1 : 0
'k reps'=. x
ret=. ''
for. i. reps do.
  ret=. ret , <(k u km y)
end.
best=. (i. <.)/ > (u kmAIC & y) each ret
> best { ret
)