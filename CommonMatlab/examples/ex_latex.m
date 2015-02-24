figure
% text(0.1,0.5,'$y = L + (U-L)\frac{\exp(\frac{x-b}{a})}{1 + \exp(\frac{x-b}{a}}$','interpreter','latex',...
%     'FontSize',20)

%clf
text(0.1,0.5,'$P = A \;\frac{e\:(\frac{x-bias}{slope}\:)}{1 + e \:(\frac{x-bias}{slope}\:)} + $ \fontfamily{phv}\selectfont Offset','interpreter','latex',...
    'FontSize',20)

%text(0.1, 0.5, '\fontfamily{cmtt}\selectfont Einstein: $E = m c^2$', ...
 %   'Interpreter', 'latex', 'FontSize', 32)


export_fig('LogisticEqn','-pdf','-transparent')
 title('$A_N = 1- \displaystyle\sum_{i=0}^T {N\choose i} p^i (1-p)^{N-i}$','interpreter','latex');