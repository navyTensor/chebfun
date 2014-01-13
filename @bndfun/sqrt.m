function f = sqrt(f)
%SQRT   Square root of a BNDFUN.
%   SQRT(F) returns the square root of a BNDFUN F. Note, it is assumed that the
%   only roots of F are located at the endpoints of F.domain. Note, it is
%   assumed that F is non-zero on its domain. If F has zeros, then the output is
%   garbage without throwing a warning.
%
% See also POWER.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

% If there are roots at the end of the domain, then make the f.onefun a singfun:
lval = get(f, 'lval');                         % Value at left of domain.
rval = get(f, 'rval');                         % Value at right of domain.
tol = 100*get(f, 'epslevel').*get(f, 'vscale'); % Tolerance for a root.

% Whether F has a vanishing value at any end point determines which SQRT() we'll
% call, the SMOOTHFUN one or the SINGFUN one.

if ( any(abs(lval) < tol) || any(abs(rval) < tol) )
    f.onefun = singfun(f.onefun);
end

% [TODO]: Revive the loop below for quasimatrix.
%
%     numFuns = size(f, 2);
%
%     % Loop over each column:
%     for k = 1:numFuns
%
%         % Extract each column and store them in cells:
%         g = extractColumns(f, k);
%
%         % Cast f.onefun to a SINGFUN:
%         g.onefun = singfun(g.onefun);
%
%         % Call SQRT()@SINGFUN:
%         h = sqrt(g.onefun);
%
%         % Put it back to the corresponding column:
%         f = assignColumns(f, k, h);
%     end

% Call SQRT of the ONEFUN:
f.onefun = sqrt(f.onefun);

end