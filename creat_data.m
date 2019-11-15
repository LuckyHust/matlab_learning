function [u, y] = creat_data(N)
%����������С���˷�
% �������롢���ż��������

% L = 150;
L = N;
a=[1.5 0.6];b=[2,-1.4];c=[1,1.2,0.85];%ϵͳ����������ʽ

% ���������������
rng('default')
s = rng(0);

e = 0.8*randn(L,1);%��ȷ����
u = randn(L,1); % ���� 
y = zeros(L,1); % ���
seeta_stand = [a,b,c(2:3)];

e0 = zeros(1,2);
u0 = zeros(1,4);
y0 = zeros(1,2);
fa = zeros(1,6);
for i = 1:L
    fa = [-y0,u0(3:4),e0]';
    y(i) = fa'*seeta_stand' + e(i);
    
    for ie = length(e0):-1:2
        e0(ie) = e0(ie-1);
    end
    e0(1) = e(i);
    for iu = length(u0):-1:2
        u0(iu) = u0(iu-1);
    end
    u0(1) = u(i);
    for iy = length(y0):-1:2
        y0(iy) = y0(iy-1);
    end
    y0(1) = y(i);
end

t = 0:0.01:(L-1)*0.01;
%���롢���š�������ӻ�
figure
subplot(211)
plot(t,u,'b',t,e,'g')
legend('u','e')
subplot(212)
plot(t,y)
legend('y')

% �������ݵ�mat�ļ�
t = 0:0.01:1.49;
input_source = [t;u'];
ksai_source = [t;e'];
save('input.mat','input_source');
save('ksai.mat', 'ksai_source');

end
