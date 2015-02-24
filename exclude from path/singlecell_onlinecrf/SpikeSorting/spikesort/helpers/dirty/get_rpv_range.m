function [lb,ub,ev] = get_rpv_range(N, T, RP, RPV )

   alpha = .05;
   lambda = N/T;

   [dummy, interval] = poissfit(RPV,alpha);
   lb = convert_to_percentage( interval(1), RP, N, T, lambda ); 
   ub = convert_to_percentage( interval(2), RP, N, T, lambda ); 
   ev = convert_to_percentage( RPV, RP, N, T, lambda );
  
end

function p = convert_to_percentage( RPV, RP, N, T, lambda )

    p =  (RPV / (2*RP*N)) / lambda;
    
    if isnan(p), p = 0; end
    if p>1, p= 1; end
        
end
