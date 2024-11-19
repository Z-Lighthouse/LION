function dd = RecoverandSubsystemDecs(obj,this_block_name)
obj.l.info('----------------------RecoverDecs Start----------------------');
% 获取连接信息
[connections,~,~] = emi.slsf.get_connections(this_block_name, true, true);
% 需要把没有目标块的过滤掉
if iscell(connections.DstBlock)
    if isempty(connections.DstBlock{1})
        return;
    end
    dstblock = connections.DstBlock{1};
else
    dstblock = connections.DstBlock(1);
end
% 获取到目标块
dst_block_names = getfullname(connections.DstBlock);
[hang lie] = size(dst_block_names);
% 处理一些Simulink不规范问题
if hang ~= 1
    dst_block_names(cellfun(@isempty,dst_block_names))=[];
    dst_block_names = dst_block_names{1,1};
else
    dst_block_names = {dst_block_names};
end
try
    dst_block_name = dst_block_names{1};
catch
    dst_block_name = dst_block_names;
end
% 获取目的地块的输入
PortHandles = struct2table(get_param(dst_block_name, 'PortHandles'),'AsArray', true);
dst_Inport = PortHandles.Inport;
% 获取第一个目标块的接点
PortHandles = struct2table(get_param(this_block_name, 'PortHandles'),'AsArray', true);
this_Outport = PortHandles.Outport;
% 得到该块所在的子系统
sys = strsplit(this_block_name,'/');
for j =1:length(sys) -1
    if j ==1
        token = sys{j};
    else
        token = [token,'/',sys{j}];
    end
end
% 删除原连线
delete_line(token,this_Outport,dst_Inport);
% 在这中间生成两个S-Function
load_system('simulink');
% 输入块
sf_name1 = strcat(this_block_name,'_sf1');
h = add_block('simulink/User-Defined Functions/S-Function',sf_name1);
set_param(sf_name1,'FunctionName','normalfunction');
PortHandles = struct2table(get_param(sf_name1, 'PortHandles'),'AsArray', true);
sf1_Inport = PortHandles.Inport;
sf1_Outport = PortHandles.Outport;
add_line(token,this_Outport,sf1_Inport);
% 接收块
sf_name2 = strcat(this_block_name,'_sf2');
add_block('simulink/User-Defined Functions/S-Function',sf_name2);
set_param(sf_name2,'FunctionName','recoverfunction');
PortHandles = struct2table(get_param(sf_name2, 'PortHandles'),'AsArray', true);
sf2_Outport = PortHandles.Outport;
sf2_Inport = PortHandles.Inport;
add_line(token,sf2_Outport,dst_Inport);
% 具体变异
switch emi.cfg.SAMPLETYPE
    case 1
        % 1.库里加
        last_Outport = addRecoverMutatorBlockFromLibrary(sf_name1,token);
    case 2
        % 2.当前模型里加
        last_Outport = addRecoverMutatorBlockFromSystem(obj,sf_name1,token);
    case 3
        % 3.数据库里加
        last_Outport = addRecoverMutatorBlockFromDB(obj,sf_name1,token);
end
% 连通路径最后一个块
if length(last_Outport)==1
    add_line(token,last_Outport,sf2_Inport);
else
    add_line(token,last_Outport(1),sf2_Inport);
end
end