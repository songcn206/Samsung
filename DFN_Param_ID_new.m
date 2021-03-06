clc
clear all
% EXAMPLE_1	 This script demonstrates PSO applied to the Ackley Problem [1]
%
%	find x = [x1,x2]' such that
%
%	min: f(x) = 20 + exp(1)
%			  - 20*exp(-0.2*sqrt((1/n).*sum(x.^2,2))) ...
%		      - exp((1/n).*sum(cos(2*pi*x),2))
%
%	subject to:   x1 <= x2
%				x1^2 <= 4*x2
%				  -2 <= x <= 2 
%
% [1] Ebbesen, Kiwitz and Guzzella "A Generic Particle Swarm Optimization
%	  Matlab Function", 2012 American Control Conference, June 27-29,
%     Montreal, CA.
%
% Author(s):	Soren Ebbesen, 14-Sep-2011
%				sebbesen@idsc.mavt.ethz.ch
%
% Version:	1.1 (19-Jun-2013)
%
% Institute for Dynamic Systems and Control, Department of Mechanical and
% Process Engineering, ETH Zurich
%
% This Source Code Form is subject to the terms of the Mozilla Public License,
% v. 2.0. If a copy of the MPL was not distributed with this file, You can
% obtain one at http://mozilla.org/MPL/2.0/.

addpath(genpath('functions'))

% EXAMPLE 1: ACKLEY PROBLEM
% Options
options = pso;
options.PopulationSize	= 10;%24;
options.Vectorized		= 'off';
options.BoundaryMethod	= 'nearest'; %'penalize'
options.PlotFcns		= @psoplotbestf;
options.Display			= 'iter';
options.HybridFcn		= @fmincon;
options.Display		    = 'off';
%Problem
problem	= struct;
problem.fitnessfcn	= @DFN_error_new;
problem.nvars		= 4;
problem.Aineq		= [];
problem.bineq		= [];
% problem.lb			= [0.5E+02 0.5E+01 0.1300];% 1.00E-04];% 0.1600];
% problem.ub			= [1.50E+02  1.50E+01 0.1400];% 10.00E-04];% 0.1700];
%%%problem.lb			= [5E-04 1E-14 1E-14];% 1.00E-04];% 0.1600];
%%%problem.ub			= [20E-03  1E-12 1E-12];% 10.00E-04];% 0.1700];

problem.lb			      = [1.00E-10 0.35 0 0];    % Upper bound changed by HEP
problem.ub			      = [9.00E-10 0.48 0.1 0.1];    % Lower bound changed by HEP

%options.PopInitBest		  = [7.00E-04 1.40E-14 2E-14];      % Initial Personal Best (After Initial Run)
options.PopInitBest		  = [5.34E-10 0.38 0 0];      % Initial Personal Best (After Initial Run)


bounds.range        = problem.ub-problem.lb;                       % Range 
options.VelocityLimit= 0.1*bounds.range;	                       % Maximum Velocity of Particles


problem.nonlcon		= [];
problem.options		= options;

% Optimize
[x,fval,exitflag,output] = pso(problem);

% lb=[0.5E+02 0.5E+01]; %Set lower bounds
% ub=[1000 1000];
% x = [80, 80]; % Initial population
% % EXAMPLE 2: GA
% % Optimization options
% options = gaoptimset(...
% 'PopulationType','doubleVector',... % The type of Population being entered [ 'bitstring' | 'custom' | {'doubleVector'} ]
% 'PopInitRange', [lb;ub],... % Initial range of values a population may have
% 'PopulationSize', 4,... % Positive scalar indicating the number of individuals
% 'EliteCount', 1,... % Number of best individuals that survive to next generation without any change
% 'CrossoverFraction', 0.8,... % The fraction of genes swapped between individuals
% 'ParetoFraction', 0.35, ... % The fraction of population on non-dominated front
% 'MigrationDirection', 'both', ... % Direction that fittest individuals from the various sub-populations may migrate to other sub-populations
% 'MigrationInterval', 20,... % The number of generations between the migration of the fittest individuals to other sub-populations
% 'MigrationFraction', 0.2,... % Fraction of those individuals scoring the best that will migrate
% 'Generations', 10,... % Maximum number of generations allowed
% 'TimeLimit', Inf,...
% 'FitnessLimit', -Inf,... % Minimum fitness function value desired 
% 'StallGenLimit', 50,... % Number of generations over which cumulative change in fitness function value is less than TolFun
% 'StallTimeLimit', Inf,... % Maximum time over which change in fitness function value iGAs less than zero
% 'TolFun', 0,... % - Termination tolerance on fitness function value
% 'TolCon', 0,... % Termination tolerance on constraints (1e-6)
% 'InitialPopulation', x,... % The initial population used in seeding the GA algorithm; can be partial
% 'InitialScores',[],... % The initial scores used to determine fitness; used in seeding the GA algorithm; can be partial
% 'InitialPenalty', 10,... % Initial value of penalty parameter
% 'PenaltyFactor', 100,... % Penalty update parameter
% 'CreationFcn', @gacreationuniform,... % Function used to scale fitness scores.
% 'FitnessScalingFcn', @fitscalingrank,... % Function used to scale fitness scores / [ @fitscalingshiftlinear | @fitscalingprop | @fitscalingtop | {@fitscalingrank} ]*
% 'SelectionFcn', @selectionroulette,... % Function used in selecting parents for next generation / [ @selectionremainder | @selectionuniform | @selectionroulette  |  @selectiontournament | @selectionstochunif ]
% 'CrossoverFcn', @crossoverarithmetic,... % Function used to do crossover / [ @crossoverheuristic | @crossoverintermediate | @crossoversinglepoint | @crossovertwopoint | @crossoverarithmetic | @crossoverscattered ]
% 'MutationFcn', @mutationadaptfeasible,... % Function used in mutating genes / [ @mutationuniform | @mutationadaptfeasible | @mutationgaussian ]
% 'DistanceMeasureFcn', @distancecrowding,... % Function used to measure average distance of individuals from their neighbors
% 'HybridFcn',[],... %Another optimization function to be used once GA has normally terminated (for whatever reason)
% 'Display', 'final',...
% 'OutputFcns',[],...
% 'PlotFcns', @gaplotbestf, ... % Function(s) used in plotting various quantities
% 'PlotInterval', 1, ...
% 'Vectorized', 'off', ...
% 'UseParallel', 'always');
% 
% Fmin = @(x)DFN_error(x); % Objective function: Fmin, variable x(1),x(2),x(3)
% lb=[0.5E+02 0.5E+01]; %Set lower bounds
% % Optimize
% %[x,fval,exitflag,output] = pso(problem);
% [X, fval, exitflag] = ga(Fmin, 2, [],[],[],[], lb, [],[], options);
