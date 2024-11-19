function dd = addMutatorRandomBlockFromSystem(Obj,sys_path)
disp('addRandomBlockFromSystem');
% 每层最大生成块数
GEN_NUM = 3;
% 生成层数
GEN_DEEPTH = 3;
% 获得该系统中的所有块
all_block = find_system(Obj.mutant.sys,'Type','Block');
all_blk_type = get_param(all_block,'BlockType');
% 去重
all_blk_type = unique(all_blk_type);
% 去掉一些不能生成的 SubSystem Outport To Workspace
all_blk_type(strcmp(all_blk_type,'Outport'))=[];
all_blk_type(strcmp(all_blk_type,'SubSystem'))=[];
all_blk_type(strcmp(all_blk_type,'ToWorkspace'))=[];
all_blk_type(strcmp(all_blk_type,'ActionPort'))=[];
all_blk_type(strcmp(all_blk_type,'S-Function'))=[];
all_blk_type(strcmp(all_blk_type,'S-Function'))=[];
% Entity↵Transport Delay From↵File Signal Editor  From Spreadsheet From
% Workspace
% 获取具体名
for ko =1:length(all_blk_type)
    all_blk_type{ko} = getFullBlockTypeName(all_blk_type{ko});
end
% all_blk_type = GetAllBlockFromLibrary();
% 随机取一个块
blk = randomchoose(all_blk_type);
Name = strcat(sys_path,'/start');
% 生成这个块
add_block(blk,Name);
% 记录第一个块的名字
first_blk = Name;
% 判断一下是否是If
if contains(blk,'If')
    if_sub = strcat(Name,'if_sub');
    add_block('simulink/Ports & Subsystems/If Action Subsystem',if_sub);
    ifaction_port = get_param(if_sub,'PortHandles');
    n_port = get_param(Name,'PortHandles');
    add_line(token,n_port.Outport(1),ifaction_port.Ifaction,'autorouting','on');
    Name = if_sub;
end
% 根据层数生成
tree = {Name};
for i = 1:GEN_DEEPTH
    % 看看几个要生成的
    n_tree_list={};
    for j =1:length(tree)
        % 随机确定生成几个
        num = randi(GEN_NUM);
        blk = tree{j};
        port = get_param(blk,'PortHandles');
        for w = 1:num
            % 随机生成一个
            new_blk = randomchoose(all_blk_type);
            nblk_Name = strcat(first_blk,'nzb','_',string(i),'_',string(j),'_',string(w));
            add_block(new_blk,nblk_Name);
            n_port = get_param(nblk_Name,'PortHandles');
            % 判断一下有没有Inport口
            while isempty(n_port.Inport)
                delete_block(nblk_Name);
                new_blk = randomchoose(all_blk_type);
                nblk_Name = strcat(first_blk,'nzb','_',string(i),'_',string(j),'_',string(w));
                add_block(new_blk,nblk_Name);
                n_port = get_param(nblk_Name,'PortHandles');
            end
            % 添加线
            try
                add_line(sys_path,port.Outport(1),n_port.Inport(1),'autorouting','on');
            catch
            end
            n_tree_list{end+1} = nblk_Name(1,1);
            % 判断一下是否是If
            if contains(new_blk,'If')
                if_sub = strcat(nblk_Name,'if_sub');
                add_block('simulink/Ports & Subsystems/If Action Subsystem',if_sub);
                ifaction_port = get_param(if_sub,'PortHandles');
                add_line(sys_path,n_port.Outport(1),ifaction_port.Ifaction,'autorouting','on');
                nblk_Name = if_sub;
                n_tree_list{end} = nblk_Name;
            end
        end
    end
    tree = n_tree_list;
end
% 随机选择块的方法
    function blk = randomchoose(all_blk_type)
        num = randi(length(all_blk_type));
        blk = all_blk_type{num};
    end
end
