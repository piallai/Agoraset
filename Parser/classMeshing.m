classdef classMeshing < handle
    %classMeshing class containing cartesian meshing data
    %classMeshing Properties:
    %   file_path       - path of meshing file
    %   Nx              - number of meshes in the i-x direction
    %   Ny              - number of meshes in the j-y direction
    %   x               - x positions of meshes ([Nx, Ny])
    %   y               - y positions of meshes ([Nx, Ny])
    %   average_pitch   - used for meshing adapation to matlab's pcolor
    %classMeshing Methods:
    %   classMeshing(file_path) - constructor using the file path of the meshing
    %   classEnvironment(meshing, ratio) - constructor using another meshing being refined by a factor ratio
    
    properties
        
        file_path;
        Nx;
        Ny;
        x;
        y;
        
        
        average_pitch;
        
        
    end
    
    methods
        function self = classMeshing(varargin)
            
            numvarargs = length(varargin);
            if numvarargs == 1
                self.file_path = varargin{1};
                
                self.load();
            elseif numvarargs == 2
                meshing_in = varargin{1};
                ratio = varargin{2};
                self.file_path = strcat(meshing_in.file_path,'-r',num2str(ratio));
                
                self.Nx = meshing_in.Nx*ratio;
                self.Ny = meshing_in.Ny*ratio;
                
                [Y,X] = meshgrid(1/2:meshing_in.Ny-1/2, 1/2:meshing_in.Nx-1/2);
                [YI,XI] = meshgrid(1/(2*ratio):1/ratio:meshing_in.Ny-1/(2*ratio), 1/(2*ratio):1/ratio:meshing_in.Nx-1/(2*ratio));
                
                self.x = interp2(Y, X, meshing_in.x, YI, XI,'*spline');
                self.y = interp2(Y, X, meshing_in.y, YI, XI,'*spline');
                
                self.average_pitch = meshing_in.average_pitch/ratio;
            end
            
            
        end
        
        function self = load(self)
            %Loads meshing
            disp('- Loading meshing');
            file = OpenFile(self.file_path);
            
            Dim = fread(file,1,'integer*4');
            
            self.Nx = fread(file,1,'integer*4');
            disp(strcat('Nx= ',num2str(self.Nx)));
            
            self.Ny = fread(file,1,'integer*4');
            disp(strcat('Ny= ',num2str(self.Ny)));
            
            self.x      = zeros(self.Nx,self.Ny);
            self.y      = zeros(self.Nx,self.Ny);
            
            for i=1:self.Nx
                for j=1:self.Ny
                    self.x(i,j) = fread(file,1,'real*8');
                    self.y(i,j) = fread(file,1,'real*8');
                end
            end
            
            fclose(file);
            
            self.average_pitch = ((self.x(self.Nx,self.Ny)-self.x(1,1))/(self.Nx-1)+(self.y(self.Nx,self.Ny)-self.y(1,1))/(self.Ny-1))/2;
        end
        
        
        function [density_map] = compute_density(self, pedestrian_positions, gaussian_deviation, n_time, varargin)
            %Computes on meshing density of a quantity based on pedestrian_positions,
            %at time index n_time, using deviation gaussian_deviation.
            %Default quantity considered for density is dirac function.
            global DIM;
            
            [Npedestrians, Dim] = size(pedestrian_positions{n_time});
            
            numvarargs = length(varargin);
            if numvarargs > 0
                density_quantity = varargin{1};
            else
                density_quantity = ones(Npedestrians,1);
            end
            
            
            
            Pi = 3.14159;
            A = 1/(2*Pi*gaussian_deviation^2);
            B = -0.5/(gaussian_deviation^2);
            
            if iscell(density_quantity)
                %continuum quantity is temporal
                dims = size(density_quantity{n_time});
                if dims(2)==1
                    %is scalar
                    density_map = zeros(self.Nx,self.Ny);
                    for p=1:Npedestrians
                        density_map(:,:) = density_map(:,:)+density_quantity{n_time}(p)*A.*exp(B*((self.x(:,:)-pedestrian_positions{n_time}(p,1)).^2+(self.y(:,:)-pedestrian_positions{n_time}(p,2)).^2));
                    end
                elseif dims(2)==DIM
                    %is dimensional
                    density_map = zeros(self.Nx,self.Ny,DIM);
                    for d=1:DIM
                        for p=1:Npedestrians
                            density_map(:,:,d) = density_map(:,:,d)+density_quantity{n_time}(p,d)*A.*exp(B*((self.x(:,:)-pedestrian_positions{n_time}(p,1)).^2+(self.y(:,:)-pedestrian_positions{n_time}(p,2)).^2));
                        end
                    end
                end
                
            else
                %continuum quantity is constant
                dims = size(density_quantity);
                if dims(2)==1
                    %is scalar
                    density_map = zeros(self.Nx,self.Ny);
                    for p=1:Npedestrians
                        density_map(:,:) = density_map(:,:)+density_quantity(p)*A.*exp(B*((self.x(:,:)-pedestrian_positions{n_time}(p,1)).^2+(self.y(:,:)-pedestrian_positions{n_time}(p,2)).^2));
                    end
                elseif dims(2)==DIM
                    %is dimensional
                    density_map = zeros(self.Nx,self.Ny,DIM);
                    for d=1:DIM
                        for p=1:Npedestrians
                            density_map(:,:) = density_map(:,:)+density_quantity(p,d)*A.*exp(B*((self.x(:,:)-pedestrian_positions{n_time}(p,1)).^2+(self.y(:,:)-pedestrian_positions{n_time}(p,2)).^2));
                        end
                    end
                    
                end
            end
            
        end
        
        function [continuum_map] = compute_continuum(self, pedestrian_positions, gaussian_deviation, n_time, continuum_quantity)
            %Computes on meshing continuum of a quantity based on pedestrian_positions,
            %at time index n_time, using deviation gaussian_deviation.
            %Default quantity considered for continuum is dirac function.
            %The gaussian deviation is onyl used here for a first
            %evaluation of density, which is then used to evaluate a local
            %deviation.
            global DIM;
            
            [Npedestrians, Dim] = size(pedestrian_positions{n_time});
            
            
            %evaluation of the local deviation
            density_map_default = self.compute_density(pedestrian_positions,gaussian_deviation,n_time);
            density_map_default = density_map_default+0.00000000001;
            gaussian_deviation_map = 1./density_map_default;
            
            %computes density based on local deviation
            density_map = zeros(self.Nx,self.Ny);
            Pi = 3.14159;
            for p=1:Npedestrians
                density_map(:,:) = density_map(:,:)+(0.5./(Pi.*gaussian_deviation_map(:,:))).*exp((-0.5./gaussian_deviation_map(:,:)).*((self.x(:,:)-pedestrian_positions{n_time}(p,1)).^2+(self.y(:,:)-pedestrian_positions{n_time}(p,2)).^2));
            end
            
            %computes quantity's density based on local deviation and
            %division by density
            if iscell(continuum_quantity)
                %continuum quantity is temporal
                dims = size(continuum_quantity{n_time});
                if dims(2)==1
                    %is scalar
                    continuum_map = zeros(self.Nx,self.Ny);
                    for p=1:Npedestrians
                        continuum_map(:,:) = continuum_map(:,:)+continuum_quantity{n_time}(p)*(0.5./(Pi.*gaussian_deviation_map(:,:))).*exp((-0.5./gaussian_deviation_map(:,:)).*((self.x(:,:)-pedestrian_positions{n_time}(p,1)).^2+(self.y(:,:)-pedestrian_positions{n_time}(p,2)).^2));
                    end
                    continuum_map = continuum_map./density_map;
                elseif dims(2)==DIM
                    %is dimensional
                    continuum_map = zeros(self.Nx,self.Ny,DIM);
                    for d=1:DIM
                        for p=1:Npedestrians
                            continuum_map(:,:,d) = continuum_map(:,:,d)+continuum_quantity{n_time}(p,d)*(0.5./(Pi.*gaussian_deviation_map(:,:))).*exp((-0.5./gaussian_deviation_map(:,:)).*((self.x(:,:)-pedestrian_positions{n_time}(p,1)).^2+(self.y(:,:)-pedestrian_positions{n_time}(p,2)).^2));
                        end
                        continuum_map(:,:,d) = continuum_map(:,:,d)./density_map(:,:);
                    end
                end
                
            else
                %continuum quantity is constant
                dims = size(continuum_quantity);
                if dims(2)==1
                    %is scalar
                    continuum_map = zeros(self.Nx,self.Ny);
                    for p=1:Npedestrians
                        continuum_map(:,:) = continuum_map(:,:)+continuum_quantity(p)*(0.5./(Pi.*gaussian_deviation_map(:,:))).*exp((-0.5./gaussian_deviation_map(:,:)).*((self.x(:,:)-pedestrian_positions{n_time}(p,1)).^2+(self.y(:,:)-pedestrian_positions{n_time}(p,2)).^2));
                    end
                    continuum_map = continuum_map./density_map;
                elseif dims(2)==DIM
                    %is dimensional
                    continuum_map = zeros(self.Nx,self.Ny,DIM);
                    for d=1:DIM
                        for p=1:Npedestrians
                            continuum_map(:,:,d) = continuum_map(:,:,d)+continuum_quantity(p,d)*(0.5./(Pi.*gaussian_deviation_map(:,:))).*exp((-0.5./gaussian_deviation_map(:,:)).*((self.x(:,:)-pedestrian_positions{n_time}(p,1)).^2+(self.y(:,:)-pedestrian_positions{n_time}(p,2)).^2));
                        end
                        continuum_map(:,:,d) = continuum_map(:,:,d)./density_map(:,:);
                    end
                    
                end
            end
            
        end
        
        
        function [x_display, y_display] = get_display_positions(self)
            %Gives adapted meshing for pcolor display
            
            x_display = self.x;
            y_display = self.y;
            
            x_display(self.Nx+1,:) = x_display(self.Nx,:)+self.average_pitch;
            x_display(:,self.Ny+1) = x_display(:,self.Ny)+0;
            
            y_display(self.Nx+1,:) = y_display(self.Nx,:)+0;
            y_display(:,self.Ny+1) = y_display(:,self.Ny)+self.average_pitch;
            
            x_display(:,:) = x_display(:,:) - self.average_pitch/2;
            y_display(:,:) = y_display(:,:) - self.average_pitch/2;
        end
        
    end
    
    
end

