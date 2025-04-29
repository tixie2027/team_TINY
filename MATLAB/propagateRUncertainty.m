function lambdaR = propagateRUncertainty(V, Rg, Rn, Rp, Rf, Rd)
    % Relative uncertainty
    relUncertainty = 0.05;
    
    % Partial derivatives
    dRdV = (5 * Rd * Rf * Rn * (Rp + Rg)^2) / ((Rn * Rp + Rg * Rn) * V - 5 * Rg * Rn - 5 * Rf * Rg)^2;
    
    dRdRg = -(25 * Rd * Rf * (Rn + Rf) * Rp) / ((Rn * V - 5 * Rn - 5 * Rf) * Rg + Rn * Rp * V)^2;
    
    dRdRn = (5 * Rd * Rf * (Rp + Rg) * ((Rp + Rg) * V - 5 * Rg)) / (((Rp + Rg) * V - 5 * Rg) * Rn - 5 * Rf * Rg)^2;
    
    dRdRp = -(25 * Rd * Rf * (Rn + Rf) * Rp) / ((Rn * V - 5 * Rn - 5 * Rf) * Rg + Rn * Rp * V)^2;
    
    dRdRf = -(5 * Rd * Rn * (Rp + Rg) * ((Rp + Rg) * V - 5 * Rg)) / (5 * Rg * Rf + (-Rn * Rp - Rg * Rn) * V + 5 * Rg * Rn)^2;
    
    dRdR2 = (Rp * (Rn * V + 5 * Rf) + Rg * Rn * (V - 5)) / (5 * Rf * Rg - Rn * (Rp * V + Rg * (V - 5)));
    
    % Uncertainty components
    lambdaV = 0.0048;
    lambdaRg = relUncertainty * Rg;
    lambdaRn = relUncertainty * Rn;
    lambdaRp = relUncertainty * Rp;
    lambdaRf = relUncertainty * Rf;
    lambdaR2 = relUncertainty * Rd;
    
    % Total uncertainty
    lambdaR = sqrt((dRdV * lambdaV)^2 + ...
                   (dRdRg * lambdaRg)^2 + ...
                   (dRdRn * lambdaRn)^2 + ...
                   (dRdRp * lambdaRp)^2 + ...
                   (dRdRf * lambdaRf)^2 + ...
                   (dRdR2 * lambdaR2)^2);
end