function error = fObjectiveFunctionReturnScalar(lambda, xRef, phiRef)

m = lambda(1);
l = lambda(2);
I = lambda(3);

[x, phi] = fSimulateModel(m, l, I);

errorX   = xRef - x;
errorPhi = phiRef - phi;

error = sum(errorX.^2) + sum(errorPhi.^2);

end