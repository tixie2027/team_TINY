function lambdaR = propagateRUncertainty(V, Rg, Rn, Rp, Rf, Rd)
    % Relative uncertainty
    relUncertainty = 0.005;
    
    % Partial derivatives
    dRdV = (5 * Rd * Rf * Rn * (Rp + Rg)^2) / ((Rn * Rp + Rg * Rn) * V - 5 * Rg * Rn - 5 * Rf * Rg)^2;
    
    dRdRg = -(25 * Rd * Rf * (Rn + Rf) * Rp) / ((Rn * V - 5 * Rn - 5 * Rf) * Rg + Rn * Rp * V)^2;
    
    dRdRn = (5 * Rd * Rf * (Rp + Rg) * ((Rp + Rg) * V - 5 * Rg)) / (((Rp + Rg) * V - 5 * Rg) * Rn - 5 * Rf * Rg)^2;
    
    dRdRp = -(25 * Rd * Rf * (Rn + Rf) * Rp) / ((Rn * V - 5 * Rn - 5 * Rf) * Rg + Rn * Rp * V)^2;
    
    dRdRf = -(5 * Rd * Rn * (Rp + Rg) * ((Rp + Rg) * V - 5 * Rg)) / (5 * Rg * Rf + (-Rn * Rp - Rg * Rn) * V + 5 * Rg * Rn)^2;
    
    dRdRd = (Rp * (Rn * V + 5 * Rf) + Rg * Rn * (V - 5)) / (5 * Rf * Rg - Rn * (Rp * V + Rg * (V - 5)));
    
    % Uncertainty components
    lambdaV = 0.0048;
    lambdaRg = relUncertainty * Rg + 0.04;
    lambdaRn = relUncertainty * Rn + 0.004;
    lambdaRp = relUncertainty * Rp + 0.04;
    lambdaRf = relUncertainty * Rf + 0.004;
    lambdaRd = relUncertainty * Rd + 0.04;
    
    % Total uncertainty
    lambdaR = sqrt((dRdV * lambdaV)^2 + ...
                   (dRdRg * lambdaRg)^2 + ...
                   (dRdRn * lambdaRn)^2 + ...
                   (dRdRp * lambdaRp)^2 + ...
                   (dRdRf * lambdaRf)^2 + ...
                   (dRdRd * lambdaRd)^2);
end