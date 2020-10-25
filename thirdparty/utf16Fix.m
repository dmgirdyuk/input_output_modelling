% UTF-16 byte-order mark fix
% Решение взято отсюда:
% https://se.mathworks.com/matlabcentral/answers/411337-matlab-doesn-t-read-my-txt-file-correct

fid = fopen('data/VAROW/VAROW.csv','r','n');
bytes = fread(fid)';
fclose(fid);
bytes(1:2) = []; % remove the byte order mark 

asciibytes = bytes(1:2:end); % strip out the zero bytes 
fid = fopen('data/VAROW/VAROW_ascii.csv','w','n','UTF-8');
fwrite(fid,asciibytes);
fclose(fid);
