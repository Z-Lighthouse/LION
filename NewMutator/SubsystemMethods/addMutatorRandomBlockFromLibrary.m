function dd = addMutatorRandomBlockFromLibrary(sys_path)
disp('addMutatorRandomBlockFromLibrary');
% 每层最大生成块数
GEN_NUM = 2;
% 生成层数
GEN_DEEPTH = 2;
% 获得Library中的所有块
all_blk_type = GetAllBlockFromLibrary();
% 根据层数生成
if emi.cfg.IFCONNECTLINE
    Name = strcat(sys_path,'/In1');
    first_blk = Name;
    tree = {Name};
else
    % 随机取一个块
    blk = randomchoose(all_blk_type);
    Name = strcat(sys_path,'/start');
    % 生成这个块
    add_block(blk,Name);
    % 记录第一个块的名字
    first_blk = Name;
    % 让他自动填上
    if contains(blk,'First Order Hold')
        set_param(Name,'AllowContinuousInput','on');
    end
    % 判断一下是否是If
    if contains(blk,'If')
        if_sub = strcat(Name,'if_sub');
        add_block('simulink/Ports & Subsystems/If Action Subsystem',if_sub);
        ifaction_port = get_param(if_sub,'PortHandles');
        n_port = get_param(Name,'PortHandles');
        add_line(token,n_port.Outport(1),ifaction_port.Ifaction,'autorouting','on');
        Name = if_sub;
    end
    tree = {Name};
end
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
            if contains(new_blk,'First Order Hold')
                set_param(nblk_Name,'AllowContinuousInput','on');
            end
            % 设置采样时间
            try
                set_param(nblk_Name,'SampleTime','-1')
            catch
            end
            % 添加线
            add_line(sys_path,port.Outport(1),n_port.Inport(1),'autorouting','on');
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

