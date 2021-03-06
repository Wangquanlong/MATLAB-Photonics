classdef SimGroupObj
    %This class defines a group of simulation objects that define a
    %simulation run, including GeometryObj, SimulationObj, SourceObj,PbsObj
    
    properties
        simulation = SimulationObj; %MEEP Simulation variables
        MPBSimulation = MPBSimulationObj; %MPB Simulation variables
        geometry = GeometryObj; %Geometry descriptors (MEEP and MPB)
        geoProperties = GeoPropertiesObj; %Specialized geometry parameters (i.e. core-shell spheres)
        lattice = latticeGenObj %Lattice descriptors (MEEP Only)
        sources = SourceObj; %Sources (MEEP Only)
        harminv = HarminvObj %Harminv setup/data storage (MEEP Only)
        pbs = PbsObj; %.pbs script file definitions (MEEP and MPB)
        simVars = simVarObj %Override values for use in structure definition
        CCopt = CCoptimizationObj %Collective coordinate optimization properties
        EVNdata = EVNdataObj %Data from effective valley network calculation
        type %MEEP or MPB
        
        %Post processing data storage
        field %Storage electromagnetic field objects read in from data output
        
        %SimViewerApplicationProperties
        SVpath %Path when loaded into SimViewer-- should be same as that in simulation, unless folder has been moved
        checked = false %Indicates that checkbox for simulation is checked
        
        %Simulation Data
        
        %MEEP Data
        normFlux %Normalization run flux for calculating trans/refl spectrum
        reflFlux %Reflected flux for calculating trans/refl spectrum
        normFreq %Normalized frequencies
        reflectance %Computed reflectance data
        transmission %Computed transmission data
        
        reflData_FLAG = false %Flag to indicate that reflectance data has been loaded
        averagedData = false %Flag to indicate that this is an averaged data set
        
        %MPB Data
        MPBdata
        MPBData_FLAG = false %Flag to indicate that MPB data has been loaded
        
        %User Data -- used for passing data from simulation setup phase to
        %analysis phase
        user1
        
        %Notes
        notes %Storage for information specific to this simulation
        
        %Plotting
        colorNum %Color to use when plotting data-- number (1-8) corresponds to a color in the color matrix of SimViewerDataObj
        plotElement %Descriptors for plotted items associated with the current SimGroup
        plotYMin = 2;
        plotZMin = 2;
        
        %Name override
        overrideName = '' %Name to be used while plotting instead of simulation.name
        
        %File Management
        dir %Directory for current simulation family, all simulation runs will be saved here in individual folders, referenced from cluster
        name %Name for current simulation run, used to create subfolder in dir for inputs/outputs of current simulation
        localPath %Local path to cluster for file transfer, thus local path is "localPath/dir"
        
    end
    
    
    methods
        
        function obj = SimGroupObj()
            
            obj.plotElement = PlotElementObj;
            
        end
        
        function SimGroupText = print(obj)
            %This function calls print methods for simulation, pbs, geometry
            %and sources and returns the result as a single character array,
            %SimGroupText
            
            %Get simulation parameters
            SimGroupText = obj.simulation.print;
            
            %Get PBS parameters
            SimGroupText = [SimGroupText,obj.pbs.print];
            
            %Loop over all sources in simulation
            for k = 1:length(obj.sources)
                
                %Get source parameters
                SimGroupText = [SimGroupText,obj.sources.print(k)];
                
            end
            if(isprop(obj, 'notes'))
                SimGroupText = [SimGroupText '/n' obj.notes];
                
            end
            
        end
        function h = plotGeometry(obj)
            %This function plots the simulation geometry from the geometry
            %objects
            gcf;
            
            %Clear axes
            cla;
            
            hold on;
            
            
            %Loop over all geometry objects
            for k=1:length(obj.geometry)
                
                switch obj.geometry(k).type
                    
                    case 'sphere'
                        
                        %Check to see if color is defined for the lattice
                        %object
                        if(isprop(obj.geometry(k),'color') && ~isempty(obj.geometry(k).color))
                            color = obj.geometry(k).color;
                        else
                            color = [0 0 1]; %blue
                        end
                        
                        [x,y,z] = sphere; %Get unit sphere
                        %Apply radius
                        x = x*obj.geometry(k).radius;
                        y = y*obj.geometry(k).radius;
                        z = z*obj.geometry(k).radius;
                        
                        %Move center
                        x = x + obj.geometry(k).center(1);
                        y = y + obj.geometry(k).center(2);
                        z = z + obj.geometry(k).center(3);
                        
                        %Plot spheres
                        h = surf(x,y,z);
                        set(h, 'FaceColor',color,'FaceLighting', 'phong', 'AmbientStrength', 0.3, 'DiffuseStrength', 0.9, ...
                            'SpecularStrength', 0.5, 'SpecularExponent', 25, 'BackFaceLighting', 'lit', 'FaceAlpha',1, 'EdgeAlpha', 0);
                        
                    case 'cylinder'
                        
                        %Determine color
                        if(isprop(obj.geometry(k),'color') && ~isempty(obj.geometry(k).color))
                            cylColor = obj.geometry(k).color;
                        else
                            cylColor = [0 0 1]; %blue
                        end
                        
                        %Get properties
                        r1 = obj.geometry(k).radius;
                        r2 = obj.geometry(k).radius;
                        height = obj.geometry(k).height;
                        cylAxis = obj.geometry(k).axis;
                        center = obj.geometry(k).center;
                        
                        %Compute end points
                        X1 = center - .5*height*cylAxis;
                        X2 = center + .5*height*cylAxis;
                        
                        %Form radius vector
                        R = [r1; r2];
                        
                        %Number of elements
                        n = 20;
                        
                        %Plot cylinder
                        [Cone_h, EndPlate1_h, EndPlate2_h] = Cone(X1, X2, R, n, cylColor, 1, 1);
                        
                        
                    case 'cone'
                        
                        %Determine color
                        if(isprop(obj.geometry(k),'color') && ~isempty(obj.geometry(k).color))
                            coneColor = obj.geometry(k).color;
                        else
                            coneColor = [0 0 1]; %blue
                        end
                        
                        %Get properties
                        r1 = obj.geometry(k).radius;
                        r2 = obj.geometry(k).radius2;
                        height = obj.geometry(k).height;
                        coneAxis = obj.geometry(k).axis;
                        center = obj.geometry(k).center;
                        
                        %Compute end points
                        X1 = center - .5*height*coneAxis;
                        X2 = center + .5*height*coneAxis;
                        
                        %Form radius vector
                        R = [r1; r2];
                        
                        %Number of elements
                        n = 20;
                        
                        %Plot cone
                        [Cone_h, EndPlate1_h, EndPlate2_h] = Cone(X1, X2, R, n, coneColor, 1, 1);
                        
                        
                    case 'block'
                        
                        continue
                        
                        if(isprop(obj.geometry(k),'color') && ~isempty(obj.geometry(k).color))
                            color = obj.geometry(k).color;
                        else
                            color = [.5 .5 .5]; %blue
                        end
                        
                        transparency = 1;
                        
                        block = obj.geometry(k);
                        
                        %Check to make sure that Y and Z dimensions are
                        %large enough
                        if(block.size(2) < obj.plotYMin)
                            block.size(2) = obj.plotYMin;
                        end
                        
                        if(block.size(3) < obj.plotZMin)
                            block.size(3) = obj.plotZMin;
                        end
                        
                        %Plot block
                        h = plotBlock(block, transparency, color, 1);
                        
                        %                         set(h, 'FaceColor',color,'FaceLighting', 'phong', 'AmbientStrength', 0.3, 'DiffuseStrength', 0.9, ...
                        %                             'SpecularStrength', 0.5, 'SpecularExponent', 25, 'BackFaceLighting', 'lit', 'FaceAlpha',1, 'EdgeAlpha', 0);
                        %
                        
                    case 'ellipsoid'
                        
                end
            end
            geoPlotHandles = [];
            %Add planes to show source, reflectance
            
            %Loop over all sources
            for m = 1:length(obj.sources);
                
                %Check if source has been set
                if(isempty(obj.sources(m).size))
                    break
                end
                
                %Get size of source
                size = obj.sources(m).size;
                
                %Get origin of source
                origin = obj.sources(m).center;
                
                %Check if simulation is 2D
                if(obj.simulation.lat(3) == 0)
                    origin(3) = 0;
                    size(3) = 2; %Set size in Z dierction to make source visible
                    %Legacy support for souces without explictly defined Z value
                end
                
                %Set transparency for source
                transparency = .3;
                
                %Set Color for source
                color = [1 0 0];
                
                %Draw source
                %h = drawRect(origin,size,transparency,color);
                %geoPlotHandles = [geoPlotHandles; h];
            end
            
            %Loop over all flux regions
            for m = 1:length(obj.simulation.fluxRegion)
                
                
                %Check if flux region has been set
                if(isempty(obj.simulation.fluxRegion(m).size))
                    break
                end
                
                %Get size of flux region
                size = obj.simulation.fluxRegion(m).size;
                
                %Get origin of flux region
                origin = obj.simulation.fluxRegion(m).center;
                
                %Check if simulation is 2D
                if(obj.simulation.lat(3) == 0)
                    origin(3) = 0;
                    size(3) = 2; %Set size in Z dierction to make source visible
                    %Legacy support for flux regions without explictly defined Z value
                elseif ~isempty(obj.simulation.fluxRegion(m).center(3))
                    origin(3) = obj.simulation.fluxRegion(m).center(3);
                else
                    origin(3) = 0;
                end
                
                %Set transparency for flux region
                transparency = .3;
                
                %Set Color for fluxregion
                color = [0 1 0];
                
                %h = drawRect(origin,size,transparency,color);
                %geoPlotHandles = [geoPlotHandles; h];
                
            end
            
            if(~isempty(obj.simulation.lat))
                
                
                %Calculate axis scaling
                xmin = -1*obj.simulation.lat(1)/2 - obj.lattice.radius;
                xmax = obj.simulation.lat(1)/2 + obj.lattice.radius;
                ymin = -1*obj.simulation.lat(2)/2 - obj.lattice.radius;
                ymax = obj.simulation.lat(2)/2 + obj.lattice.radius;
                zmin = -1*obj.simulation.lat(3)/2 - obj.lattice.radius;
                zmax = obj.simulation.lat(3)/2 + obj.lattice.radius;
                
                %Check to see if cell is below minimum view size in Y or Z
