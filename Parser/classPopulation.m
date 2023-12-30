classdef classPopulation < handle
    %classPopulation Class containing and managing crowd data
    %classPopulation Properties:
    %   file_temporal_path  - path of temporal data of population
    %   file_constant_path  - path of constant data of population
    %   Ntimes              - Number of data's timesteps
    %   Npedestrians        - Number of population's pedestrians
    %   masses              - pedestrians mass (constant, [Npedestrians, 1], kg)
    %   radiuses            - pedestrians radius (constant, [Npedestrians, 1], kg)
    %   wills               - pedestrians will to go their goal (constant, [Npedestrians, 1], N)
    %   fatigues            - pedestrians slow down coefficient (constant, [Npedestrians, 1], N.m^-1.s)
    %   times               - data times
    %   positions           - pedestrians position ({Ntimes}, [Npedestrians, 2], m)
    %   velocities          - pedestrians velocity ({Ntimes}, [Npedestrians, 2], m.s^-1)
    %   wishes              - pedestrians wish ({Ntimes}, [Npedestrians, 2], 1)
    %classPopulation constructors:
    %   classPopulation(files_population_path) - Constructor of classPopulation loading files at files_popuation_path
    %   classPopulation(population1, population2, population3, ...) - Constructor of classPopulation by concatenation of populations
    %classPopulation user-friendly methods:
    %   get_Ntimes()        - returns number of data's timesteps
    %   get_Npedestrians()  - returns number of population's pedestrians
    %   get_quantity(str_quantity_name) - returns the quantity named 'str_quantity_name'
    %   pop_display(str_display_type, str_quantity, environment, n_time)    - displays str_quantity as str_display_type (plot, density, etc..) at timestep n_time
    %   pop_display(str_display_type, str_quantity, environment, Ntimes, frames_modulo) - movie of str_quantity for Ntimes duration with frames_modulo frame skip
    %   pop_display(str_display_type, str_quantity, environment, Ntimes, frames_modulo, export_name) - same as previous + frames recording at path export_name
    %classPopulation advanced methods (used by pop_display()):
    %   plot(environment, n_time, str_color)    -   plots pedestrians at n_time
    %   plot(environment, n_time, str_color, quantity)    -   plots pedestrians' quantity at n_time (if quantity == positions, same as previous function)
    %   plot(environment, n_time, str_color, quantity, index_size)    - plots pedestrians' quantity at n_time with pedestrian index of size index_size
    %   movie_plot(environment) - movie of positions plot, frames recording in 'movie_plot.*'
    %   movie_plot(environment, quantity) - movie of quantity plot
    %   movie_plot(environment, quantity, Ntimes) - same as previous + Ntimes timesteps duration
    %   movie_plot(environment, quantity, Ntimes, frames_modulo) - same as previous + frames_modulo frames skip
    %   movie_plot(environment, quantity, Ntimes, frames_modulo, movie_name) - same as previous + frames recording at movie_name
    %   display_density(environment, n_time) - displays pedestrians density at n_time
    %   display_density(environment, n_time, quantity) - displays pedestrians quantity density at n_time
    %   movie_density(environment) - movie of pedestrians density, frames recording in 'movie_density.*'
    %   movie_density(environment, quantity) - movie of pedestrians' quantity density
    %   movie_density(environment, quantity, Ntimes) - same as previous + Ntimes timesteps duration
    %   movie_density(environment, quantity, Ntimes, frames_modulo) - same as previous + frames_modulo frames skip
    %   movie_density(environment, quantity, Ntimes, frames_modulo, movie_name) - same as previous + frames recording at movie_name
    %   display_continuum(envrionment, n_time) - displays pedestrians continuum at n_time (= 1 everywhere)
    %   display_continuum(environment, n_time, quantity) - displays pedestrians quantity continuum at n_time
    %   movie_continuum(environment) - movie of pedestrians continuum, frames recording in 'movie_continuum.*'
    %   movie_continuum(environment, quantity) - movie of pedestrians' quantity continuum
    %   movie_continuum(environment, quantity, Ntimes) - same as previous + Ntimes timesteps duration
    %   movie_continuum(environment, quantity, Ntimes, frames_modulo) - same as previous + frames_modulo frames skip
    %   movie_continuum(environment, quantity, Ntimes, frames_modulo, movie_name) - same as previous + frames recording at movie_name
    
    
    properties
        
        file_temporal_path;
        file_constant_path;
        
        Ntimes;
        Npedestrians;
        
        masses;
        radiuses;
        wills;
        fatigues;
        
        times;
        positions;
        velocities;
        wishes;
        
    end
    
    methods
        
        function self = classPopulation(varargin)
            
            numvarargs = length(varargin);
            if numvarargs == 1
                %Constructs classPopulation using a file path
                files_population_path = varargin{1};
                disp('- Loading classPopulation');
                mex load_population.c
                [self.Ntimes, self.Npedestrians,...
                    self.masses, self.radiuses, self.wills, self.fatigues,...
                    self.times, self.positions, self.velocities, self.wishes] = load_population(files_population_path);
                
                disp(strcat('Ntimes : ',num2str(self.Ntimes)));
                disp(strcat('Npedestrians : ',num2str(self.Npedestrians)));
            else
                %Constructs classPopulation by adding other
                %classPopulations
                disp('- classPopulation construction with other populations')
                Npopulations = numvarargs;
                for pop=1:Npopulations
                    populations(pop) = varargin{pop};
                end
                
                self.Ntimes = 9999999999;
                for pop=1:Npopulations
                    if populations(pop).Ntimes < self.Ntimes
                        self.Ntimes = populations(pop).Ntimes;
                        pop_min = pop;
                    end
                end
                disp(strcat('minimum common Ntimes : ',num2str(self.Ntimes)));
                self.times = populations(pop_min).times;
                
                self.positions = cell(self.Ntimes,1);
                self.velocities = cell(self.Ntimes,1);
                self.wishes = cell(self.Ntimes,1);
                
                self.Npedestrians = 0;
                for pop=1:Npopulations
                    self.Npedestrians = self.Npedestrians + populations(pop).Npedestrians;
                    self.masses = vertcat(self.masses, populations(pop).masses);
                    self.radiuses = vertcat(self.radiuses, populations(pop).radiuses);
                    self.wills = vertcat(self.wills, populations(pop).wills);
                    self.fatigues = vertcat(self.fatigues, populations(pop).fatigues);
                    
                    for nt=1:self.Ntimes
                        self.positions{nt} = vertcat(self.positions{nt},populations(pop).positions{nt});
                        self.velocities{nt} = vertcat(self.velocities{nt},populations(pop).velocities{nt});
                        self.wishes{nt} = vertcat(self.wishes{nt},populations(pop).wishes{nt});
                    end
                      
                end 

            end %ends if numvarargs == 1
        end %ends constructor
        
        function Ntimes = get_Ntimes(self)
           Ntimes = self.Ntimes; 
        end
        
        function Npedestrians = get_Npedestrians(self)
           Npedestrians = self.Npedestrians; 
        end
        
        function quantity = get_quantity(self, str_quantity)
            
            if strcmp(str_quantity,'positions')
                quantity = ones(self.Npedestrians, 1);
            elseif strcmp(str_quantity,'velocities')
                quantity = self.velocities;
            elseif strcmp(str_quantity,'wishes')
                quantity = self.wishes;
            elseif strcmp(str_quantity,'masses')
                quantity = self.masses;
            elseif strcmp(str_quantity,'radiuses')
                quantity = self.radiuses;
            elseif strcmp(str_quantity,'wills')
                quantity = self.wills;
            elseif strcmp(str_quantity,'fatigues')
                quantity = self.fatigues;
            else
               disp(strcat('There is no such pedestrian quantity as : ', str_quantity));
               disp('Available quantities are : positions, velocities, wishes, masses, radiuses, wills, fatigues');
            end
            
        end
        
        
        
        
        
        function output = pop_display(self, str_display_type, str_quantity, environment, varargin)
            global index_size_user;
            
            numvarargs = length(varargin);
            
            a = strfind(str_display_type, 'movie');
            l_movie = ~isempty(a);
            if ~l_movie & numvarargs > 0
                n_time = varargin{1};
                a = strfind(str_display_type, 'plot');
                l_plot = ~isempty(a);
                if l_plot
                    if numvarargs > 1
                        str_color = varargin{2};
                    else
                        str_color = 'b';
                    end
                end
            elseif l_movie & numvarargs > 1
                Ntimes = varargin{1};
                frames_modulo = varargin{2};
                if numvarargs > 2
                    export_name = varargin{3}
                else
                    export_name = strcat(str_display_type,'-',str_quantity);
                end
            end
            
            
            if numvarargs == 1
                n_time = varargin{1};
            else
                if numvarargs > 1
                    Ntimes = varargin{1};
                    frames_modulo = varargin{2};
                    if numvarargs > 2
                        export_name = varargin{3}
                    else
                        export_name = strcat(str_display_type,'-',str_quantity);
                    end
                end
            end
            
            quantity = self.get_quantity(str_quantity);
            
            if strcmp(str_display_type,'plot')
                output = self.plot(environment, n_time, str_color, quantity);
            elseif strcmp(str_display_type,'plot-idx')
                output = self.plot(environment, n_time, str_color, quantity, index_size_user);
            elseif strcmp(str_display_type,'density')
                output = self.display_density(environment, n_time, quantity);
            elseif strcmp(str_display_type,'continuum')
                output = self.display_continuum(environment, n_time, quantity);
            elseif strcmp(str_display_type,'movie-plot')
                output = self.movie_plot(environment, quantity, Ntimes, frames_modulo, export_name);
            elseif strcmp(str_display_type,'movie-plot-idx')
                output = self.movie_plot(environment, quantity, Ntimes, frames_modulo, export_name, index_size_user);
            elseif strcmp(str_display_type,'movie-density')
                output = self.movie_density(environment, quantity, Ntimes, frames_modulo, export_name);
            elseif strcmp(str_display_type,'movie-continuum')
                output = self.movie_continuum(environment, quantity, Ntimes, frames_modulo, export_name);
            else
                disp(strcat('There is no such display type as : ', str_display_type));
                disp('Available displays are : plot, plot-idx, density, continuum, movie-plot, movie-plot-idx, movie-density, movie-continuum');
            end
            
            
            
        end
        
        
        
        function fig = plot(self, environment, n_time, str_color, varargin)
            global DIM;
            global plot_scale;
            global quiver_scale;
            
            numvarargs = length(varargin);
            if numvarargs > 0
                plot_quantity = varargin{1};
            else
                plot_quantity = ones(self.Npedestrians, 1);
            end
            if numvarargs > 1
                l_plot_index = 1;
                index_size = varargin{2};
            else
                l_plot_index = 0;    
            end
            
            hold on
            environment.display_map();
            
            if iscell(plot_quantity)
                dims = size(plot_quantity{n_time});
                if dims(2) == 1
                    mean_quantity = mean(plot_quantity{n_time});
                    for p=1:self.Npedestrians
                        plot(self.positions{n_time}(p,1), self.positions{n_time}(p,2),'o','MarkerEdgeColor','k','MarkerFaceColor',str_color,'MarkerSize',(plot_scale/mean_quantity)*plot_quantity{n_time}(p)+10^-10);
                    end
                elseif dims(2) == DIM
                    plot_quantity_norm = zeros(self.Npedestrians, 1);
                    plot_quantity_norm(:) = (plot_quantity{n_time}(:,1).^2+plot_quantity{n_time}(:,2).^2).^0.5;
                    mean_quantity = mean(plot_quantity_norm);
                    index = plot_quantity_norm(:) ~= 0;
                    plot_quantity{n_time}(index,1) = plot_quantity{n_time}(index,1)./plot_quantity_norm(index);
                    plot_quantity{n_time}(index,2) = plot_quantity{n_time}(index,2)./plot_quantity_norm(index);
                    for p=1:self.Npedestrians
                        plot(self.positions{n_time}(p,1), self.positions{n_time}(p,2),'o','MarkerEdgeColor','k','MarkerFaceColor',str_color,'MarkerSize',(plot_scale/mean_quantity)*plot_quantity_norm(p)+10^-10);
                        quiver(self.positions{n_time}(p,1), self.positions{n_time}(p,2), plot_quantity{n_time}(p,1), plot_quantity{n_time}(p,2),quiver_scale,'r','LineWidth',2*quiver_scale);
                    end
                end
                
            else
                dims = size(plot_quantity);
                if dims(2) == 1
                    mean_quantity = mean(plot_quantity);
                    for p=1:self.Npedestrians
                        plot(self.positions{n_time}(p,1), self.positions{n_time}(p,2),'o','MarkerEdgeColor','k','MarkerFaceColor',str_color,'MarkerSize',(plot_scale/mean_quantity)*plot_quantity(p)+10^-10);
                    end
                    
                elseif dims(2) == DIM
                    plot_quantity_norm = zeros(self.Npedestrians, 1);
                    plot_quantity_norm(:) = (plot_quantity(:,1).^2+plot_quantity(:,2).^2).^0.5;
                    mean_quantity = mean(plot_quantity_norm);
                    index = plot_quantity_norm(:) ~= 0;
                    plot_quantity(index,1) = plot_quantity(index,1)./plot_quantity_norm(index);
                    plot_quantity(index,2) = plot_quantity(index,2)./plot_quantity_norm(index);
                    for p=1:self.Npedestrians
                        plot(self.positions{n_time}(p,1), self.positions{n_time}(p,2),'o','MarkerEdgeColor','k','MarkerFaceColor',str_color,'MarkerSize',(plot_scale/mean_quantity)*plot_quantity_norm(p)+10^-10);
                        quiver(self.positions{n_time}(p,1), self.positions{n_time}(p,2), plot_quantity(p,1), plot_quantity(p,2),2,'r','LineWidth',quiver_scale,'r','LineWidth',2*quiver_scale);
                    end
                end
                    
              
            end
            
            if l_plot_index
                for p=1:self.Npedestrians
                    if environment.is_inside(self.positions{n_time}(p,:))
                        t= text(double(self.positions{n_time}(p,1)), double(self.positions{n_time}(p,2)),[num2str(p)],'HorizontalAlignment','left','VerticalAlignment','bottom');
                        set(t,'FontSize', index_size);
                    end
                end
            end
            
            hold off
            fig = gcf;
              
        end
        
        function M = movie_plot(self, environment, varargin)
            global DIM;
            global plot_scale;
            global quiver_scale;
            
            str_color = 'b';
            
            numvarargs = length(varargin);
            if numvarargs > 0
                plot_quantity = varargin{1};
            else
                plot_quantity = ones(self.Npedestrians,1);
            end
            if numvarargs > 1
                Ntimes = varargin{2};
                if Ntimes > self.Ntimes
                    Ntimes = self.Ntimes;
                end
            else
                Ntimes = self.Ntimes;
            end
            if numvarargs > 2
                frames_modulo = varargin{3};
            else
                frames_modulo = 1;
            end
            if numvarargs > 3
                movie_name = varargin{4};
            else
                movie_name = 'movie-plot';
            end
            if numvarargs > 4
                l_plot_index = 1;
                index_size = varargin{5};
            else
                l_plot_index = 0;    
            end
            
            
            if iscell(plot_quantity)
                dims = size(plot_quantity{1});
                if dims(2) == 1
                    mean_quantity = mean(mean(plot_quantity));
                elseif dims(2) == DIM
                    for n_time=1:frames_modulo:Ntimes
                        n_time_movie = (n_time-1)/frames_modulo+1;
                        plot_quantity_norm(:,n_time_movie) = zeros(self.Npedestrians, 1);
                        plot_quantity_norm(:,n_time_movie) = (plot_quantity{n_time}(:,1).^2+plot_quantity{n_time}(:,2).^2).^0.5;  
                        index = plot_quantity_norm(:,n_time_movie) ~= 0;
                        plot_quantity{n_time}(index,1) = plot_quantity{n_time}(index,1)./plot_quantity_norm(index,n_time_movie);
                        plot_quantity{n_time}(index,2) = plot_quantity{n_time}(index,2)./plot_quantity_norm(index,n_time_movie);
                    end
                    mean_quantity = mean(mean(plot_quantity_norm));
                end
            else
                dims = size(plot_quantity);
                if dims(2) == 1
                    mean_quantity = mean(plot_quantity);
                elseif dims(2) == DIM   
                    plot_quantity_norm(:) = zeros(self.Npedestrians, 1);
                    plot_quantity_norm(:) = (plot_quantity(:,1).^2+plot_quantity(:,2).^2).^0.5;  
                    index = plot_quantity_norm(:) ~= 0;
                    plot_quantity(index,1) = plot_quantity(index,1)./plot_quantity_norm(index);
                    plot_quantity(index,2) = plot_quantity(index,2)./plot_quantity_norm(index);
                    mean_quantity = mean(plot_quantity_norm);
                end
            end
            
            fig = figure;
            for n_time=1:frames_modulo:Ntimes
                n_time_movie = (n_time-1)/frames_modulo+1;
                disp(strcat(num2str(n_time_movie),'/',num2str(round((Ntimes-1)/frames_modulo+1)),'  n_time:',num2str(n_time)));
                
                hold on
                environment.display_map();
                
                if iscell(plot_quantity)
                    dims = size(plot_quantity{n_time});
                    if dims(2) == 1
                        for p=1:self.Npedestrians
                            plot(self.positions{n_time}(p,1), self.positions{n_time}(p,2),'o','MarkerEdgeColor','k','MarkerFaceColor',str_color,'MarkerSize',(plot_scale/mean_quantity)*plot_quantity{n_time}(p)+10^-10);
                        end
                    elseif dims(2) == DIM
                        for p=1:self.Npedestrians
                            plot(self.positions{n_time}(p,1), self.positions{n_time}(p,2),'o','MarkerEdgeColor','k','MarkerFaceColor',str_color,'MarkerSize',(plot_scale/mean_quantity)*plot_quantity_norm(p,n_time_movie)+10^-10);
                            quiver(self.positions{n_time}(p,1), self.positions{n_time}(p,2), plot_quantity{n_time}(p,1), plot_quantity{n_time}(p,2),quiver_scale,'r','LineWidth',2*quiver_scale);
                        end
                    end
                    
                else
                    dims = size(plot_quantity);
                    if dims(2) == 1
                        mean_quantity = mean(plot_quantity);
                        for p=1:self.Npedestrians
                            plot(self.positions{n_time}(p,1), self.positions{n_time}(p,2),'o','MarkerEdgeColor','k','MarkerFaceColor',str_color,'MarkerSize',(plot_scale/mean_quantity)*plot_quantity(p)+10^-10);
                        end
                    elseif dims(2) == DIM
                        for p=1:self.Npedestrians
                            plot(self.positions{n_time}(p,1), self.positions{n_time}(p,2),'o','MarkerEdgeColor','k','MarkerFaceColor',str_color,'MarkerSize',(plot_scale/mean_quantity)*plot_quantity_norm(p)+10^-10);
                            quiver(self.positions{n_time}(p,1), self.positions{n_time}(p,2), plot_quantity(p,1), plot_quantity(p,2),quiver_scale,'r','LineWidth',2*quiver_scale);
                        end
                    end
                    
                    
                end

                if l_plot_index
                    for p=1:self.Npedestrians
                        if environment.is_inside(self.positions{n_time}(p,:))
                            t= text(double(self.positions{n_time}(p,1)), double(self.positions{n_time}(p,2)),[num2str(p)],'HorizontalAlignment','left','VerticalAlignment','bottom');
                            set(t,'FontSize', index_size);
                        end
                    end
                end
                
                hold off
                
                export_fig(strcat(movie_name,'.',my_int2str(n_time_movie),'.png'));
                
                M(n_time_movie) = getframe(fig);
                clf;
                
            end

              
        end
        
        
        function fig = display_density(self, environment, n_time, varargin)
            global DIM;
            
            
            
            numvarargs = length(varargin);
            if numvarargs == 1
                density_quantity = varargin{1};
            else
                density_quantity = ones(self.Npedestrians,1);
            end
            
            disp('Computing density');
            density = environment.meshing.compute_density(self.positions, environment.meshing.average_pitch, n_time, density_quantity);
            
            
            dims = size(density);
            dim = size(dims);
            if dim(2)==3 & dims(3)==DIM
                density_norm(:,:) = density(:,:,1);
                density_norm(:,:) = 0;
                for d=1:DIM
                    density_norm(:,:) = density_norm(:,:)+density(:,:,d).^2;
                end
                density_norm(:,:) = density_norm(:,:).^0.5;
                
                l_normalize_field = 1;
                if l_normalize_field
                    for d=1:DIM
                        density(:,:,d) = density(:,:,d)./(density_norm(:,:)+0.00000000000001);
                    end
                end
                
                disp('Displaying density');
                hold on
                environment.display_data_map(density_norm(:,:));
                environment.display_data_field(density);
                hold off
            else
                environment.display_data_map(density);
            end
            fig = gcf;
            
        end
        
        
        function M = movie_density(self, environment, varargin)
            global DIM;
            
            numvarargs = length(varargin);
            if numvarargs > 0
                density_quantity = varargin{1};
            else
                density_quantity = ones(self.Npedestrians,1);
            end
            if numvarargs > 1
                Ntimes = varargin{2};
                if Ntimes > self.Ntimes
                    Ntimes = self.Ntimes;
                end
            else
                Ntimes = self.Ntimes;
            end
            if numvarargs > 2
                frames_modulo = varargin{3};
            else
                frames_modulo = 1;
            end
            if numvarargs > 3
                movie_name = varargin{4};
            else
                movie_name = 'movie-density';
            end
            
            
            
            disp('Computing densities');
            for n_time=1:frames_modulo:Ntimes
                n_time_movie = (n_time-1)/frames_modulo+1;
                disp(strcat(num2str(n_time_movie),'/',num2str(round((Ntimes-1)/frames_modulo+1)),'  n_time:',num2str(n_time)));
                density_tmp = environment.meshing.compute_density(self.positions, environment.meshing.average_pitch, n_time, density_quantity);
                dims = size(density_tmp);
                dim = size(dims);
                if dim(2)==2
                    density(:,:,n_time_movie) = density_tmp;
                elseif dim(2)==3
                    density(:,:,:,n_time_movie) = density_tmp;
                    
                    density_norm(:,:,n_time_movie) = zeros(environment.meshing.Nx,environment.meshing.Ny);
                    for d=1:DIM
                        density_tmp2(:,:) = density(:,:,d,n_time_movie);
                        density_norm(:,:,n_time_movie) = density_norm(:,:,n_time_movie)+density_tmp2(:,:).^2;
                    end
                    density_norm(:,:,n_time_movie) = density_norm(:,:,n_time_movie).^0.5;    
                end
            end
            
            dims = size(density);
            dim = size(dims);
            if dim(2)==3
                density_max = max(max(max(density)));
                density_min = min(min(min(density)));
            elseif dim(2)==4
                density_max = max(max(max(density_norm)));
                density_min = min(min(min(density_norm)));
            end
            
            disp('Displaying densities');
            fig = figure;
            for n_time=1:frames_modulo:Ntimes
                n_time_movie = (n_time-1)/frames_modulo+1;
                disp(strcat(num2str(n_time_movie),'/',num2str(round((Ntimes-1)/frames_modulo+1)),'  n_time:',num2str(n_time)));
                
                hold on
                if dim(2)==3
                    environment.display_data_map(density(:,:,n_time_movie));
                elseif dim(2)==4
                    environment.display_data_map(density_norm(:,:,n_time_movie));
                    environment.display_data_field(density(:,:,:,n_time_movie));
                end
                caxis([density_min density_max]);
                hold off
                
                export_fig(strcat(movie_name,'.',my_int2str(n_time_movie),'.png'));
                
                M(n_time_movie) = getframe(fig);
                clf;
            end
                        
        end
        
        function fig = display_continuum(self, environment, n_time, varargin)
            global DIM;
            
            numvarargs = length(varargin);
            if numvarargs == 1
                continuum_quantity = varargin{1};
            else
                continuum_quantity = ones(self.Npedestrians,1);
            end
            
            disp('Computing continuum');
            continuum = environment.meshing.compute_continuum(self.positions, environment.meshing.average_pitch, n_time, continuum_quantity);
            dims = size(continuum);
            dim = size(dims);
            if dim(2)==3 & dims(3)==DIM
                continuum_norm(:,:) = continuum(:,:,1);
                continuum_norm(:,:) = 0;
                for d=1:DIM
                    continuum_norm(:,:) = continuum_norm(:,:)+continuum(:,:,d).^2;
                end
                continuum_norm(:,:) = continuum_norm(:,:).^0.5;
                
                l_normalize_field = 1;
                if l_normalize_field
                    for d=1:DIM
                        continuum(:,:,d) = continuum(:,:,d)./(continuum_norm(:,:)+10^-10);
                    end
                    %remove unrelevant low values for field
                    mean_value = mean(mean(continuum_norm));
                    low_value_mask(:,:) = continuum_norm(:,:) >= mean_value*10^-1;
                    for d=1:DIM
                        continuum(:,:,d) = continuum(:,:,d).*low_value_mask(:,:);
                    end
                end
                
                
                
                disp('Displaying continuum');
                hold on
                environment.display_data_map(continuum_norm(:,:));
                environment.display_data_field(continuum);
                hold off
                
                continuum_max = max(max(continuum_norm));
                continuum_min = min(min(continuum_norm));  
            else
                disp('Displaying continuum');
                environment.display_data_map(continuum);
                
                continuum_max = max(max(continuum));
                continuum_min = min(min(continuum)); 
            end
            fig = gcf;
            
            caxis([continuum_min continuum_max]);
            
        end
        
        function M = movie_continuum(self, environment, varargin)
            
            global DIM;
            
            numvarargs = length(varargin);
            if numvarargs > 0
                continuum_quantity = varargin{1};
            else
                continuum_quantity = ones(self.Npedestrians,1);
            end
            if numvarargs > 1
                Ntimes = varargin{2};
                if Ntimes > self.Ntimes
                    Ntimes = self.Ntimes;
                end
            else
                Ntimes = self.Ntimes;
            end
            if numvarargs > 2
                frames_modulo = varargin{3};
            else
                frames_modulo = 1;
            end
            if numvarargs > 3
                movie_name = varargin{4};
            else
                movie_name = 'movie-continuum';
            end
            
            
            disp('Computing continuum');
            for n_time=1:frames_modulo:Ntimes
                n_time_movie = (n_time-1)/frames_modulo+1;

                
                disp(strcat(num2str(n_time_movie),'/',num2str(round((Ntimes-1)/frames_modulo+1)),'  n_time:',num2str(n_time)));
                continuum_tmp = environment.meshing.compute_continuum(self.positions, environment.meshing.average_pitch, n_time, continuum_quantity);
                dims = size(continuum_tmp);
                dim = size(dims);
                if dim(2)==2
                    continuum(:,:,n_time_movie) = continuum_tmp;
                elseif dim(2)==3
                    continuum(:,:,:,n_time_movie) = continuum_tmp;
                    
                    continuum_norm(:,:,n_time_movie) = zeros(environment.meshing.Nx,environment.meshing.Ny);
                    for d=1:DIM
                        continuum_tmp2(:,:) = continuum(:,:,d,n_time_movie);
                        continuum_norm(:,:,n_time_movie) = continuum_norm(:,:,n_time_movie)+continuum_tmp2(:,:).^2;
                    end
                    continuum_norm(:,:,n_time_movie) = continuum_norm(:,:,n_time_movie).^0.5;
                    
                    l_normalize_field = 1;
                    if l_normalize_field
                        for d=1:DIM             
                            continuum(:,:,d,n_time_movie) = continuum(:,:,d,n_time_movie)./(continuum_norm(:,:,n_time_movie)+10^-10);
                        end
                        %remove unrelevant low values for field
                        %mean_value = mean(mean(continuum_norm(:,:,n_time_movie)));
                        %low_value_mask(:,:) = continuum_norm(:,:,n_time_movie) >= mean_value*10^-1;
                        %for d=1:DIM
                        %    continuum(:,:,d,n_time_movie) = continuum(:,:,d,n_time_movie).*low_value_mask(:,:);
                        %end
                    end
                end  
            end
            
            dims = size(continuum);
            dim = size(dims);
            if dim(2)==3
                continuum_max = max(max(max(continuum)));
                continuum_min = min(min(min(continuum)));
            elseif dim(2)==4
                continuum_max = max(max(max(continuum_norm)));
                continuum_min = min(min(min(continuum_norm)));
            end

            disp('Displaying continuum');
            fig = figure;
            for n_time=1:frames_modulo:Ntimes
                n_time_movie = (n_time-1)/frames_modulo+1;
                disp(strcat(num2str(n_time_movie),'/',num2str(round((Ntimes-1)/frames_modulo+1)),'  n_time:',num2str(n_time)));
                
                hold on
                if dim(2)==3
                    environment.display_data_map(continuum(:,:,n_time_movie));
                elseif dim(2)==4
                    environment.display_data_map(continuum_norm(:,:,n_time_movie));
                    environment.display_data_field(continuum(:,:,:,n_time_movie));
                end
                caxis([continuum_min continuum_max]);
                hold off
                
                export_fig(strcat(movie_name,'.',my_int2str(n_time_movie),'.png'));
                
                M(n_time_movie) = getframe(fig);
                clf;
            end
                        
        end
        
    end
    
end

