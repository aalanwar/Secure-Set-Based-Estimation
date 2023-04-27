clear all
close all

load("cache\p1keq4.mat")
close all
fig = figure('Renderer', 'painters', 'Position', [10 10 900 900]);
clf;
bd = 25;
% xlim([-bd bd]);
% ylim([-bd bd]);
grid on
hold on
Z = conZonotope([1 2 2 2 6 2 8;1 2 2 0 5 0 6 ],[],[]);
%measUpdateGrp{1}=Z;
%h_measSet{2} = plotCZono(measUpdateGrp{1},[1,2],'black','+');
clf;
bd = 25;

grid on
hold on
box on

index =1;
measUpdateGrp = {measUpdateGrp{1},measUpdateGrp{16},measUpdateGrp{22}};
% for ii =1:length(measUpdateGrp)
%         measUpdateGrp{ii} = reduce(measUpdateGrp{ii},'girard',2);
% end




doneInd =[];
for ii =1:length(measUpdateGrp)
    flag =0;
    if ismember(ii,doneInd)
        continue;
    end
    for jj=ii+1:length(measUpdateGrp)
        if abs(center(measUpdateGrp{ii} )- center(measUpdateGrp{jj})) < 0.5
            flag = 1;
            combMeasUpdate{index} = or(measUpdateGrp{ii},measUpdateGrp{jj});
            index = index +1;
            doneInd = [doneInd jj];
        end

    end
    if flag ==0
        combMeasUpdate{index} = measUpdateGrp{ii};
        index = index +1;
    end
end


measUpdateGrp = combMeasUpdate;
hpoint = plot(x(1,k+1),x(2,k+1),'x','LineWidth',Blacklinwid+1);
for j=1:2
    hMeasSet=  plotZono(measSet{j},[1,2],'blue','+','LineWidth',Linwid);
end
hMeasSetAttacked=  plotZono(measSet{3},[1,2],'red','*','LineWidth',Linwid);
for j=1:length(timeUpdateGrp)
    hTimeUpdate=  plotCZono(timeUpdateGrp{j},[1,2],'green','+','LineWidth',Linwid);
end
for j=1:length(measUpdateGrp)
    hMeasUpdate=plotCZono(measUpdateGrp{j},[1,2],'black','+','LineWidth',Blacklinwid);
end


warOrig = warning; warning('off','all');
warning(warOrig);
ax = gca;
ax.FontSize = 26;
%set(gcf, 'Position',  [50, 50, 800, 400])
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
yticks(-6:2:8);
xticks(-5:2:6);
ylim([-6 8])
xlim([-5.5 5])


Yattstr =strcat(' $\mathcal{Y}^', num2str(indexAtt) ,'_k$');
legend([hpoint,hMeasSet,hMeasSetAttacked,hTimeUpdate,hMeasUpdate],...
        'True state $x(k)$',strcat('Safe $\mathcal{Y}_k^',safeIndexStrA,' $\mathcal{Y}_k^',safeIndexStrB),strcat('Attacked',Yattstr),'Time update $\hat{\mathcal{X}}_{k|k-1}$','Meas. update $\hat{\mathcal{X}}_{k|k}$','Location','northwest','Interpreter','latex');

xlabel('$x_1(k)$','Interpreter','latex');
ylabel('$x_2(k)$','Interpreter','latex');
