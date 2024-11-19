function dd = DeadSignalDecs(obj,this_block_name)
obj.l.info('----------------------DeadSignalDecs Start----------------------');
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
if length(this_Outport) ~=1
    delete_line(token,this_Outport(1),dst_Inport);
else
    delete_line(token,this_Outport,dst_Inport);
end
% 在这中间生成抉择信号块
load_system('simulink');
% 输入块
sf_name1 = strcat(this_block_name,'_sink');
h = add_block('simulink/Signal Routing/Manual Variant Sink',sf_name1);
PortHandles = struct2table(get_param(sf_name1, 'PortHandles'),'AsArray', true);
sf1_Inport = PortHandles.Inport;
sf1_Outport = PortHandles.Outport;
% 连接连线
if length(dst_Inport) ~=1
    add_line(token,sf1_Outport(1),dst_Inport(1));
else
    add_line(token,sf1_Outport(1),dst_Inport);
end
if length(this_Outport) ~=1
    add_line(token,this_Outport(1),sf1_Inport);
else
    add_line(token,this_Outport,sf1_Inport);
end
% 具体变异
switch emi.cfg.SAMPLETYPE
    case 1
        % 1.库里加
        addSignalBlockFromLibrary(sf_name1,token);
        % addRecoverBlockFromLibrary(sf_name1,token);
    case 2
        % 2.当前模型里加
        addSignalBlockFromSystem(obj,sf_name1,token);
        % addRecoverBlockFromSystem(obj,sf_name1,token);
    case 3
        % 3.从数据库里加
        % addSignalBlockFromLibrary(sf_name1,token)
        % last_Outport = addRecoverBlockFromDB(obj,sf_name1,token);
end
end