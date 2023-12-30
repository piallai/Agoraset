function [ file ] = OpenFile( name , varargin)
%OpenFile Opens a file name with '.data' extension and displays the file
%name

numvarargs = length(varargin);
if numvarargs > 0
    open_file_option = strcat(varargin{1},'b');
else
    open_file_option = 'rb';
end

extension = '.data';
file_name = strcat(name,extension);
disp('Opening file :');
disp(file_name);
file    = fopen(file_name, open_file_option);

end