%                 if(.5*ymax < obj.plotYMin)
%                     ymax = .5*obj.plotYMin;
%                     ymin = -1*ymax;
%                 end
%                 
%                 if(.5*zmax < obj.plotZMin)
%                     zmax = .5*obj.plotZMin;
%                     zmin = -1*zmax;
%                 end
%                 
                %Scale axis to fit cell
                axis([xmin xmax ymin ymax zmin zmax]);
                axis equal
                
            end
            
            set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'ZMinorTick', 'on');
            
            camlight headlight;
            lighting phong
            
            %Add plot labels
            %title('Simulation Geometry', 'FontSize', 16);
            xlabel('X [a]', 'FontSize', 13);
            ylabel('Y [a]', 'FontSize', 13);
            %zlabel('Z', 'FontSize', 14, 'Rotation', 0);
            
            set( gca, 'FontName', 'Helvetica', 'FontSize', 13);
            
            %Allow 3d rotation
            rotate3d on
            grid on
            grid minor
            
        end
        
        function plot1DGeometry(obj,ymin, ymax)
            %This function plots the geometry for a 1D structure in the XY
            %plane
            
            %Loop over all geometry objects
            for k = 1:length(obj.geometry)
                
                switch obj.geometry(k).type
                    %Ignore any object that isn't a block
                    
                    case 'block'
                        
                        %Create vertecies for polygon
                        xmin = obj.geometry(k).center(1) - obj.geometry(k).size(1)/2;
                        xmax = obj.geometry(k).center(1) + obj.geometry(k).size(1)/2;
                        
                        X = [xmin xmin xmax xmax];
                        Y = [ymin ymax ymax ymin];
                        FaceAlpha = 1;
                        EdgeAlpha = 1;
                        
                        if(~isempty(obj.geometry(k).color))
                            
                            h = patch(X, Y, obj.geometry(k).color);
                            
                            set(h, 'FaceColor', obj.geometry(k).color, 'EdgeColor', obj.geometry(k).color, 'FaceAlpha', FaceAlpha, 'EdgeAlpha', EdgeAlpha);
                            
                        end
                end
            end
            xmin = -1*obj.simulation.lat(1)/2 - obj.lattice.radius;
            xmax = obj.simulation.lat(1)/2 + obj.lattice.radius;
            
            %Scale axis to fit cell
            axis equal
            axis([xmin xmax ymin ymax]);
            
            
            set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');
            
            xlabel('X [a]', 'FontSize', 13);
            ylabel('Y [a]', 'FontSize', 13);
            set( gca, 'FontName', 'Helvetica', 'FontSize', 13);
            set(gca,'XTick',[-12:2:12])
            
            grid on
            grid minor
            
        end
        
        
        
        function obj = appendSimVar(obj,field, data)
            
            %Check if simVars is empty, assign into first element
            if(length(obj.simVars) == 1 && isempty(obj.simVars(1).field))
                obj.simVars(1).field = field;
                obj.simVars(1).data = data;
                
            else
                
                %Append data to simVars
                obj.simVars(length(obj.simVars)+1) = simVarObj;
                obj.simVars(length(obj.simVars)).field = field;
                obj.simVars(length(obj.simVars)).data = data;
                
            end
            
        end
        
        function centers = extractGeoCenters(obj)
            
            %Get points
            centers = [obj.geometry.center];
            
            %Reshape array
            centers = reshape(centers,3,length(obj.geometry))';
            
            
        end
        
        function save(obj, path)
            
            SimGroup = obj;
            
            if(isempty(path))
                %Save SimGroup to default location
                save([obj.localPath '/' obj.dir '/' ...
                    obj.name '/save/' obj.name '.mat'], 'SimGroup');
                
            else %Save SimGroup to specified location
                save([path '/save/' obj.name '.mat'], 'SimGroup');
                
                
            end
            
            
            
            
        end
        
    end
    
end
