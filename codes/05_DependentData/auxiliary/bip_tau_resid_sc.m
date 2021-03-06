
function [a_bip_sc, x_filt] = bip_tau_resid_sc(x, beta_hat, p, q) 


if p>0
phi_hat = beta_hat(1:p);
    if size(phi_hat,2)>size(phi_hat,1)
        phi_hat = phi_hat';
    end
else
    phi_hat = [];
end



if q>0
 theta_hat = beta_hat(p+1:end);
    if size(theta_hat,2)>size(theta_hat,1)
        theta_hat = theta_hat';
    end
else
 theta_hat = [];
end



N = length(x);
r = max(p,q);


a_bip = zeros(size(x));



x_sc = tau_scale(x); %
kap2 = 0.8724286; %kap=var(eta(randn(10000,1)));


if or(sum(abs(roots([1; -phi_hat]))>1),sum(abs(roots([1; -theta_hat]))>1))
sigma_hat = x_sc;
else
lamb = ma_infinity(phi_hat, -theta_hat, 100); % MA infinity approximation to compute scale used in eta function
sigma_hat = sqrt(x_sc^2/(1+kap2*sum(lamb.^2))); % scale used in eta function
end



if r == 0
     
  a_sc_bip = x_sc;
  a_bip = x;
  

else   
    
    if or(sum(abs(roots([1; -phi_hat]))>1),sum(abs(roots([1; -theta_hat]))>1))
    a_bip_sc = 10^10;
    else
    if p>=1 && q>=1 % ARMA models
        

        for ii=r+1:N 
            
            % BIP-ARMA residuals
            a_bip(ii)=x(ii)-phi_hat'*(x(ii-1:-1:ii-p)-a_bip(ii-1:-1:ii-p)+sigma_hat*eta(a_bip(ii-1:-1:ii-p)/sigma_hat))+theta_hat'*sigma_hat*eta(a_bip(ii-1:-1:ii-q)/sigma_hat);
        end 
     
      
        
        
    elseif p==0 && q>=1
        
        for ii=r+1:N   % MA models

            % BIP-MA residuals
            a_bip(ii)=x(ii)+theta_hat'*sigma_hat*eta(a_bip(ii-1:-1:ii-q)/sigma_hat);

        end
        
    elseif p>=1 && q==0 % AR models
        
        for ii=r+1:N
            
            % BIP-AR residuals
            a_bip(ii)=x(ii)-phi_hat'*(x(ii-1:-1:ii-p)-a_bip(ii-1:-1:ii-p)+sigma_hat*eta(a_bip(ii-1:-1:ii-p)/sigma_hat));

        end
    end

    a_bip_sc = tau_scale(a_bip(p+1:end));
        
        % cleaned signal
        x_filt = x;
        for ii = p+1:N
             x_filt(ii)=x(ii)-a_bip(ii)+sigma_hat*eta(a_bip(ii)/sigma_hat);
        end
    end
    
end

end