function varargout = svd( f )
%SVD Singular value decomposition of a chebfun2.
%
% SVD(F) returns the singular values of F. The number of singular values
% returned is equal to the rank of the chebfun2.
%
% S = SVD(F) returns the singular values of F. S is a vector of singular
% values in decreasing order.
%
% [U, S, V] = SVD(F) returns the SVD of F. U and V are quasi-matrices of
% orthogonal chebfuns and S is a diagonal matrix with the singular values
% on the diagonal.
%
% The length and rank of a chebfun2 are slightly different quantities.
% LENGTH(F) is the number of pivots used by the Chebfun2 constructor, and
% RANK(F) is the number of significant singular values of F. The relation
% RANK(F) <= LENGTH(F) should always hold.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Empty check:
if ( isempty( f ) )
    varargout = { chebfun, [], chebfun };
    return
end

if ( iszero( f ) ) 
    varargout = {0}; 
    return
end

% Get the low rank representation for f.
cols = f.cols;
rows = f.rows;
piv = f.pivotValues;
d = 1./piv;
d(abs(d) == inf) = 0;  % set infinite values to zero.

% Extract information:
dom = f.domain;
width = diff( dom( 1:2 ) );
height = diff( dom( 3:4 ) );

% If the function is the zero function then special care is required.
if ( norm( d ) == 0 )
    if ( nargout > 1 )
        U = chebfun2( 1./sqrt( width ), dom(1:2) );
        V = chebfun2( 1./sqrt( height ), dom(3:4) );
        varargout = { U, 0, V };
    else
        varargout = { 0 };
    end
    
else
    
    % If the function is non-zero then do the standard stuff.
    %
    % Algorithm:
    %   f = C D R'                 (cdr decomposition)
    %   C = Q_C R_C                (qr decomposition)
    %   R = Q_R R_R                (qr decomposition)
    %   f = Q_C (R_C D R_R') Q_R'
    %   R_C D R_R' = U S V'        (svd)
    
    [Qleft, Rleft] = qr( cols );
    [Qright, Rright] = qr( rows );
    [U, S, V] = svd( Rleft * diag( d ) * Rright.' );
    U = Qleft * U;
    V = Qright * V;
    
    % Output just like the svd of a matrix.
    if ( nargout > 1 )
        varargout = { U, S, V };
    else
        varargout = { diag( S ) };
    end
    
end

end