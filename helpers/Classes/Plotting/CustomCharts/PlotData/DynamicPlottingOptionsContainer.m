classdef DynamicPlottingOptionsContainer < dynamicprops
    %DynamicPlottingOptionsContainer Contains information about the potentially displayed plots
    %   Detailed explanation goes here
	properties (Hidden)
    	propertyAddedListener
	  	propertyRemovedListener
   	end

    properties
        registeredCallbacks
    end

	methods (Access = public)

		function obj = DynamicPlottingOptionsContainer(ownerCallback, varargin)
            if iscell(ownerCallback)
                obj.registeredCallbacks = ownerCallback;
            else
                obj.registeredCallbacks = {ownerCallback};
            end

			obj.propertyAddedListener = addlistener(obj,'PropertyAdded',@DyPropEvtCb);
			obj.propertyRemovedListener = addlistener(obj,'PropertyRemoved',@DyPropEvtCb);

			num_args = length(varargin);
			if num_args > 1
				args = varargin;
				obj.addVariableArgumentsList(args{:});
            end
			

		end % end constructor

		function addVariableArgumentsList(obj, varargin)
			num_args = length(varargin);
			% if num_args < 1
			% 	error('provide properties!');
            % end

			for i = 1:num_args
				curr_arg = varargin{i};
				if isstruct(curr_arg)
					obj.addStructAsDynamicProperties(curr_arg);
				else
					error('Unknown argument type!');
				end
			end % end for

		end

		function addStructAsDynamicProperties(obj, aStruct)
			field_names = fieldnames(aStruct);
			for i = 1:length(field_names)
				curr_field_name = field_names{i};
				curr_field_value = aStruct.(curr_field_name);
				P(i) = obj.addprop(curr_field_name);
				P(i).Hidden = false;
				P(i).NonCopyable = false;
				obj.(curr_field_name) = curr_field_value;
			end

		end % end addStructAsDynamicProperties(...)
		

		function getDynamicPropNames(obj)
			% Find dynamic properties
			allprops = properties(obj);
			for i=1:numel(allprops)
				m = findprop(obj,allprops{i});
				if isa(m,'meta.DynamicProperty')
					disp(m.Name)
				end
			end
		end % end getDynamicPropNames(...)

	end % end Public Methods block



	methods(Access = protected)

		function DyPropEvtCb(src, evt)

			switch evt.EventName
				case 'PropertyAdded'
					switch evt.PropertyName
						case 'SpecialProp'
						% Take action based on the addition of this property
						%...
						%...
						src.HiddenProp = true;
						disp('SpecialProp added')
						otherwise
						% Other property added
						% ...
						disp([evt.PropertyName,' added'])
					end
				case 'PropertyRemoved'
					switch evt.PropertyName
						case 'SpecialProp'
						% Take action based on the removal of this property
						%...
						%...
						src.HiddenProp = false;
						disp('SpecialProp removed')
						otherwise
						% Other property removed
						% ...
						disp([evt.PropertyName,' removed'])
					end
			end % end switch

			% Perform the owner callback
			for anOwnerCallbackIndex = 1:length(obj.registeredCallbacks)
				currCallback = obj.registeredCallbacks{anOwnerCallbackIndex};
				currCallback(src, evt);
			end % end for 

		end % end DyPropEvtCb

	end % end protected Methods block



end % end classdef DynamicPlottingOptionsContainer
