%% 返回值，动态步长；
function [h] = CPFCalculateStepSize(busNumber, TangentVector)
    if busNumber < 100
        r = 0.2;
    else
        r = 0.15;
    end
    dim = length(TangentVector) - 1;
    dlambda = TangentVector(end);
    sum = 0;
    for x = 1:1:dim
        sum = sum + (TangentVector(x) / dlambda)^2;
    end
    
    h = sqrt( r^2 * busNumber / sum) / (2^6) / 10;
return