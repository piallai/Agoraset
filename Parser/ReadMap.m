function [ map , t] = ReadSlvMap( file, varargin )
%ReadSlvMap Reads content of the previously opened file and puts it into a
%2D map


numvarargs = length(varargin);

if numvarargs == 1
    %if environment mask is provided
    environment_mask = varargin{1};
    [Nx,Ny] = size(environment_mask);
elseif numvarargs == 1
    %if meshing dimensions are provided
    Nx = varargin{1};
    Ny = varargin{2};
end

t          = fread(file,1,'real*8');

for i=1:Nx
    for j=1:Ny
        map(i,j) = fread(file,1,'real*8');
        if numvarargs == 1
            if environment_mask(i,j) == 1
                map(i,j) = NaN;
            end
        end
    end
end


end

