function [ str ] = my_int2str( n )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if(n > 9999)
    str = strcat('0',int2str(n));
elseif(n > 999)
    str = strcat('00',int2str(n));
elseif(n > 99)
    str = strcat('000',int2str(n));
elseif(n > 9)
    str = strcat('0000',int2str(n));
else
    str = strcat('00000',int2str(n));
end


end

