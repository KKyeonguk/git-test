%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Maxima over the threshold value is stored in 'P' Matrix %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% threshold value rate = max * [Canny : 0.6 | LoG : 0.88]

% road3.png%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img                 =         imread('C:\road3.png');
gray_img            =         rgb2gray(img);
% edge_img            =         edge(img, 'Canny');

edge_img            =         LoG_function(gray_img, 2, 7, 5);     % edge >= 0

% road.png%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img                 =         imread('C:\road.png');

edge_img            =         LoG_function(img, 2, 5, 5);
% edge_img            =         edge(img, 'Canny');


% common

[row, col]          =         size(edge_img);

delta_t             =         1;                                      % 함수입력

delta_rho           =         1;

theta_s             =         -90;                                      % theta min

theta_e             =         90;                                    % theta max [degree]

theta_cnt           =         (theta_e - theta_s);          % the number of theta 

d2r                 =         pi / 180;                               % x [degree] = x * pi / 180

cos_sin             =         zeros((theta_e - theta_s), 2);          % cos, sin Look Up Table

distance            =         sqrt((row - 1)^2 + (col - 1)^2);

rho_max             =         delta_rho * ceil(distance / delta_rho);

rho_min             =         -rho_max;

acc                 =         zeros(rho_max, theta_cnt);        % (rho, theta) pts

Theta               =         theta_s : delta_t : theta_e-1;

nrho                =         2 * ceil(distance / delta_rho) + 1;

ntheta              =         theta_cnt;

temp_rho            =         zeros(1, ntheta);

rho                 =         zeros(1, ntheta);

acc                 =         zeros(nrho, ntheta);

[acc_row, acc_col]  =         size(acc);

diagonal            =         delta_rho * ceil(distance / delta_rho);

rhoRange            =         -diagonal : delta_rho : diagonal;

rho_length          =         length(rhoRange);

%% cos sin LUT
for cnt_cs = 1 : 180                    % 삼각함수 특성상, 한 주기에 대해 값이 일정해지므로, LUT에서 가져가는 순서만 중요함. 그래서 Fixed
          cos_sin(cnt_cs, 1)            =         cos(Theta(1, cnt_cs) * d2r);
          cos_sin(cnt_cs, 2)            =         sin(Theta(1, cnt_cs) * d2r);
end       % theta max < pi 이므로 180도에 대한 cos, sin값은 포함하지 않음.


%% edge confirm & Accumulation (Voting)
for img_cnt_row = 1 : row               % 1242
          for img_cnt_col = 1 : col     % 375             
                    % Calculation about rho
                    if(edge_img(img_cnt_row, img_cnt_col) >= 1)
                              % rho value calculation by theta (-90 ~ 89)
                              for index = 1 : ntheta
                                        rho                 =         (img_cnt_col - 1) * cos_sin(index, 1) + (img_cnt_row - 1) * cos_sin(index, 2);
                                        rho                 =         ceil(rho);
                                        for find_cnt = 1 : rho_length
                                                  if(rhoRange(1, find_cnt) == rho)
                                                            acc(find_cnt, index)          =         acc(find_cnt, index) + 1 ;
                                                  end
                                        end
                              end
                    end
          end
end

mask_size_row                 =         4;                  % 함수입력

mask_size_col                 =         2;                  % 함수입력

local_stride                  =         2;

local_mask                    =         zeros(mask_size_row, mask_size_col);

comp_mask                     =         zeros(1, mask_size_row * mask_size_col);


