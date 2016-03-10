classdef spinop2 < spinoperator
%SPINOP2   Class for representing the spatial part of 2D differential operators 
%for time-dependent PDEs.
%   SPINOP2 is a class for representing the spatial part S of a time-dependent 
%   PDE of the form u_t = S(u) = Lu + N(u) in 2D, where L is a linear 
%   operator and N is a nonlinear operator. 
%
%   S = SPINOP2(PDECHAR) creates a SPINOP2 object S defined by the string 
%   PDECHAR. Strings available include 'GL2' for Ginzburg-Landau equation and 
%   'GS2' for Gray-Scott equations. Other PDEs are available, see HELP/SPIN2.
%
%   S = SPINOP2(DOM, TSPAN) creates a SPINOP2 object S on DOM x TSPAN. The other
%   fields of a SPINOP2 are its linear part S.LINEARPART, its nonlienar part
%   S.NONLINEARPART and the initial condition S.INIT. The fields can be set via
%   S.PROP = VALUE. See Remark 1 and Example 1.
%
% Remark 1: The linear part has to be of the form 
%           
%               @(u) A*laplacian(u) + B*biharmonic(u), 
%
%           for some numbers A and B, and the nonlinear part has to be of the 
%           form @(u) f(u), where f is a nonlinear function of u that does not 
%           involve any derivatives of u.
%
% Example 1: To construct a SPINOP2 corresponding to the GL2 equation on 
%            DOM = [0 200]^2 x TSPAN = [0 10] with initial condition 
%            u0(x,y) = cos(pi*x/100)*sin(y*pi/100), one can type
%
%            dom = [0 200 0 200]; tspan = [0 10];
%            S = spinop2(dom, tspan);
%            S.linearPart = @(u) lap(u);
%            S.nonlinearPart = @(u) u - (1+1.3i)*u.*(abs(u).^2);
%            S.init = chebfun2(@(x,y) cos(pi*x/100).*sin(y*pi/100), dom);
%
% See also SPINOPERATOR, SPINOP2, SPINOP3, SPIN2.

% Copyright 2016 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CLASS CONSTRUCTOR:
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods ( Access = public, Static = false )
        
        function S = spinop2(varargin)
            
            % Zero input argument:
            if ( nargin == 0 )
                return
            
            % One input argument:
            elseif ( nargin == 1 )
                if ( isa(varargin{1}, 'char') == 1 )
                    [L, N, dom, tspan, u0] = parseInputs(varargin{1});
                    S.linearPart = L;
                    S.nonlinearPart = N;
                    S.domain = dom;
                    S.tspan = tspan;
                    S.init = u0;
                else
                    error('SPINOP2:constructor', ['When constructing a ', ...
                        'SPINOP2 with one input argument, this argument ', ...
                        'should be a STRING.'])
                end
            
            % Two input arguments:
            elseif ( nargin == 2 )
                countDouble = 0;
                for j = 1:nargin
                    item =  varargin{j};
                    if ( isa(item, 'double') == 1 && countDouble == 0 )
                        S.domain = item;
                        countDouble = 1;
                    elseif ( isa(item, 'double') == 1 && countDouble == 1 )
                        S.tspan = item;
                    else
                    error('SPINOP2:constructor', ['When constructing a ', ...
                        'SPINOP2 with two input arguments, these arguments ', ...
                        'should be DOUBLE.'])
                    end
                end
                
            % More than two input arguments:    
            else
                error('SPINOP2:constructor', 'Too many input arguments.')
            end
            
        end
        
    end

end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %% METHODS IMPLEMENTED IN THIS FILE:
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

    function [L, N, dom, tspan, u0] = parseInputs(pdechar)
        %PARSEINPUTS   Parse inputs when using a STRING.
        %   [L, N, DOM, TSPAN, U0] = PARSEINPUTS(PDECHAR), where PDECHAR is a 
        %   string, outputs two function handles L and N which represent the 
        %   linear and the nonlinear parts of the PDE represented by PDECHAR, 
        %   the domain DOM, the time interval TSPAN and the initial condition
        %   U0.
            
        % Ginzburg-Landau equation:
        if ( strcmpi(pdechar, 'GL2') == 1 )
            L = @(u) lap(u);
            N = @(u) u - (1 + 1.5i)*u.*(abs(u).^2);
            dom = [0 100 0 100];
            tspan = [0 100];
            vals = .1*randn(128, 128);
            u0 = chebfun2(vals, dom, 'trig');
            
        % Gray-Scott equations:
        elseif ( strcmpi(pdechar, 'GS2') == 1 )
            L = @(u,v) [2e-5*lap(u); 1e-5*lap(v)];
            N = @(u,v) [3.5e-2*(1 - u) - u.*v.^2; -9.5e-2*v + u.*v.^2];
            G = 1.25;
            dom = G*[0 1 0 1];
            tspan = [0 8000];
            u01 = @(x,y) 1 - exp(-150*((x-G/2.05).^2 + (y-G/2.05).^2));
            u01 = chebfun2(u01, dom, 'trig');
            u02 = @(x,y) exp(-150*((x-G/2).^2 + 2*(y-G/2).^2));
            u02 = chebfun2(u02, dom, 'trig');
            u0 = [u01; u02];
    
        % Schnakenberg equations:
        elseif ( strcmpi(pdechar, 'Schnak2') == 1 )
            L = @(u,v) [lap(u); 10*lap(v)];
            N = @(u,v) [.1 - u + u.^2.*v; .9 - u.^2.*v];
            G = 50;
            dom = G*[0 1 0 1];
            tspan = [0 200];
            u01 = @(x,y) 1 - exp(-10*((x-G/2).^2 + (y-G/2).^2));
            u01 = chebfun2(u01, dom, 'trig');
            u02 = @(x,y) exp(-10*((x-G/2).^2 + 2*(y-G/2).^2));
            u02 = chebfun2(u02, dom, 'trig');
            u0 = [u01; u02];
    
        % Swift-Hohenberg equation:
        elseif ( strcmpi(pdechar, 'SH2') == 1 )
            L = @(u) -2*lap(u) - biharm(u);
            N = @(u) -.9*u + u.^2 - u.^3;
            G = 50;
            dom = G*[0 1 0 1];
            tspan = [0 200];
            vals = .1*randn(64, 64);
            u0 = chebfun2(vals, dom, 'trig');
            
        else
            error('SPINOP2:parseInputs', 'Unrecognized PDE.')
        end

    end