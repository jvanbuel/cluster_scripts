function [ ] = read_geometry(filename)
% Reads and returns geometry from an ORCA output file

fid = fopen(fullfile(filename), 'rt');
% read the entire file, if not too big
s = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
%% Read in structure

index_cart = find(strcmp(s{1}, 'CARTESIAN COORDINATES (ANGSTROEM)'), 1, 'last')+1;
f = fopen('structure.dat','wt+');
while(strcmp(s{1,1}{index_cart,1},'') == 0)
    index_cart = index_cart+1;
    line = sprintf('%s\n',s{1,1}{index_cart,1});
   % disp(line)
    formatspec='%s %f %f %f';
    fprintf(f,formatspec,line);
    
end
fclose(f);
end

