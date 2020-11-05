clear; clc;

%Dimensões do Robo
a1=0.3; a2=0.3; a3=0.4; % Links do 3R cotovelar
a6=0.1; % Link do punho esferico


% POSE desejada
POSE1 = [ 
-1  0  0  0.7;
 0 -1  0    0;
 0  0  1  0.4;
 0  0  0    1]; % Posição home, entretanto com theta5 = 90°

POSE2 = [ 
-1  0  0  0.606217;
 0 -1  0    0;
 0  0  1  0.75;
 0  0  0    1]; % Posição home, entretanto com theta2=30° | theta5 = 60°

POSE=POSE1;%Escolha da pose
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Primeiro achar o centro do punho
Xc = POSE(1,4) - a6*POSE(1,3);
Yc = POSE(2,4) - a6*POSE(2,3);
Zc = POSE(3,4) - a6*POSE(3,3);
[Xc;Yc;Zc]

% INDICE - MCI de posição
% 1 - Braço frente  Cotovelo Cima
% 2 - Braço frente  Cotovelo Baixo
% 3 - Braço trás    Cotovelo Cima
% 4 - Braço trás    Cotovelo Baixo

% Theta 1
theta1(1) = atan2(Yc,Xc);       %Braço frente
theta1(2) = atan2(Yc,Xc);       %Braço frente
theta1(3) = atan2(Yc,Xc) + pi;  %Braço trás
theta1(4) = atan2(Yc,Xc) + pi;  %Braço trás

% Theta 3
D         = (Xc^2 + Yc^2 + (Zc-a1)^2 - a2^2 - a3^2) / (2*a2*a3);
theta3(1) = atan2(-sqrt(1-D^2),D);  % Cotovelo para cima
theta3(2) = atan2( sqrt(1-D^2),D);  % Cotovelo para baixo
theta3(3) = -theta3(1);             % Cotovelo para cima
theta3(4) = -theta3(2);             % Cotovelo para baixo
 
% Theta 2
theta2(1) = atan2(Zc-a1,sqrt(Xc^2+Yc^2)) - atan2(a3*sin(theta3(1)),a2+a3*cos(theta3(1)));   %Cotovelo para cima
theta2(2) = atan2(Zc-a1,sqrt(Xc^2+Yc^2)) - atan2(a3*sin(theta3(2)),a2+a3*cos(theta3(2)));   %Cotovelo para baixo
theta2(3) = pi-theta2(1);                                                                   %Cotovelo para cima
theta2(4) = pi-theta2(2);                                                                   %Cotovelo para baixo

% INDICE - MCI de Orientação - Punho esferico
% A - Punho Normal
% B - Punho Invertido

% Calculo de R36
R = POSE([1 2 3], [1 2 3]);
for i = 1:4
    R03(:,:) = [
        cos(theta1(i))*cos(theta2(i)+theta3(i)) -cos(theta1(i))*sin(theta2(i)+theta3(i))  sin(theta1(i));
        sin(theta1(i))*cos(theta2(i)+theta3(i)) -sin(theta1(i))*sin(theta2(i)+theta3(i)) -cos(theta1(i));
                       sin(theta2(i)+theta3(i))                 cos(theta2(i)+theta3(i))               0;
    ];
    R36(:,:,i) = (R03.') * R;
end

% Calculo dos Theta
for i = 1:4
    theta4(i) = atan2( -cos(theta1(i))*sin(theta2(i)+theta3(i))*R36(1,3,i) - sin(theta1(i))*sin(theta2(i)+theta3(i))*R36(2,3,i) + cos(theta2(i)+theta3(i))*R36(3,3,i) ,                         cos(theta1(i))*cos(theta2(i)+theta3(i))*R36(1,3,i) + sin(theta1(i))*cos(theta2(i)+theta3(i))*R36(2,3,i) + sin(theta2(i)+theta3(i))*R36(3,3,i) );

    theta4b(i) = theta4(i)+pi;

    theta5(i) = atan2( sqrt(1-(sin(theta1(i))*R36(1,3,i) - cos(theta1(i))*R36(2,3,i))^2),                         sin(theta1(i))*R36(1,3,i) - cos(theta1(i))*R36(2,3,i) );

    theta5b(i)= atan2(-sqrt(1-(sin(theta1(i))*R36(1,3,i) - cos(theta1(i))*R36(2,3,i))^2),                         sin(theta1(i))*R36(1,3,i) - cos(theta1(i))*R36(2,3,i) );

    theta6(i) = atan2(             sin(theta1(i))*R36(1,2,i) - cos(theta1(i))*R36(2,2,i),                        -sin(theta1(i))*R36(1,1,i) + cos(theta1(i))*R36(2,1,i));

    theta6b(i) = theta6(i)+pi;
end

for i = 1:4
    sol (i  ,:) = [theta1(i) theta2(i) theta3(i)  theta4(i)  theta5(i)  theta6(i)]*180/pi;
    sol (i+4,:) = [theta1(i) theta2(i) theta3(i) theta4b(i) theta5b(i) theta6b(i)]*180/pi;
end

sol

% INDICE - MCI COMPLETO
% 1 - Braço frente  Cotovelo Cima   Punho Normal
% 2 - Braço frente  Cotovelo Baixo  Punho Normal
% 3 - Braço trás    Cotovelo Cima   Punho Normal
% 4 - Braço trás    Cotovelo Baixo  Punho Normal
% 5 - Braço frente  Cotovelo Cima   Punho Invertido
% 6 - Braço frente  Cotovelo Baixo  Punho Invertido
% 7 - Braço trás    Cotovelo Cima   Punho Invertido
% 8 - Braço trás    Cotovelo Baixo  Punho Invertido