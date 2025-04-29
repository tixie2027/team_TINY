% Steinhart-hart Coefficients
% function T = tCalculate(A, B, C, D, R)
%     T = 1/(A+B*log(R)+C*(log(R)^2)+D*(log(R)^3)); 
% end

function T = tCalculate(B, T0, R0, R)
    T = ((log(R/R0)/B) + (1/T0))^(-1);
end