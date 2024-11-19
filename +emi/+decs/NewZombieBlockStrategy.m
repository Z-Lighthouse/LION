classdef NewZombieBlockStrategy < emi.decs.DecoratedMutator
    methods
        function obj = NewZombieBlockStrategy(varargin)
            obj = obj@emi.decs.DecoratedMutator(varargin{:});
        end
        % 主方法
        function main_phase(obj)
            obj.l.info('----------------------newzombie----------------------');
            addpath(genpath('.\NewZombie'));
            % 判断是否为含有新僵尸块
            if size(obj.r.new_zombile_blocks, 1) == 0
                obj.l.warn('No New Zombile blocks in the original model! Returning from Decorator.');
                return;
            end
            % 目标僵尸块
            target_blocks = obj.r.new_zombile_blocks_to_annotate;
            num = num2str(length(target_blocks));
            zombie_info = '  new Zombie block ';
            % 记录僵尸块信息
            f = fopen('ZombieBlockDetail.txt','a');
            % 输出各个块的类型
            printnumofblocks(obj);
            % 设置需要记录的内容
            printnumofblocks(obj);
            % 具体变异
            function block_result = helper(blk_name)
                % 去除换行
                blk_name = replace(blk_name,newline,' ');
                % 确定每个新僵尸块的输入与输入
                blkname = [obj.mutant.sys '/' blk_name];
                % 获取本块的类型
                this_blk_type  = get_param(blkname,'BlockType');
                % 如果是SubSystem 直接跳出这个function
                if  strcmp(this_blk_type,'SubSystem')
                    return;
                end
                % 如果是If 直接跳出这个function
                if  strcmp(this_blk_type,'If')
                    return;
                end
                % 获取连接信息
                [connections,~,~] = emi.slsf.get_connections(blkname, true, true);
                % 获得本块的句柄
                PortHandles = struct2table(get_param(blkname, 'PortHandles'),'AsArray', true);
                this_Outport = PortHandles.Outport;
                % 存储之后出现的所有块
                UsedBlockList = {this_Outport};
                % 记录该块的输出
                set_param(this_Outport,'DataLogging','on');
                set_param(this_Outport,'DataLoggingNameMode','Custom');
                set_param(this_Outport,'DataLoggingName','this_block_out');
                % 获得源头块的名字
                src_block_fullnames = getfullname(connections.SrcBlock);
                src_block_fullnames(cellfun(@isempty,src_block_fullnames))=[];
                % 记录源头块的输出
                for i = 1:length(src_block_fullnames)
                    SrcPortHandles = struct2table(get_param(src_block_fullnames{i}, 'PortHandles'),'AsArray', true);
                    src_Outport = SrcPortHandles.Outport;
                    set_param(src_Outport,'DataLogging','on');
                    set_param(src_Outport,'DataLoggingNameMode','Custom');
                    set_param(src_Outport,'DataLoggingName','src_block_out');
                    UsedBlockList{end+1} = src_Outport;
                end
                % 仿真一下,得到输出
                simu_simOut = sim(obj.mutant.sys,'SignalLogging', 'on');
                logsout = simu_simOut.get('logsout');
                % 清除DataLogging
                for w = 1:length(UsedBlockList)
                    set_param(UsedBlockList{w},'DataLogging','off');
                end
                % 数据结果转化
                for j = 1:logsout.numElements
                    element = logsout.getElement(j);
                    if strcmpi(element.Name,'this_block_out')
                        block_result.this_block_out.Name = element.BlockPath.getBlock(1);
                        block_result.this_block_out.Time=element.Values.Time;
                        block_result.this_block_out.Data=element.Values.Data;
                    elseif strcmpi(element.Name,'src_block_out')
                        block_result.src_block_out(j-1).Name = element.BlockPath.getBlock(1);
                        block_result.src_block_out(j-1).Time=element.Values.Time;
                        block_result.src_block_out(j-1).Data=element.Values.Data;
                    end
                end
                % 定向变异 针对Abs
                if  strcmp(this_blk_type,'Abs')
                    % 因为需要删除所以获取一下他的目的地块
                    dst_block_fullnames = getfullname(connections.DstBlock);
                    dst_block_fullnames(cellfun(@isempty,dst_block_fullnames))=[];
                    if ischar(dst_block_fullnames{1})
                        block_result.dst_block_Name = dst_block_fullnames;
                    else
                        block_size = size(dst_block_fullnames{1});
                        for ko = 1:block_size(2)
                            block_result.dst_block_Name{ko} = dst_block_fullnames{1}{ko};
                        end
                    end
                    % 进行具体变异
                    AbsDecs(f,obj,block_result);
                    return;
                end
                % 定向变异 针对MinMax
                if  strcmp(this_blk_type,'MinMax')
                    %进行具体变异
                    MinMaxDecs(f,obj,block_result);
                    return;
                end
            end
            %得到结果
            cellfun(@helper,target_blocks, 'UniformOutput', false);
        end
    end
end

