function confusion = gmm_overlap( data1, data2 )

   iters = 1000;
   N1 = size(data1,1);
   N2 = size(data2,1);
   ndims = size(data1(:,:),2);
   
   % project data onto 95% of its eigen spectrum
   covar = cov( [data1;data2]);
   r = round( rank( covar ) );
   [v,d] = eig(covar);
   
   % get 95% of eigen spectrum
   for j = 1:size(d,1), k(j) = d(j,j); end
   k = k/sum(k);
   r = length( find( cumsum(k) > .05 ) ); 
   last = [1:r] + ndims  - r;
  
   
   for j = 1:ndims, v(:,j) = v(:,j); end        
    v = v(:,last);
    data1 = (data1*v);
    data2 = (data2*v);
   ndims = r;
   
   
    % build up model
    mu1 = mean(data1(:,:));
    mu2 = mean(data2(:,:));
    c1  = cov( data1(:,:));
    c2 = cov( data2(:,:) );
    if rank(c1) == size(c1,1) & rank(c2) == size(c2,1)

        % sample models
        fake1 = repmat(mu1,[iters 1]) + randn( [iters ndims ]) * chol(c1);
        fake2 = repmat(mu2,[iters 1]) + randn( [iters ndims ]) * chol(c2);

        % get probability of each under the models
        resids11 = ( fake1 - repmat( mu1, [iters 1]) );
        resids12 = ( fake1 - repmat( mu2, [iters 1]) );
        resids21 = ( fake2 - repmat( mu1, [iters 1]) );
        resids22 = ( fake2 - repmat( mu2, [iters 1]) );


        ic1 = inv(c1);
        ic2 = inv(c2);
        % calculate likelihoods
        f1 = log( N1 / (N1 + N2) );
        f2 = log( N2 / (N1 + N2) );
        d1 = -.5*log(det(c1));
        d2 = -.5*log(det(c2));
        for j = 1:iters
           d11(j) = f1 + d1 - 0.5 * resids11(j,:) * ic1 * resids11(j,:)' ;
           d12(j) = f2 + d2 - 0.5 * resids12(j,:) * ic2 * resids12(j,:)' ;
           d21(j) = f1 + d1 - 0.5 * resids21(j,:) * ic1 * resids21(j,:)' ;
           d22(j) = f2 + d2 - 0.5 * resids22(j,:) * ic2 * resids22(j,:)' ;
        end    
    
        % build confusion matrix
        x1 =  sum( d11 < d12 ) / iters;
        x2 =  sum( d22 < d21 ) / iters;

        confusion(1,1) =   (1-x1)*N1/ ((1-x1)*N1 + x2*N2);
        confusion(1,2) =    x1*N1/ (x1*N1 + (1-x2)*N2);
        confusion(2,2) =   (1-x2)*N2/ ((1-x2)*N2 + x1*N1);
        confusion(2,1) =    x2*N2/ (x2*N2 + (1-x1)*N1);
   
    % element (j,k) of confusion is perecent of spikes in true class J that would be given
    % label K
    else
        confusion = -ones([2 2]);
    end
    
end


