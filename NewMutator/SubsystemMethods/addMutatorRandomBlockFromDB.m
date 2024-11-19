function dd = addMutatorRandomBlockFromDB(Obj,sys_path)
disp('addMutatorRandomBlockFromDB');
% 每层最大生成块数
GEN_NUM = 3;
% 生成层数
GEN_DEEPTH = 3;
% 数据库操作
conn = database('newzombiedb', 'root', 'zhongrui985527', 'com.mysql.jdbc.Driver', 'jdbc:mysql://localhost:3306/newzombiedb');
% 文件操作
f = fopen('DBCrash.txt','a');
% 生成第一个块
sql = strcat('select srcType from blockMap');
cursorA = exec(conn, sql);
setdbprefs ('DataReturnFormat','cellarray');
cursorA=fetch(cursorA);
all_blk_type = cursorA.Data;
% 去重
all_blk_type = unique(all_blk_type);
% 随机取一个块
blk = randomchoose(all_blk_type);
Name = strcat(sys_path,'/start');
% 生成这个块
add_block(blk,Name);
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
        all_blk_type = addBlockFromdb(blk);
        % 如果没有
        if isempty(all_blk_type)
            continue;
        end
        % 如果数量不够
        if length(all_blk_type) < num
            num = length(all_blk_type);
        end
        for w = 1:num
            % 随机生成一个
            new_blk = randomchoose(all_blk_type);
            nblk_Name = strcat(first_blk,'nzb','_',string(i),'_',string(j),'_',string(w));
            try
                add_block(new_blk,nblk_Name);
            catch e
                fprint2mat(f,e.message,' '+new_blk);
            end
            n_port = get_param(nblk_Name,'PortHandles');
            % 判断一下有没有Inport口
            while isempty(n_port.Inport)
                delete_block(nblk_Name);
                new_blk = randomchoose(all_blk_type);
                nblk_Name = strcat(first_blk,'nzb','_',string(i),'_',string(j),'_',string(w));
                try
                    add_block(new_blk,nblk_Name);
                catch e
                    fprint2mat(f,e.message,' '+new_blk);
                end
                n_port = get_param(nblk_Name,'PortHandles');
            end
            % 添加线
            try
                add_line(sys_path,port.Outport(1),n_port.Inport(1),'autorouting','on');
            catch
            end
            n_tree_list{end+1} = nblk_Name(1,1);
        end
    end
    tree = n_tree_list;
end
% 根据块和数量从数据库中选取生成
    function block_list = addBlockFromdb(name)
        %1.查询类别
        blk_type = get_param(name,'BlockType');
        blk_type = getFullBlockTypeName(blk_type);
        sql = strcat('select * from blockMap where srcType="',blk_type,'"');
        %2.如果没有，就退出
        cursorA = exec(conn, sql);
        setdbprefs ('DataReturnFormat','cellarray');
        cursorA=fetch(cursorA);
        % 如果没有后续的话，就不能再加了
        block_list={};
        if ~isempty(cursorA.Data)
            if strcmp(cursorA.Data{1},'No Data')
                return;
            end
            % 可供选择的块的数组
            for j =1:size(cursorA.Data,1)
                result = string(cursorA.Data{j,3});
                block_list{j} =result;
            end
        end
    end
% 随机选择块的方法
    function blk = randomchoose(all_blk_type)
        num = randi(length(all_blk_type));
        blk = all_blk_type{num};
    end
close(conn);
end
