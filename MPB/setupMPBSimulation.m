function setupMPBSimulation(SimGroup)

%Specify this is an MPB simulation
SimGroup.type = 'MPB';


%Specfify properites based upon lattice type
switch SimGroup.MPBSimulation.latticeType
    
    case 'diamond'
        
        %Define basis point
        SimGroup.lattice.basisPoint = [-.125*SimGroup.lattice.a, -.125*SimGroup.lattice.a ,-.125*SimGroup.lattice.a];
        
        %Set lattice type
        SimGroup.lattice.type = 'diamond';
        
        %Setup lattice object
        SimGroup.lattice = SimGroup.lattice.setLattice;
        
        %Define constraints from lattice vectors
        SimGroup.lattice.defineConstraintsFrom = 'lattice vectors';
        
        %Setup lattice
        [colors, radii, positions,disorderSites, SimGroup.lattice] = latticeGen(SimGroup.lattice);
        
        positions = projectOntoBasis(positions,SimGroup.lattice.a1, SimGroup.lattice.a2, SimGroup.lattice.a3);
        
        %Determine if simulating for bands or density of states to set
        %k-points
        switch SimGroup.MPBSimulation.simulationType
            
            case 'bands'
                %K-Points, defining irreducible Brillouin zone, in canonical order
                SimGroup.MPBSimulation.kPoints(1).point = [0 .5 .5];
                SimGroup.MPBSimulation.kPoints(1).name  = 'X';
                
                SimGroup.MPBSimulation.kPoints(2).point = [0 .625 .375];
                SimGroup.MPBSimulation.kPoints(2).name  = 'U';
                
                SimGroup.MPBSimulation.kPoints(3).point = [0 .5 0];
                SimGroup.MPBSimulation.kPoints(3).name  = 'L';
                
                SimGroup.MPBSimulation.kPoints(4).point = [0 0 0];
                SimGroup.MPBSimulation.kPoints(4).name  = 'Gamma';
                
                SimGroup.MPBSimulation.kPoints(5).point = [0 .5 .5];
                SimGroup.MPBSimulation.kPoints(5).name  = 'X';
                
                SimGroup.MPBSimulation.kPoints(6).point = [.25 .75 .5];
                SimGroup.MPBSimulation.kPoints(6).name  = 'W';
                
                SimGroup.MPBSimulation.kPoints(7).point = [.375 .75 .375];
                SimGroup.MPBSimulation.kPoints(7).name  = 'K';
                
            case 'dos'
                
                SimGroup = kpointsMPBdos(SimGroup);
                
        end
        %Geometry of unit cell, will be propagated according to lattice
        %vectors
        index = 1;
        
        SimGroup.geometry(index).type = 'block';
        SimGroup.geometry(index).center = [0 0 0];
        SimGroup.geometry(index).size = 2*[SimGroup.lattice.a1_mult*SimGroup.MPBSimulation.a, ...
            SimGroup.lattice.a2_mult*SimGroup.MPBSimulation.a, SimGroup.lattice.a3_mult*SimGroup.MPBSimulation.a];
        SimGroup.geometry(index).epsilonRE = SimGroup.lattice.epsS;
        
        index = index + 1;
        
        
        
        if(SimGroup.MPBSimulation.coreShell) %If using core-shell lattice elements
            
            %Loop over all occupied lattice sites
            for k = 1:(size(positions,1))
                
                %Get center position including any positional disorder
                center =[positions(k,1), positions(k,2), positions(k,3)];
                SimGroup = shellGeometry(SimGroup, center);
                
            end
            
        else %Normal (homogenous) lattice elements
            
            %Loop over all occupied lattice sites
            for k = 1:(size(positions,1))
                SimGroup.geometry(index).type = 'sphere';
                %Get center position including any positional disorder
                center =[positions(k,1), positions(k,2), positions(k,3)];
                SimGroup.geometry(index).center = center;
                
                %Set radius and epsilon
                SimGroup.geometry(index).radius = radii(k);
                SimGroup.geometry(index).epsilonRE = SimGroup.lattice.epsL;
                SimGroup.geometry(index).color = colors(k,:);
                index = index + 1;
                
            end
        end
        
        
    case 'hexagonal'
        
        %Set lattice type
        SimGroup.lattice.type = 'hexagonal';
        
        %Define constraints from lattice vectors
        SimGroup.lattice.defineConstraintsFrom = 'lattice vectors';
        
        %Setup lattice object
        SimGroup.lattice = SimGroup.lattice.setLattice;
        
        %Handle 2D case
        switch SimGroup.MPBSimulation.dimensionality
           
            case '2D'
                SimGroup.lattice.a3 = [0 0 0];
            
        end
        
        %Define basis point
        SimGroup.lattice.basisPoint = SimGroup.lattice.a*(-1/3*SimGroup.lattice.a1 + -1/6*SimGroup.lattice.a2 + -1/4*SimGroup.lattice.a3);
        
        %Setup lattice
        [colors, radii, positions, disorderSites, SimGroup.lattice] = latticeGen(SimGroup.lattice);
        
        %Determine if simulating for bands or density of states to set
        %k-points
        switch SimGroup.MPBSimulation.simulationType
            
            case 'bands' %Compute band structure
                
                switch SimGroup.MPBSimulation.dimensionality
                    
                    case '2D'
                        
                        %K-Points, defining irreducible Brillouin zone, in canonical order
                        SimGroup.MPBSimulation.kPoints(1).point = [0 0 0];
                        SimGroup.MPBSimulation.kPoints(1).name  = 'Gamma';
                        
                        SimGroup.MPBSimulation.kPoints(2).point = [.5 0 0];
                        SimGroup.MPBSimulation.kPoints(2).name  = 'M';
                        
                        SimGroup.MPBSimulation.kPoints(3).point = [1/3 1/3 0];
                        SimGroup.MPBSimulation.kPoints(3).name  = 'K';
                        
                        SimGroup.MPBSimulation.kPoints(4).point = [0 0 0];
                        SimGroup.MPBSimulation.kPoints(4).name  = 'Gamma';
                        
                    case '3D'
                        
                        %K-Points, defining irreducible Brillouin zone, in canonical order
                        SimGroup.MPBSimulation.kPoints(1).point = [0 0 0];
                        SimGroup.MPBSimulation.kPoints(1).name  = 'Gamma';
                        
                        SimGroup.MPBSimulation.kPoints(2).point = [0 0 .5];
                        SimGroup.MPBSimulation.kPoints(2).name  = 'A';
                        
                        SimGroup.MPBSimulation.kPoints(3).point = [1/3 1/3 1/2];
                        SimGroup.MPBSimulation.kPoints(3).name  = 'H';
                        
                        SimGroup.MPBSimulation.kPoints(4).point = [1/3 1/3 0];
                        SimGroup.MPBSimulation.kPoints(4).name  = 'K';
                        
                        SimGroup.MPBSimulation.kPoints(5).point = [0 0 0];
                        SimGroup.MPBSimulation.kPoints(5).name  = 'Gamma';
                        
                        SimGroup.MPBSimulation.kPoints(6).point = [.5 0 0];
                        SimGroup.MPBSimulation.kPoints(6).name  = 'M';
                        
                        SimGroup.MPBSimulation.kPoints(7).point = [.5 0 .5];
                        SimGroup.MPBSimulation.kPoints(7).name  = 'L';
                        
                        SimGroup.MPBSimulation.kPoints(8).point = [0 0 .5];
                        SimGroup.MPBSimulation.kPoints(8).name  = 'A';
                        
                        %L-H
                        SimGroup.MPBSimulation.kPoints(9).point = [.5 0 .5];
                        SimGroup.MPBSimulation.kPoints(9).name  = 'L';
                        
                        SimGroup.MPBSimulation.kPoints(10).point = [1/3 1/3 1/2];
                        SimGroup.MPBSimulation.kPoints(10).name  = 'H';
                        
                        %M-K
                        SimGroup.MPBSimulation.kPoints(11).point = [.5 0 0];
                        SimGroup.MPBSimulation.kPoints(11).name  = 'M';
                        
                        SimGroup.MPBSimulation.kPoints(12).point = [1/3 1/3 0];
                        SimGroup.MPBSimulation.kPoints(12).name  = 'K';
                        
                end
                
            case 'dos'
                
                SimGroup = kpointsMPBdos(SimGroup);
                
        end
        
        %Geometry of unit cell, will be propagated according to lattice
        %vectors
        index = 1;
        SimGroup.geometry(index).type = 'block';
        SimGroup.geometry(index).center = [0 0 0];
        SimGroup.geometry(index).size = [SimGroup.MPBSimulation.a, SimGroup.MPBSimulation.a, sqrt(8/3)*SimGroup.MPBSimulation.a];        SimGroup.geometry(index).epsilonRE = SimGroup.lattice.epsS;
        index = index + 1;
        
        if(SimGroup.MPBSimulation.coreShell) %If using core-shell lattice elements
            
            %Loop over all occupied lattice sites
            for k = 1:(size(positions,1))
                
                %Get center position including any positional disorder
                center =[positions(k,1), positions(k,2), positions(k,3)];
                SimGroup = shellGeometry(SimGroup, center);
                
            end
            
        else %Normal (homogenous) lattice elements
            
            %Loop over all occupied lattice sites
            for k = 1:(size(positions,1))
                SimGroup.geometry(index).type = 'sphere';
                %Get center position including any positional disorder
                center =[positions(k,1), positions(k,2), positions(k,3)];
                
                %Project center onto basis of lattice vectors (MPB
                %specifies coordinates this way)
                center = projectOntoBasis(center,SimGroup.lattice.a1, SimGroup.lattice.a2, SimGroup.lattice.a3);
                
                SimGroup.geometry(index).center = center;
                
                %Set radius and epsilon
                SimGroup.geometry(index).radius = radii(k);
                SimGroup.geometry(index).epsilonRE = SimGroup.lattice.epsL;
                SimGroup.geometry(index).color = colors(k,:);
                index = index + 1;
                
            end
        end
        
    case 'fcc'
        
        %Define basis point
        SimGroup.lattice.basisPoint.X = 0;
        SimGroup.lattice.basisPoint.Y = 0;
        SimGroup.lattice.basisPoint.Z = 0;
        
        %Set lattice type
        SimGroup.lattice.type = 'fcc';
        
        %Setup lattice object
        SimGroup.lattice = SimGroup.lattice.setLattice;
        
        %Define constraints from lattice vectors
        SimGroup.lattice.defineConstraintsFrom = 'lattice vectors';
        
        %Setup lattice
        [colors, radii, positions,SimGroup.lattice] = latticeGen2(SimGroup.lattice);
        
        %Compute reciprocal vectors
        SimGroup.lattice = reciprocalVectors(SimGroup.lattice);
        
        %Determine if simulating for bands or density of states to set
        %k-points
        switch SimGroup.MPBSimulation.simulationType
            
            case 'bands'
                %K-Points, defining irreducible Brillouin zone, in canonical order
                SimGroup.MPBSimulation.kPoints(1).point = [0 .5 .5];
                SimGroup.MPBSimulation.kPoints(1).name  = 'X';
                
                SimGroup.MPBSimulation.kPoints(2).point = [0 .625 .375];
                SimGroup.MPBSimulation.kPoints(2).name  = 'U';
                
                SimGroup.MPBSimulation.kPoints(3).point = [0 .5 0];
                SimGroup.MPBSimulation.kPoints(3).name  = 'L';
                
                SimGroup.MPBSimulation.kPoints(4).point = [0 0 0];
                SimGroup.MPBSimulation.kPoints(4).name  = 'Gamma';
                
                SimGroup.MPBSimulation.kPoints(5).point = [0 .5 .5];
                SimGroup.MPBSimulation.kPoints(5).name  = 'X';
                
                SimGroup.MPBSimulation.kPoints(6).point = [.25 .75 .5];
                SimGroup.MPBSimulation.kPoints(6).name  = 'W';
                
                SimGroup.MPBSimulation.kPoints(7).point = [.375 .75 .375];
                SimGroup.MPBSimulation.kPoints(7).name  = 'K';
                
            case 'dos'
                
                SimGroup = kpointsMPBdos(SimGroup);
                
        end
        %Geometry of unit cell, will be propagated according to lattice
        %vectors
        index = 1;
        
        SimGroup.geometry(index).type = 'block';
        SimGroup.geometry(index).center = [0 0 0];
        SimGroup.geometry(index).size = [SimGroup.MPBSimulation.a, SimGroup.MPBSimulation.a, SimGroup.MPBSimulation.a];
        SimGroup.geometry(index).epsilonRE = SimGroup.lattice.epsS;
        
        index = index + 1;
        
        
        
        if(SimGroup.MPBSimulation.coreShell) %If using core-shell lattice elements
            
            %Loop over all occupied lattice sites
            for k = 1:(size(positions,1))
                
                %Get center position including any positional disorder
                center =[positions(k,1), positions(k,2), positions(k,3)];
                SimGroup = shellGeometry(SimGroup, center);
                
            end
            
        else %Normal (homogenous) lattice elements
            
            %Loop over all occupied lattice sites
            for k = 1:(size(positions,1))
                SimGroup.geometry(index).type = 'sphere';
                %Get center position including any positional disorder
                center =[positions(k,1), positions(k,2), positions(k,3)];
                SimGroup.geometry(index).center = center;
                
                %Set radius and epsilon
                SimGroup.geometry(index).radius = radii(k);
                SimGroup.geometry(index).epsilonRE = SimGroup.lattice.epsL;
                SimGroup.geometry(index).color = colors(k,:);
                index = index + 1;
                
            end
        end
        
        
    case '1D'
        
        %Define basis point
        SimGroup.lattice.basisPoint = [0 0 0];
        
        %Set lattice type
        SimGroup.lattice.type = '1D';
        
        SimGroup.MPBSimulation.dimensionality = '1D';
        
        %Setup lattice object
        SimGroup.lattice = SimGroup.lattice.setLattice;
        
        %Define constraints from lattice vectors
        SimGroup.lattice.defineConstraintsFrom = 'lattice vectors';
        
        %Setup lattice
        [colors, radius, positions,disorderSites, SimGroup.lattice] = latticeGen2(SimGroup.lattice);
        
        %Determine if simulating for bands or density of states to set
        %k-points
        switch SimGroup.MPBSimulation.simulationType
            
            case 'bands'
                %K-Points, defining irreducible Brillouin zone, in canonical order
                SimGroup.MPBSimulation.kPoints = SimGroup.lattice.criticalPoints;

            case 'dos'
                
                SimGroup = kpointsMPBdos(SimGroup);
                
        end
        %Geometry of unit cell, will be propagated according to lattice
        %vectors
        index = 1;
        
        SimGroup.geometry(index).type = 'block';
        SimGroup.geometry(index).center = [0 0 0];
        SimGroup.geometry(index).size = [SimGroup.MPBSimulation.a, 1, 1]; %MPB cannot handle 0 size objects
        SimGroup.geometry(index).epsilonRE = SimGroup.lattice.epsS;
        
        index = index + 1;
        
        %Loop over all occupied lattice sites
        for k = 1:(size(positions,1))
            SimGroup.geometry(index).type = 'block';
            %Get center position including any positional disorder
            center =[positions(k,1), positions(k,2), positions(k,3)];
            SimGroup.geometry(index).center = center;
            
            %Set element size and epsilon
            SimGroup.geometry(index).size = [radius(k) 1 1]; %MPB cannot handle 0 size objects
            SimGroup.geometry(index).epsilonRE = SimGroup.lattice.epsL;
            SimGroup.geometry(index).color = colors(k,:);
            index = index + 1;
            
        end
        
        
        
        
    case 'custom'
        
        %Custom lattice, all properties specified in simulation setup
        %script. Do nothing.
        
end

%Add epsilon.h5 to list of files to be output post-processed
index = length(SimGroup.MPBSimulation.MPBh5Files) + 1;
SimGroup.MPBSimulation.MPBh5Files(index).name = [SimGroup.name 'MPB-epsilon.h5'];
SimGroup.MPBSimulation.MPBh5Files(index).inUse_FLAG = true;

%Generate simulation files
writeSimFiles(SimGroup);

figure
SimGroup.plotGeometry;

end