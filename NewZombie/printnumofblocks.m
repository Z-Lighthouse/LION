function dd = printnumofblocks(obj)
disp('================printnumofblocks================');
obj.l.info('================printnumofblocks================');
dead_blocks = obj.r.dead_blocks;
live_blocks = obj.r.live_blocks;
new_zombie_blocks = obj.r.new_zombile_blocks;
file = fopen('D:\桌面\slemi-new zombile block\NewZombie\blocksdetail.txt','a');
dead_blocks_num = size(dead_blocks,1);
live_blocks_num = size(live_blocks,1);
new_zombie_blocks_num = size(new_zombie_blocks,1);
% 输出到文件

fprintf(file,obj.r.original_sys);
fprintf(file,int2str(dead_blocks_num));
fprintf(file,int2str(live_blocks_num));
fprintf(file,int2str(new_zombie_blocks_num));
fprintf(file,'\r\n');


% fprint2mat(file,obj.r.original_sys,' ');
% fprint2mat(file,int2str(dead_blocks_num),' dead_blocks');
% fprint2mat(file,int2str(live_blocks_num),' live_blocks');
% fprint2mat(file,int2str(new_zombie_blocks_num),' new_zombie_blocks');
% fprint2mat(file,'=====================',' ');
end