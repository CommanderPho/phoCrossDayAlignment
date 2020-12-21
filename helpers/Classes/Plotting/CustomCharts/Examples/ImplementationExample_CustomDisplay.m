classdef ImplementationExample_CustomDisplay < matlab.graphics.chartcontainer.ChartContainer & ...
        matlab.mixin.CustomDisplay
        

	properties
		PropA = [1 0 0]
		PropB = 'test';
    end

    methods
		function obj = ImplementationExample_CustomDisplay(PropA, PropB, varargin)
			% Check for at least two inputs
			if nargin < 2
				error('Not enough inputs');
			end

			% Combine args with user-provided name-value pairs
			% args = [args varargin];
			args = varargin;
				
			% Call superclass constructor method
			obj@matlab.graphics.chartcontainer.ChartContainer(args{:});

			obj.PropA = PropA;
			obj.PropB = PropB;
		end
	end



	methods(Access = protected)

	%% matlab.mixin.CustomDisplay Overrides:
		% See https://www.mathworks.com/help/matlab/matlab_oop/ways-to-approach-customization.html
		function header = getHeader(obj)
			if ~isscalar(obj)
				% List for array of objects
				header = getHeader@matlab.mixin.CustomDisplay(obj);
			else
				headerStr = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
				headerStr = [headerStr,' with Customized Display'];
				header = sprintf('%s\n',headerStr);
			end
		end % end getHeader(...)


		function s = getFooter(obj)
			% The default implementation returns an empty char vector
            s = 'Here is my custom footer';
			% if ~isscalar(obj)
			% 	header = getHeader@matlab.mixin.CustomDisplay(obj);
			% else
			% 	headerStr = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
			% 	headerStr = [headerStr,' with Customized Display'];
			% 	header = sprintf('%s\n',headerStr);
			% end

        end % end getFooter(...)

    	% Called when this class is displayed
		function propgrp = getPropertyGroups(obj)
			if ~isscalar(obj)
				% List for array of objects
				propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
			else
				% List for scalar object
				propList = {'PropA','PropB'};
				% propList = struct('PropA',obj.PropA,...
				% 	'PropB',obj.PropB;
				propgrp = matlab.mixin.util.PropertyGroup(propList);
			end
		end % end getPropertyGroups(...)

	end % end main protected method block
	
end
