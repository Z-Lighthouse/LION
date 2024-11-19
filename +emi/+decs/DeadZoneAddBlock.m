classdef DeadZoneAddBlock < emi.decs.DecoratedMutator
    methods
        function obj = DeadZoneAddBlock(varargin)
            obj = obj@emi.decs.DecoratedMutator(varargin{:});
        end
        function main_phase(obj)
            obj.l.info('----------------------DeadZoneAddBlock----------------------');
            if size(obj.r.dead_blocks, 1) == 0
                obj.l.warn('No dead blocks in the original model! Returning from Decorator.');
                return;
            end
            blocks_to_add = obj.r.sample_dead_blocks_to_delete();
            blocks_to_add = cellfun(@(p) [obj.mutant.sys '/' p], blocks_to_add, 'UniformOutput', false);
            blocks_to_add = utility.unique(blocks_to_add);
            % 得到该块所在的子系统
            function block_result = helper(block)
                sys = strsplit(block,'/');
                for j =1:length(sys) -1
                    if j ==1
                        token = sys{j};
                    else
                        token = [token,'/',sys{j}];
                    end
                end
                % 判断一下是否是If
                blk_type = get_param(block,'BlockType');
                if contains(blk_type,'If')
                    return;
%                     if_sub = strcat(block,'if_sub');
%                     add_block('simulink/Ports & Subsystems/If Action Subsystem',if_sub);
%                     ifaction_port = get_param(if_sub,'PortHandles');
%                     n_port = get_param(block,'PortHandles');
%                     try
%                         add_line(token,n_port.Outport(1),ifaction_port.Ifaction,'autorouting','on');
%                     catch
%                         try
%                             add_line(token,n_port.Outport(2),ifaction_port.Ifaction,'autorouting','on');
%                         catch
%                             return;
%                         end
%                     end
%                     block = if_sub;
                end
                switch emi.cfg.SAMPLETYPE
                    case 1
                        % 1.从库中添加块
                        LibraryAddBlock(obj,token,block);
                    case 2
                        % 2.系统中添加块
                        SystemAddBlock(obj,token,block);
                    case 3
                        % 3.从数据库中添加块
                        disp('Not finish now');
                end
            end
            %得到结果
            cellfun(@helper,blocks_to_add, 'UniformOutput', false);
        end
        % 从系统中添加块
        function dd = SystemAddBlock(obj,sys_path,Name)
            % 每层最大生成块数
            GEN_NUM = 3;
            % 生成层数
            GEN_DEEPTH = 3;
            % 获得该系统中的所有块
            all_block = find_system(obj.mutant.sys,'Type','Block');
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
            % 获取具体名
            for ko =1:length(all_blk_type)
                all_blk_type{ko} = getFullBlockTypeName(all_blk_type{ko});
            end
            % 记录第一个块的名字
            first_blk = Name;
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
                        new_blk = randomchoose(obj,all_blk_type);
                        nblk_Name = strcat(first_blk,'nzb','_',string(i),'_',string(j),'_',string(w));
                        add_block(new_blk,nblk_Name);
                        n_port = get_param(nblk_Name,'PortHandles');
                        % 判断一下有没有Inport口
                        while isempty(n_port.Inport)
                            delete_block(nblk_Name);
                            new_blk = randomchoose(obj,all_blk_type);
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
        end
        % 从库中添加块
        function dd = LibraryAddBlock(obj,sys_path,Name)
            % 每层最大生成块数
            GEN_NUM = 3;
            % 生成层数
            GEN_DEEPTH = 3;
            % 获得Library中的所有块
            all_blk_type = GetAllBlockFromLibrary();
            first_blk = Name;
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
                        new_blk = randomchoose(obj,all_blk_type);
                        nblk_Name = strcat(first_blk,'nzb','_',string(i),'_',string(j),'_',string(w));
                        add_block(new_blk,nblk_Name);
                        n_port = get_param(nblk_Name,'PortHandles');
                        % 判断一下有没有Inport口
                        while isempty(n_port.Inport)
                            delete_block(nblk_Name);
                            new_blk = randomchoose(obj,all_blk_type);
                            nblk_Name = strcat(first_blk,'nzb','_',string(i),'_',string(j),'_',string(w));
                            add_block(new_blk,nblk_Name);
                            n_port = get_param(nblk_Name,'PortHandles');
                        end
                        if contains(new_blk,'First Order Hold')
                            set_param(nblk_Name,'AllowContinuousInput','on');
                        end
                        %                         % 设置采样时间
                        %                         try
                        %                             set_param(nblk_Name,'SampleTime','-1')
                        %                         catch
                        %                         end
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
        end
        % 随机选择块的方法
        function blk = randomchoose(obj,all_blk_type)
            num = randi(length(all_blk_type));
            blk = all_blk_type{num};
        end
    end
end

