function [sys,x0,str,ts,simStateCompliance] = my_online_RLS(t,x,u,flag,na,nb,nc,d,alpha)
% ���ߵ�����С���˷������Կ��ǰ���������ɫ����
% u �����룬����ϵͳ����������
% na����ַ��̵�A�Ľ״�
% nb����ַ��̵�B�Ľ״�
% nc����ַ��̵�C�Ľ״�
% d ����ַ��������ʱ��
% alpha����������

n = [na, nb, nc]; % �������״α�����������

switch flag
  case 0
    [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes(n,d);
  case 1
    sys=mdlDerivatives(t,x,u);
  case 2
    sys=mdlUpdate(t,x,u,n,d,alpha);
  case 3
    sys=mdlOutputs(t,x,u);
  case 4
    sys=mdlGetTimeOfNextVarHit(t,x,u);
  case 9
    sys=mdlTerminate(t,x,u);
  otherwise
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));
end

function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes(n,d)
global P K len %����Update�㷨��Ҫ�õ�������Ϊȫ�ֱ���
len = sum(n) + 1; % ����theta�ĳ���

sizes = simsizes;
sizes.NumContStates  = 0;
% na��һ�����浱ǰʱ�̵�λ�ã�nb��һ���������Լ�����d��ʱ�̵�λ�ã�nc��һ�����浱ǰʱ�̵�λ��
sizes.NumDiscStates  = len * 2 + d - 1; %ǰ��len + d - 1Ϊfai������lenΪtheta
sizes.NumOutputs     = len; % theta
sizes.NumInputs      = 2; % ����������źź�������
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;   % at least one sample time is needed
sys = simsizes(sizes);

x0  = zeros(sizes.NumDiscStates,1);
str = [];
ts  = [-1 0];

P = eye(len) * 1e6;% ��ʼ��P������״�ͬfai
K = 0;
simStateCompliance = 'UnknownSimState';

function sys=mdlDerivatives(t,x,u)
sys = [];

function sys=mdlUpdate(t,x,u,n,d,alpha)
na = n(1); nb = n(2); nc = n(3);
input = u(1); y = u(2);

global P K len

% �����x������������fai��Ҳ�ǳ�ʼ��ʱ��x0
y_part_rb = na; % y_part���ұ߽�
y_part = x(1:y_part_rb); % na��
u_part_rb = y_part_rb + (nb+1) + d - 1; % u_part���ұ߽�
u_part = x(y_part_rb+1 : u_part_rb); % nb + 1 + d - 1��
ksai_part_rb = u_part_rb + nc;
ksai_part = x(u_part_rb+1 : ksai_part_rb); % ��nc��
theta = x(ksai_part_rb + 1:end); %��len=na+nb+1+nc��  end-(len-1) = ksai_part_rb
% ������������
if nc > 0 
    fai = [y_part; u_part(d:end); ksai_part];
else
    fai = [y_part;u_part(d:end)];
end

% ���㵱ǰʱ�̵�K(k)���������õ��ı���������һʱ�̵�
K = (P * fai) / (alpha + fai' * P * fai);
% ���㵱ǰʱ�̵Ĳ�������ֵtheta
theta = theta + K * (y - fai' * theta); % ��������theta�ͺ����faiҪһ����µ�״̬������
% ���㵱ǰʱ�̵�P
P = (eye(len) - K * fai') * P / alpha;
% ������������ֵ
ksai = y - fai' * theta;

% ����״̬�������y�Ĳ���
% t = 0.01ʱ(k=1)��y(k-1)=y(0)����fai(k-1),y(1)������y_part(0)
for i = length(y_part):-1:2
    y_part(i) = y_part(i-1);
end
y_part(1) = -y; % ��¼��ǰʱ�̵�-y
% ����״̬��������u�Ĳ���
for i = length(u_part):-1:2
    u_part(i) = u_part(i-1);
end
u_part(1) = input; % ��¼��ǰʱ�̵�u
fai_u = u_part(d:end);
% ����״̬��������ksai�Ĳ��֣� ���㵱ǰʱ�̵�����ksai��
if nc > 0
    for i = length(ksai_part):-1:2
        ksai_part(i) = ksai_part(i-1);
    end
    ksai_part(1) = ksai; % ��¼��ǰʱ�̵�ksai,��һʱ����
end
% fai��theta���µ�״̬����
x = [y_part;u_part;ksai_part;theta]; %[fai;theta]�Ǵ�ģ�x��״̬��������������ʱ����
sys = x;

function sys=mdlOutputs(t,x,u)
global len
theta = x(end-(len-1):end);
sys = theta;

function sys=mdlGetTimeOfNextVarHit(t,x,u)
sys = [];

function sys=mdlTerminate(t,x,u)
sys = [];
