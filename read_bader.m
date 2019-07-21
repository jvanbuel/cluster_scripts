function [bader_c] = read_bader(filename,structure_atoms)
% Reads and returns geometry from an ORCA output file

dat = importdata(filename);
charge_dat = dat.data;
bader_c = charge_dat(:,5);
%disp(bader_c)

for i = 1:length(bader_c)
    bader_c(i) = atomic_number(structure_atoms{i})- bader_c(i);
end

end