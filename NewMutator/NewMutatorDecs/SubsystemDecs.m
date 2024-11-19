function dd = SubsystemDecs(obj,this_block_name)
obj.l.info('----------------------SubsystemDecs Start----------------------');
% 获取连接信息
[connections,~,~] = emi.slsf.get_connections(this_block_name, true, true);
% 需要把没有目标块的过滤掉
if iscell(connections.DstBlock)
    if isempty(connections.DstBlock{end})
        return;
    end
    dstblock = connections.DstBlock{end};
else
    dstblock = connections.DstBlock(end);
end
% 封装出一个可用稳定的目的块
dst_block_names = getfullname(dstblock);
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
    if (hang == 1 && lie~=1) && (lie < 5)
        dst_block_names = dst_block_names';
        dst_block_name = dst_block_names{1}(1,end);
        dst_block_name = dst_block_name{1};
    end
catch
    dst_block_name = dst_block_names;
end
% 获取目的地块的输入
PortHandles = struct2table(get_param(dst_block_name, 'PortHandles'),'AsArray', true);
dst_Inport = PortHandles.Inport;
% 获取第一个目标块的接点
PortHandles = struct2table(get_param(this_block_name, 'PortHandles'),'AsArray', true);
this_Outport = PortHandles.Outport;
% 生成Subsystem
load_system('simulink');
subsystem_name = strcat(this_block_name,'_sb');
add_block('simulink/Commonly Used Blocks/Subsystem',subsystem_name);
% 在两个块中加入一个块
PortHandles = struct2table(get_param(subsystem_name, 'PortHandles'),'AsArray', true);
sb_Outport = PortHandles.Outport;
sb_Inport = PortHandles.Inport;
% sb_Inport = PortHandles.Inport;
% 得到该块所在的子系统
sys = strsplit(this_block_name,'/');
for j =1:length(sys) -1
    if j ==1
        token = sys{j};
    else
        token = [token,'/',sys{j}];
    end
end
% 连接单接口
if length(dst_Inport) ~=1
    % 删除原连线
    delete_line(token,this_Outport,dst_Inport(1));
    % 连接首尾
    add_line(token,this_Outport,sb_Inport);
    add_line(token,sb_Outport,dst_Inport(1));
else
    % 删除原连线
    delete_line(token,this_Outport,dst_Inport);
    % 连接首尾
    add_line(token,this_Outport,sb_Inport);
    add_line(token,sb_Outport,dst_Inport);
end
% 在子系统中随机添加
switch emi.cfg.SAMPLETYPE
    case 1
        % 1.从库里加
        addMutatorRandomBlockFromLibrary(subsystem_name);
    case 2
        % 2.从模型中加
        addMutatorRandomBlockFromSystem(obj,subsystem_name);
    case 3
        % 3.从数据库里添加
        addMutatorRandomBlockFromDB(obj,subsystem_name);
end
end