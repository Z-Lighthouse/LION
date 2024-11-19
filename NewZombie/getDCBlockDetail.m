% 获取DC块的具体信息
function dd = getDCBlockDetail(file,h,cur_blk)
% 获得名字
cur_blk_name = getfullname(cur_blk);
cur_blk_type= get_param(cur_blk_name,'BlockType');
cur_blk_type_detail = getFullBlockTypeName(cur_blk_type);
% 输出到文件
fprintf(file,cur_blk_name);
fprintf(file,'\r\n');
fprintf(file,cur_blk_type);
fprintf(file,'\r\n');
fprintf(file,cur_blk_type_detail);
fprintf(file,'\r\n');
fprintf(file,'------------------------');
fprintf(file,'\r\n');
end