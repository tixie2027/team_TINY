function R = rCalculate(V, Rg, Rn, Rp, Rf, Rd)
    R = ((Rg*Rn*(-5 + V) + Rp*(5*Rf + Rn*V))*Rd) / ...
        (5*Rf*Rg - Rn*(Rg*(-5 + V) + Rp*V));
end