classdef DataRecoverBlockStrategy < emi.decs.DecoratedMutator
    methods
        function obj = DataRecoverBlockStrategy(varargin)
            obj = obj@emi.decs.DecoratedMutator(varargin{:});
        end
        % 主方法
        function main_phase(obj)
            obj.l.info('----------------------DataRecover----------------------');
            addpath(genpath('.\NewMutator'));
            % 选择几个地方进行变异
            CHOOSE_NUM = 5;
            % 目标块
            target_blocks = obj.r.blocks_to_annotate;
            % 采用不同的采样方法进行需要选择
            target_blocks = randomGetBlocks(target_blocks,CHOOSE_NUM);
            % 变异
            function block_result = helper(blk_name)
                blk_name = replace(blk_name,newline,' ');
                % 获取这个块的全称
                this_block_name = [obj.mutant.sys '/' blk_name];
                switch emi.cfg.DECSTYPE
                    case 1
                        % 1.加子系统
                        SubsystemDecs(obj,this_block_name);
                    case 2
                        % 2.进行恢复
                        RecoverDecs(obj,this_block_name);
                    case 3
                        % 3.子系统+恢复
                        RecoverandSubsystemDecs(obj,this_block_name);
                end
            end
            %得到结果
            cellfun(@helper,target_blocks, 'UniformOutput', false);
            % 1.随机采样方法
            function target_blocks = randomGetBlocks(target_blocks,CHOOSE_NUM)
                len = length(target_blocks);
                % 判断CHOOSE_NUM的大小
                if CHOOSE_NUM > len
                    CHOOSE_NUM = len;
                end
                % 打乱顺序
                num = randperm(len);
                num = num(1:CHOOSE_NUM);
                % 取具体的数据
                blocks = {};
                for i =1:CHOOSE_NUM
                    blocks{end+1} = target_blocks{i};
                end
                target_blocks = blocks;
            end
            % 2.基于Glibs的采样方法
            function target_blocks = randomGlibsGetBlocks(target_blocks,CHOOSE_NUM)
                len = length(target_blocks);
            end
        end
    end
end

