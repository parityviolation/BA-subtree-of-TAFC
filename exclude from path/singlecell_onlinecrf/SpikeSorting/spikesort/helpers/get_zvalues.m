function [z,dof] = get_zvalues( w, covar, r )

    if nargin < 3
        r = round( rank( covar ) /2 );
    end
   
    num_dims = size(w(:,:),2);
    num_spikes = size(w,1);
    last = [1:r] + num_dims  - r;
    
    % mean subtract
    w = detrend(w,'constant');
    
    % get the principal components 
    [v,d] = eig(covar);
    for j = 1:num_dims, v(:,j) = v(:,j); end
        
    v = v(:,last);
    w = (w*v);   
 
    
    dof = r;    
    % get z-scores
    z = zeros([1 num_spikes]);
    dinv = inv(d(last,last));
    for j = 1:num_spikes
        z(j) = w(j,:)*dinv*w(j,:)';
    end
            
end