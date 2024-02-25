classdef classEnvironment < handle
    %classEnvironment class containing environment data
    %classPopulation Properties:
    %   str_path    - path of environment file
    %   meshing     - cartesian meshing the environment lies in
    %   map         - boolean map of obstacles ([meshing.Nx, meshing.Ny])
    %classEnvironment Methods:
    %   classEnvironment(meshing, str_path)  - constructor using a corresponding meshing and the file path of the environment
    %   classEnvironment(environment, ratio) - constructor using another environment being refined by a factor ratio
    
    properties
        
        str_path;
        meshing = classMeshing.empty;
        map;
        
    end
    
    methods
        
        function self = classEnvironment(varargin)
            
            numvarargs = length(varargin);
            if numvarargs == 2
                sizes = size(varargin{2});
                if sizes(2)>1
                    %if second argument is supposely a path string
                    self.meshing = varargin{1};
                    self.str_path = varargin{2};
            
                    self.load();
                else
                    %if second argument is a scalar value
                    environment_in = varargin{1};
                    ratio = varargin{2};
                    self.str_path = strcat(environment_in.str_path,'-r',num2str(ratio));
                    self.meshing = classMeshing(environment_in.meshing,ratio);

                    self.map = interp2(environment_in.meshing.y,environment_in.meshing.x,environment_in.map,self.meshing.y,self.meshing.x,'nearest');
    
                end
            else
               disp('classEnvironment takes two input arguments'); 
            end
            
        end
        
        function self = load(self)
            disp('- Loading environment');
            file = OpenFile(strcat(self.str_path, '.env'));
            self.map = ReadMap(file, self.meshing.x);
            
            for i=1:self.meshing.Nx
                for j=1:self.meshing.Ny
                    if self.map(i,j) == 1
                        self.map(i,j) = NaN;
                    elseif self.map(i,j) == -1
                        self.map(i,j) = 1;
                    end
                end
            end
        end
        
        function l_inside = is_inside(self, position)
            
            l_inside = 0;
            if position(1) > self.meshing.x(1,1) & position(1) < self.meshing.x(end,1)
                if position(2) > self.meshing.y(1,1) & position(2) < self.meshing.y(1,end)
                    l_inside = 1;
                end
            end
            
        end
        
        
        function display_map(self)
            %Displays environment map only using pcolor
            %An adapted meshing is used in order to correct pcolor meshes
            %offset

            map_display = self.map;
            x_display = self.meshing.x;
            y_display = self.meshing.y;
            
            [x_display, y_display] = self.meshing.get_display_positions();
            map_display(self.meshing.Nx+1,:) = map_display(self.meshing.Nx,:);
            map_display(:,self.meshing.Ny+1) = map_display(:,self.meshing.Ny);
            
            pcolor(x_display, y_display, map_display);
            shading('flat');
            
            self.configure_display(x_display, y_display);
            
        end
        
        function display_data_map(self, data_map)
            %Displays data_map with the environment mask using pcolor
            %An adapted meshing is used in order to correct pcolor meshes
            %offset
            
            
            map_display = self.map;
            [x_display, y_display] = self.meshing.get_display_positions();
            
            map_display(self.meshing.Nx+1,:) = map_display(self.meshing.Nx,:);
            map_display(:,self.meshing.Ny+1) = map_display(:,self.meshing.Ny);
            
            
            data_map(self.meshing.Nx+1,:) = data_map(self.meshing.Nx,:);
            data_map(:,self.meshing.Ny+1) = data_map(:,self.meshing.Ny);
            
            map_display = map_display.*data_map;

            pcolor(x_display, y_display, map_display);
            shading('flat');
            colormap(jet(256))
            colorbar
            
            self.configure_display(x_display, y_display);
            
        end
        
        function display_data_field(self, data_field)
            %Displays data_field with the environment mask using quiver
            %An adapted meshing is used in order to correct pcolor meshes
            %offset
            
            global DIM;
            global quiver_scale;
            
            dims = size(data_field);
            if dims(3)==DIM
     
                %Environment mask
                for d=1:DIM
                   data_field(:,:,d) = data_field(:,:,d).*self.map(:,:);
                end
                
                skip = 2;
                quiver(self.meshing.x(1:skip:self.meshing.Nx,1:skip:self.meshing.Ny),self.meshing.y(1:skip:self.meshing.Nx,1:skip:self.meshing.Ny),data_field(1:skip:self.meshing.Nx,1:skip:self.meshing.Ny,1),data_field(1:skip:self.meshing.Nx,1:skip:self.meshing.Ny,2),0.2*quiver_scale,'k','LineWidth',1)
                
                [x_display, y_display] = self.meshing.get_display_positions();
                self.configure_display(x_display, y_display);
                
            end
        end
        
        function configure_display(self, x_display, y_display)
            
            global figure_window;
            
            Nx_ticks = 8;
            for i=0:Nx_ticks
                x_ticks(i+1) =  x_display(i*self.meshing.Nx/Nx_ticks+1,1);
            end
            set(gca,'XTick',x_ticks);
            
            Ny_ticks = 8;
            for j=0:Ny_ticks
                y_ticks(j+1) =  y_display(1,j*self.meshing.Ny/Ny_ticks+1);
            end
            set(gca,'YTick',y_ticks);
            
            axis equal
            axis([0 x_display(self.meshing.Nx+1,1) 0 y_display(1,self.meshing.Ny+1)]);
            
            set(gca, 'Color', 'w');
            xlabel('m');
            ylabel('m');
            set(gcf, 'Color', 'w');
            set(gcf, 'Position', figure_window)
            
        end
        
        
    end
    
end

