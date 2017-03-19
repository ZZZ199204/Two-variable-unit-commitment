function dataUC=readdataUC(pathAndFilename)
fprintf('\n\n\n');
disp('------------------------��ȡ����������������ļ�----------------------------');
pathAndFilename
%% 1.��ȡ����ϵͳ����
% [filename,path] = uigetfile('.mod','��ѡ�������ļ�');
% pathAndFilename = strcat(path,filename);
% pathAndFilename='UC_AF/10_0_1_w.mod';
% pathAndFilename='UC_AF/10_std.mod';
dataUC.pathAndFilename = pathAndFilename;
fid=fopen(pathAndFilename);
%���Ե�1������
fgetl(fid);                    %ProblemNum
%��ȡ��2������
tmp=fscanf(fid,'%s',1);                     %HorizonLen
dataUC.T=fscanf(fid,'%d',1);                       %HorizonLen   ����ʱ��T
%��ȡ��3������
tmp=fscanf(fid,'%s',1);                     %NumThermal
dataUC.N=fscanf(fid,'%d',1);                       %NumThermal   ����������N
% ���Ե�4-10������
% NumHydro , NumCascade , LoadCurve , MinSystemCapacity, MaxSystemCapacity,
% MaxThermalCapacity, Loads
fgetl(fid);  % ��һ�еĽ�β
for i = 1:7 
    fgetl(fid); 
end
% ��ȡ��11������ ����
dataUC.PD=fscanf(fid,'%f',[1,dataUC.T]);    dataUC.PD = dataUC.PD';                   % ����
% ���Ե�12������
fgetl(fid);fgetl(fid);
% ��ȡ��13������ ����
dataUC.spin = fscanf(fid,'%f',[1,dataUC.T]);  dataUC.spin = dataUC.spin';     % ����
% ���Ե�14������
fgetl(fid);fgetl(fid);
%��ȡN̨�������
for i = 1:dataUC.N
    if strcmp(pathAndFilename,'UC_AF/10_std.mod')
        unit_parameters(i,:) = fscanf(fid,'%f',[1,19]);     
    else
        unit_parameters(i,:) = fscanf(fid,'%f',[1,16]);
    end
    fscanf(fid,'%s',1);
    dataUC.p_rampup(i) = fscanf(fid,'%f',1);
    dataUC.p_rampdown(i) = fscanf(fid,'%f',1);
end
fgetl(fid);fgetl(fid);fgetl(fid);

dataUC.p_rampup = dataUC.p_rampup';   
dataUC.p_rampdown= dataUC.p_rampdown';

dataUC.alpha = unit_parameters(:,4);
dataUC.beta = unit_parameters(:,3);
dataUC.gamma = unit_parameters(:,2);
dataUC.p_low = unit_parameters(:,5);
dataUC.p_up = unit_parameters(:,6);
dataUC.time_on_off_ini = unit_parameters(:,7);
dataUC.time_min_on = unit_parameters(:,8);
dataUC.time_min_off = unit_parameters(:,9);
fixedCost4startup = unit_parameters(:,14);
dataUC.p_initial = unit_parameters(:,16);

dataUC.u0 = sparse(dataUC.N,1);
dataUC.u0(find(dataUC.p_initial>0)) = 1;

dataUC.p_startup = dataUC.p_low;
dataUC.p_shutdown = dataUC.p_low;

if strcmp(dataUC.pathAndFilename,'UC_AF/10_std.mod')
    dataUC.Cold_hour = [5,5,4,4,4,2,2,0,0,0]';
    dataUC.Cold_cost = 2*fixedCost4startup;
else 
    if strcmp(dataUC.pathAndFilename,'UC_AF/8_std.mod')
        dataUC.Cold_hour = [5,5,4,4,4,2,2,0]';
        dataUC.Cold_cost = 2*fixedCost4startup;
    else
        dataUC.Cold_hour = sparse(dataUC.N,1);
        dataUC.Cold_cost = 1*fixedCost4startup;
    end
    
end
dataUC.Hot_cost = fixedCost4startup;

if strcmp(dataUC.pathAndFilename,'UC_AF/8_std.mod')
    dataUC.PD = sum(dataUC.p_up) * [0.71; 0.65; 0.62;  0.6;  0.58;  0.58;  0.6;  0.64;
                                    0.73; 0.8;  0.82;  0.83;   0.82; 0.8;  0.79;  0.79;
                                    0.83; 0.91; 0.9;  0.88;   0.85;  0.84;  0.79;  0.74];
    dataUC.spin = 0.03 * dataUC.PD;
end

dataUC.projected = 0;
dataUC.expended = 0;

fclose(fid);



