

N = 150; %��������

% ��������
[u, y] = creat_data(N);

na = 2;nb = 1;nc = 2; % �״�
d = 3; % �����ʱ��

[theta_a_cn_1, theta_b_cn_1, theta_c_cn_1] = myRELS(na, nb, nc, d, u, y, N);
Nt = length(theta_a_cn_1);
% ��ͼ
A = [1, 1.5, 0.6];
B = [2, -1.4];
C = [1, 1.2, 0.85];
myplot(A, B, C, Nt, theta_a_cn_1, theta_b_cn_1, theta_c_cn_1)