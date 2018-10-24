function [a, varargout] = Test(ID, varargin)

t  = nargin;
tt = nargout;

a = ID + t;

varargout{1} = tt;
varargout{2} = tt*2;
varargout{3} = tt*3;