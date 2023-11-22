data {
  int<lower=1> n;
  int<lower=1> L;
  int<lower=1> K;
  int<lower=1> d;
  int<lower=1> Nmax;
  vector[n] y;
  matrix[n,d] C;
  matrix[Nmax,K] phi_mat[n];
  matrix[K, L] J;  
  // DATA for gaussian processes:
  int<lower=1> Nvec[n];
  real tobs[n, Nmax];
  vector[Nmax] xobs[n];
}
parameters {
  real delta;
  vector[d] alpha;
  simplex[L] beta;
  real<lower=0> sigma;
  real<lower=0> sigma_x;
  // GP parameters:
  matrix[n,K] xi;
  real<lower=0> sigma_xi[K];
}

model {
  // GP Prior distribution:
  for(i in 1:n ){
    xi[i] ~ normal(0, sigma_xi );
  }
  sigma_xi ~ lognormal(0,1);
  sigma_x ~ lognormal(0,1);
  // fRLM priors:
  delta ~ normal(0, 10);
  beta ~ dirichlet( rep_vector( 1.0 / L, L ) );
  sigma ~ lognormal(0,1);
  alpha ~ std_normal();
  // GP liklihood:
    for(i in 1:n ){
      xobs[i,:Nvec[i] ] ~ normal(phi_mat[i][:Nvec[i] ] * xi[i]', sigma_x );
    }
  //The likelihood of the fRLM
  for (i in 1:n){
    y[i] ~ normal( delta * xi[i] * J * beta + C[i] * alpha, sigma );
  }
}

