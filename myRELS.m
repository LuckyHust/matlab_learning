function  [theta_a, theta_b, theta_c]  = myRELS( na, nb, nc, d, u, y, N)
%����������С���˷�
%   na��������ֵĽ״�
%   nb�����벿�ֵĽ״�
%   nc���������ֵĽ״�
%   d�����ض����ʱ��
%   u�������ź�
%   y������ź�
%   K����������

% ���ó�ֵ
len_b = nb + 1;
len = na + len_b + nc;

theta = zeros(len, 1);%B�е�һ��Ԫ��ҲҪ����
P = eye(len) * 10^6;

% ��na=2 nb=1 nc=2 d=3Ϊ��
% ��������������������
y_part = zeros(na, 1); % [y(k-1); y(k-2)]
u_part = zeros(len_b+d-1, 1); % [u(k-1); u(k-2); u(k-3); u(k-4)]
%���d-1����ʵ�����ƹ��ܣ��ҵ�һ��Ԫ���ܱ��浱ǰʱ�̵�u
e_part = zeros(nc, 1); % �������Ƴ�ֵ [e(k-1), e(k-2)]

res = [];
k = 1; %k�ǵ���/������������1��ʼ��1��Ӧt=0ʱ�̵ĳ�ʼ״̬; y��u����ʱ����ֵ
while k <= N
    % ��Ϊt=0(k=1)ʱ�̾��ǵ�һ��������ʱ��
    fai = [-y_part; u_part(d:end); e_part]; % ��������
    y_k = y(k); % ����
    
    % ����K(k)
    K = P * fai / (1 + fai' * P * fai); 
    % ����theta����С���˹���
    theta = theta + K * (y_k - fai' * theta); % theta����ʱ����������
    res = [res; theta'];
    % ����P
    P = ( eye(len) - K * fai') * P;
    % ���������ϵ�thetaӦ��Ϊk��faiʵ���ϵı���Ӧ��Ϊfai(k)��������k-1
    ksai = y_k - fai' * theta;
    
    % ����a���֣���ǰ��ֵ����һʱ�̾���k-1ʱ��
    for i = length(y_part):-1:2
       y_part(i) = y_part(i-1);
    end
    y_part(1) = y_k;
    % ����b����
    for i = length(u_part):-1:2
       u_part(i) = u_part(i-1);
    end
    u_part(1) = u(k);
    % ����ksai(c)����
    for i = length(e_part):-1:2
        e_part(i) = e_part(i-1);
    end
    e_part(1) = ksai;

    % ���µ�������k
    k = k + 1;
end

theta_a = res(:, 1:na);
theta_b = res(:, na+1:end-(nc-1)-1);
theta_c = res(:, end-(nc-1):end);

end