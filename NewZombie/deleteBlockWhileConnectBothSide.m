% 该方法可以将本块删去，前后两个块连接
function dd = deleteBlockWhileConnectBothSide(f,obj,src_block_Name,this_block_Name,dst_block_NameList)
% 获取到这些块到输入输出端口
src_handle = get_param(src_block_Name,'PortHandles');
this_handle = get_param(this_block_Name,'PortHandles');
% 得到该块所在的子系统
sys = strsplit(this_block_Name,'/');
for j =1:length(sys) -1
    if j ==1
        token = sys{j};
    else
        token = [token,'/',sys{j}];
    end
end
% 删除本块与输入块的线
delete_line(token,src_handle.Outport,this_handle.Inport);
% 完成其他操作
if length(dst_block_NameList)~=1
    for i =1:length(dst_block_NameList)
        % 获取目的地句柄
        dst_handle = get_param(dst_block_NameList{i},'PortHandles');
        % 完成删除与连接
        delete_line(token,this_handle.Outport,dst_handle.Inport);
        add_line(token,src_handle.Outport,dst_handle.Inport,'autorouting','on');
    end
else
    % 获取目的地句柄
    dst_handle = get_param(dst_block_NameList{1},'PortHandles');
    % 完成删除与连接
    delete_line(token,this_handle.Outport,dst_handle.Inport);
    add_line(token,src_handle.Outport,dst_handle.Inport,'autorouting','on');
end
% 删除原本块
delete_block(this_block_Name);
end