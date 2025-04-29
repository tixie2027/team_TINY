% Steinhart-hart Coefficients
% function lambdaT = propagateTUncertainty(A, B, C, D, R, lambdaA, lambdaB, lambdaC, lambdaD, lambdaR)
% 
%     % Partial derivatives
%     dTdA1 = -1 / (A + D * log(R)^3 + C * log(R)^2 + B * log(R))^2;
% 
%     dTdB1 = -log(R) / (log(R) * B + D * log(R)^3 + C * log(R)^2 + A)^2;
% 
%     dTdC1 = -log(R)^2 / (log(R)^2 * C + D * log(R)^3 + B * log(R) + A)^2;
% 
%     dTdD1 = -log(R)^3 / (log(R)^3 * D + C * log(R)^2 + B * log(R) + A)^2;
% 
%     dTdR = -(3 * D * log(R)^2 + 2 * C * log(R) + B) / (R * (D * log(R)^3 + C * log(R)^2 + B * log(R) + A)^2);
% 
%     % Total uncertainty
%     lambdaT = sqrt((dTdA1 * lambdaA)^2 + ...
%                    (dTdB1 * lambdaB)^2 + ...
%                    (dTdC1 * lambdaC)^2 + ...
%                    (dTdD1 * lambdaD)^2 + ...
%                    (dTdR * lambdaR)^2);
% end

% Simple equation
function lambdaT = propagateTUncertainty(B, R0, T0, R, lambdaB, lambdaR0, lambdaR)

    % Partial derivatives
    dTdB = (log(R / R0) * T0^2) / (B + log(R / R0) * T0)^2;

    dTdR0 = 1 / (B * (log(R / R0) / B + 1 / T0)^2 * R0);

    dTdR = -1 / (B * R * (log(R / R0) / B + 1 / T0)^2);

    % Total uncertainty
    lambdaT = sqrt((dTdB * lambdaB)^2 + ...
                   (dTdR0 * lambdaR0)^2 + ...
                   (dTdR * lambdaR)^2);
end