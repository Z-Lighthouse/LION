function dd = getFullBlockPath(sys)
disp('============getFullBlockPath Start===============');
all_block = find_system(sys,'Type','Block');
% 连接数据库
conn = database('newzombiedb', 'root', 'zhongrui985527', 'com.mysql.jdbc.Driver', 'jdbc:mysql://localhost:3306/newzombiedb');
for i=1:length(all_block)
    src_block = all_block(i);
    [~,~,dst] = emi.slsf.get_connections(src_block{1}, false, true);
    if ~isempty(dst)
        if size(dst.DstBlock,2) ~=1
            for k=1:size(dst.DstBlock,2)
                path_name = getfullname(dst.DstBlock(k));
                blk_type = get_param(path_name,'BlockType');
                if strcmp(blk_type,'SubSystem')
                    continue;
                end
                blk_type = getFullBlockTypeName(blk_type);
                src_block_type =  get_param(src_block,'BlockType');
                if strcmp(src_block_type{1},'SubSystem')
                    continue;
                end
                if strcmp(blk_type,'simulink/Sinks/To Workspace') || strcmp(blk_type,strcat('Scope'))||strcmp(blk_type,'simulink/Quick Insert/Ports & Subsystems/Outport')
                    continue;
                end
                % 这里插入
                src_block_type{1} = getFullBlockTypeName(src_block_type{1});
                sql = strcat('insert ignore into blockMap(srcType,dstType)values("',src_block_type{1},'","',blk_type,'")');
                exec(conn, sql);
            end
        else
            if iscell(dst.DstBlock)
                blocks = dst.DstBlock{1};
                for w=1:length(blocks)
                    path_name = getfullname(blocks(w));
                    blk_type = get_param(path_name,'BlockType');
                    if strcmp(blk_type,'SubSystem')
                        continue;
                    end
                    blk_type = getFullBlockTypeName(blk_type);
                    src_block_type =  get_param(src_block,'BlockType');
                    if strcmp(src_block_type{1},'SubSystem')
                        continue;
                    end
                    if strcmp(blk_type,'simulink/Sinks/To Workspace') || strcmp(blk_type,strcat('Scope'))||strcmp(blk_type,'simulink/Quick Insert/Ports & Subsystems/Outport')
                        continue;
                    end
                    % 这里插入
                    src_block_type{1} = getFullBlockTypeName(src_block_type{1});
                    sql = strcat('insert ignore into blockMap(srcType,dstType)values("',src_block_type{1},'","',blk_type,'")');
                    exec(conn, sql);
                end
            else
                path_name = getfullname(dst.DstBlock);
                blk_type = get_param(path_name,'BlockType');
                if strcmp(blk_type,'SubSystem')
                    continue;
                end
                blk_type = getFullBlockTypeName(blk_type);
                src_block_type =  get_param(src_block,'BlockType');
                if strcmp(src_block_type{1},'SubSystem')
                    continue;
                end
                if strcmp(blk_type,'simulink/Sinks/To Workspace') || strcmp(blk_type,strcat('Scope'))||strcmp(blk_type,'simulink/Quick Insert/Ports & Subsystems/Outport')
                    continue;
                end
                % 这里插入
                src_block_type{1} = getFullBlockTypeName(src_block_type{1});
                sql = strcat('insert ignore into blockMap(srcType,dstType)values("',src_block_type{1},'","',blk_type,'")');
                exec(conn, sql);
            end
        end
    end
end
close(conn);
end
