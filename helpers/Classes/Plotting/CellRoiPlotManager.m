classdef CellRoiPlotManager < PlotManager
    %CELLROIPLOTMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        interaction_helper_obj % InteractionHelper
        
        %% Graphical (TODO: potentially refactor)
        Colors
        
        testCellROIBlob_Plot_figH
    end
    
    %% Computed Properties:
    properties (Dependent)
        final_data_explorer_obj % FinalDataExplorer
    end
    methods
       function final_data_explorer_obj = get.final_data_explorer_obj(obj)
          final_data_explorer_obj = obj.interaction_helper_obj.final_data_explorer_obj;
       end
    end
    
    
    %% Main Methods Block:
    methods
        function obj = CellRoiPlotManager(final_data_explorer_obj, active_selections_backingFile_path)
            %CELLROIPLOTMANAGER Construct an instance of this class
            %   Detailed explanation goes here
            
            % Call PlotManager constructor:
            obj@PlotManager([]);
            

            %% Build Interaction Helper Object:
            obj.interaction_helper_obj = InteractionHelper(final_data_explorer_obj, 'Pho', active_selections_backingFile_path);
%             active_selections_backingFile_path = obj.interaction_helper_obj.BackingFile.fullPath;

            % Build Colors Arrays:
			obj = obj.SetupColors();
            
            obj.testCellROIBlob_Plot_figH
            
        end
        
        function obj = SetupColors(obj)
			% SetupColors: Build Color Matricies
			desiredSize = [512 512];
			obj.Colors.black3DArray = fnBuildCDataFromConstantColor([0.0 0.0 0.0], desiredSize);
			obj.Colors.darkgrey3DArray = fnBuildCDataFromConstantColor([0.3 0.3 0.3], desiredSize);
			obj.Colors.lightgrey3DArray = fnBuildCDataFromConstantColor([0.6 0.6 0.6], desiredSize);

			obj.Colors.orange3DArray = fnBuildCDataFromConstantColor([0.9 0.3 0.1], desiredSize);

			obj.Colors.red3DArray = fnBuildCDataFromConstantColor([1.0 0.0 0.0], desiredSize);
			obj.Colors.green3DArray = fnBuildCDataFromConstantColor([0.0 1.0 0.0], desiredSize);
			obj.Colors.blue3DArray = fnBuildCDataFromConstantColor([0.0 0.0 1.0], desiredSize);

			obj.Colors.darkRed3DArray = fnBuildCDataFromConstantColor([0.6 0.0 0.0], desiredSize);
			obj.Colors.darkGreen3DArray = fnBuildCDataFromConstantColor([0.0 0.6 0.0], desiredSize);
			obj.Colors.darkBlue3DArray = fnBuildCDataFromConstantColor([0.0 0.0 0.6], desiredSize);

        end
        

    end
end