% Local Maxima Selection
for acc_cnt_row = 1 : local_stride : acc_row - (mask_size_row)
          for acc_cnt_col = 1 : local_stride : acc_col - (mask_size_col)

                    local_mask(1 : mask_size_row, 1 : mask_size_col)                 =         acc(acc_cnt_row : acc_cnt_row + (mask_size_row - 1), acc_cnt_col : acc_cnt_col + (mask_size_col - 1));

                    % N x M Matrix        ->        1 x NM Matrix
                    for sub_row = 1 : mask_size_row
                              for sub_col = 1 : mask_size_col
                                        comp_mask(1, mask_size_col * (sub_row - 1) + sub_col)      =      local_mask(sub_row, sub_col);
                              end
                    end

                    % sorting for MAX
                    for repeat_cnt = 1 : mask_size_row * mask_size_col
                              for comp_cnt = 1 : mask_size_row * mask_size_col - 1
                                        if(comp_mask(1, comp_cnt) < comp_mask(1, comp_cnt + 1))
                                                  temp_mov                               =          comp_mask(1, comp_cnt);
                                                  comp_mask(1, comp_cnt)                 =          comp_mask(1, comp_cnt + 1);
                                                  comp_mask(1, comp_cnt + 1)             =          temp_mov;
                                        end
                              end
                    end

                    % Local Maxima & Zero
                    MAX_value                     =         comp_mask(1,1);

                    for local_cnt_row = 1 : mask_size_row
                              for local_cnt_col = 1 : mask_size_col
                                        if(local_mask(local_cnt_row, local_cnt_col) == MAX_value)
                                                  acc(acc_cnt_row + (local_cnt_row - 1), acc_cnt_col + (local_cnt_col - 1))           =         MAX_value;
                                        else
                                                  acc(acc_cnt_row + (local_cnt_row - 1), acc_cnt_col + (local_cnt_col - 1))           =         0;
                                        end
                              end
                    end
          end
end                 


%% Inverse
cot_csc             =         zeros((theta_e - theta_s), 2);          % cot, csc Look Up Table

temp_th             =         0;

out_line_img        =         zeros(row, col);   

threshold_value     =         max(acc, [], 'all') * 0.98;                                   % Canny : 0.6 | LoG : 0.88


%% cot csc LUT
for cnt_cc = 1 : 180                    % 삼각함수 특성상, 한 주기에 대해 값이 일정해지므로, LUT에서 가져가는 순서만 중요함. 그래서 Fixed
          if(Theta(1, cnt_cc) == 0)
                    cot_csc(cnt_cc, 1)            =         0;
                    cot_csc(cnt_cc, 2)            =         0;   
          else
                    cot_csc(cnt_cc, 1)            =         cot(Theta(1, cnt_cc) * d2r);
                    cot_csc(cnt_cc, 2)            =         csc(Theta(1, cnt_cc) * d2r);
          end
end       % theta max < pi 이므로 180도에 대한 cos, sin값은 포함하지 않음.

imshow(img);
hold on

%% Inversion Hough Transform : Hough Space -> xy
for acc_cnt_row = 1 : acc_row
          for acc_cnt_col = 1 : acc_col
                    temp_acc       =         acc(acc_cnt_row, acc_cnt_col);

                    if(temp_acc >= threshold_value)
                              temp_rho            =        rhoRange(1, acc_cnt_row);
                              temp_theta          =        acc_cnt_col;
                                        % for pts_cnt_x = 1 : col
                                        %           x         =         pts_cnt_x;         
                                        %           y         =         - x * cot_csc(temp_theta, 1) + temp_rho * cot_csc(temp_theta, 2);
                                        %           y         =         int16(y);

                                        %           if(y > 0 && y <= row)
                                        %                     out_line_img(y, x)            =         255;
                                        %                     edge_img(y, x)                =         255;
                                        %                     % img(y, x)                     =         255;
                                        %           end

                                        % end
                                        x1 = 1
                                        y1 = - x1 * cot_csc(temp_theta, 1) + temp_rho * cot_csc(temp_theta, 2);
                                        x2 = col
                                        y2 = - x2 * cot_csc(temp_theta, 1) + temp_rho * cot_csc(temp_theta, 2);

                              plot([x1, x2], [y1, y2]);
                    end
          end
end


out = uint8(out_line_img);

figure, imshow(out);      
figure, imshow(edge_img);      
figure, imshow(img);      


%% Line Detection Denote

image     =         imread('C:\road.png');