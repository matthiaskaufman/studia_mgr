function errorVector = fObjectiveFunctionReturnVector(lambda, xRef, phiRef)

m = lambda(1);
l = lambda(2);
I = lambda(3);

[x, phi] = fSimulateModel(m, l, I);

errorX   = xRef - x;
errorPhi = phiRef - phi;

errorVector = [errorX;
               errorPhi];

end