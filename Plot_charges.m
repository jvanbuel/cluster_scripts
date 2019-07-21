
%% Read in output file

% Select DFT output file
[Input,Pathname] = uigetfile('*.out','Select the DFT file');
if isequal(Input,0)
   disp('User selected Cancel')
   return
else
   disp(['Loading DFT output of file ', fullfile(Input)])
end

fid = fopen(fullfile(Input), 'rt');
% read the entire file, if not too big
s = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
%% Read in structure

read_geometry(fullfile(Input));

structure = importdata('structure.dat');
structure_atoms = structure.textdata;
structure_positions = structure.data;

%% Plot atoms

unique_atoms = unique(structure_atoms);
natoms = length(unique_atoms);
colors = distinguishable_colors(natoms);
figure_handles = zeros(1,natoms);

fig1 = figure;
fig1_ax = gca;
hold on
[x,y,z] = sphere(25);
%radius = 0.5;
for i =1: length(structure_atoms)
radius = atomic_radius(structure_atoms{i})*2.5e-3;
    for j = 1:natoms
     switch structure_atoms{i}
        case  unique_atoms(j)
        color = colors(j,:);
       	figure_handles(j) = surf(x*radius+structure_positions(i,1),y*radius+structure_positions(i,2),z*radius+structure_positions(i,3),'EdgeColor',[0 0 0],'FaceColor',color,'FaceLighting','phong' ,'AmbientStrength',0.1,'DiffuseStrength',0.8,'SpecularStrength',0.2);
     end
    end

end

%% Plot bonds

% Compare sum of atomic radii with distance between atoms. If distance is
% smaller, draw bond.

for i = 1:(length(structure_atoms)-1)
    for j = i+1:length(structure_atoms)
        
        r1 = structure_positions(i,:);
        r2 = structure_positions(j,:);
        distance = norm(r2-r1);

        sum_atomic_radii = (atomic_radius(structure_atoms{i}) + atomic_radius(structure_atoms{j}))/100;
        if distance <= sum_atomic_radii
            x = [r1(1) r2(1)];
            y = [r1(2) r2(2)];
            z = [r1(3) r2(3)];
            hold on
            g = plot3(x,y,z,'LineWidth',3,'Color',[0.5 0.5 0.5]);
        end
    end
end

axis equal
axis off

legend(figure_handles,unique_atoms);

savefig('Structure.fig')
% Plot by bond orders read from input file (TO DO)

%% Read in Mulliken atomic charges
index_mull = find(strncmp(s{1}, 'MULLIKEN ATOMIC CHARGES',22), 1, 'last')+1;
f = fopen('mulliken_charges.dat','wt+');
while(strcmp(s{1,1}{index_mull,1},'') == 0)
    index_mull = index_mull+1;
    line = sprintf('%s\n',s{1,1}{index_mull,1});
   
   expression = '^\s*\d*\s*(\w*)\s?:\s*(-?\w.\w*)';
   [tokens,match] =regexp(line,expression,'tokens','match');
   str = [tokens{:}];
   
   if isempty(str) ~=1
    formatspec='%s %s \n';
    fprintf(f,formatspec,str{1,1},str{1,2});
   end
    
end
fclose(f);

mulliken = importdata('mulliken_charges.dat');
mulliken_atoms = mulliken.textdata;
mulliken_charges = mulliken.data;

%% Read in Loewdin atomic charges
index_loew = find(strncmp(s{1}, 'LOEWDIN ATOMIC CHARGES',22), 1, 'last')+1;
f = fopen('loewdin_charges.dat','wt+');
while(strcmp(s{1,1}{index_loew,1},'') == 0)
    index_loew = index_loew+1;
    line = sprintf('%s\n',s{1,1}{index_loew,1});
   
   expression = '^\s*\d*\s*(\w*)\s?:\s*(-?\w.\w*)';
   [tokens,match] =regexp(line,expression,'tokens','match');
   str = [tokens{:}];
   if isempty(str) ~=1
    formatspec='%s %s \n';
    fprintf(f,formatspec,str{1,1},str{1,2});
   end
    
end
fclose(f);

loewdin = importdata('loewdin_charges.dat');
loewding_atoms = loewdin.textdata;
loewdin_charges = loewdin.data;

%% Read in Bader charges

bader_charges = read_bader('Bader_charges.dat',structure_atoms);

%% Plot charges

fig2 = figure ;
fig2_ax = gca;

charges = bader_charges;
cmp = colormap('jet');
m = length(cmp);

if exist('cmin','var')
    if cmin > min(charges)
        cmin = min(charges);
    end
    if cmax < max(charges)
        cmax = max(charges);
    end
else
    cmin = min(charges);
    cmax = max(charges);
end

for i =1: length(structure_atoms)
   [x,y,z] = sphere(200);
   %radius = 0.3;
   radius = atomic_radius(structure_atoms{i})*2.5e-3;
   % Determine index in colormap
   index = fix((charges(i)-cmin)/(cmax-cmin)*m)+1;
   % Clamp values outside the range [1 m]
   index(index<1) = 1;
   index(index>m) = m;
   color = cmp(index,:);
   hold on

   surf(x*radius+structure_positions(i,1),y*radius+structure_positions(i,2),z*radius+structure_positions(i,3),'EdgeColor','none','FaceColor',color,'FaceLighting','gouraud' ,'AmbientStrength',0.1,'DiffuseStrength',0.8,'SpecularStrength',0.2);
    set(gcf, 'Renderer', 'OpenGL');
    material shiny, lighting gouraud, lightangle(0, 30);
end

for i = 1:(length(structure_atoms)-1)
    for j = i+1:length(structure_atoms)
        
        r1 = structure_positions(i,:);
        r2 = structure_positions(j,:);
        distance = norm(r2-r1);

        sum_atomic_radii = (atomic_radius(structure_atoms{i}) + atomic_radius(structure_atoms{j}))/100;
        if distance <= sum_atomic_radii*1.1
            x = [r1(1) r2(1)];
            y = [r1(2) r2(2)];
            z = [r1(3) r2(3)];
            hold on
            g = plot3(x,y,z,'LineWidth',5,'Color',[0.5 0.5 0.5]);
        end
    end
end

colorbar
caxis([cmin cmax])
axis equal
axis off
linkdata on

savefig('Charges.fig')


Link = linkprop([fig1_ax, fig2_ax],{'CameraUpVector','CameraViewAngle', 'CameraPosition', 'CameraTarget'});
setappdata(gcf, 'StoreTheLink', Link);
