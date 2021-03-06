close all; clear all; clc;

% TODO 0: try cross-clusters; only have a few columns of A, global sparse case,
% 10m rows and some columns, try to speed up; local sparse case, 10m rows,
% but the column indices for each row we have are different, this example
% comes from the kNN sparse similarity, we have value and index talk and
% skiny matrices. in computation, the k nn might be infered from different
% columns of information. fort example, 2 & 3 are close and indicated for
% point 2 but not for point 3. then when compute with point 3, we can use
% the information from pint 2.

% choose different eigensolvers, msol
% 1. eigs in matlab
% 2. Chebyshev preconditioner
% 3. coordinate descent with adaptive entry-wise update, TODO 3

% choose different clustering methods, mclc
% mclc = 1: symmetric normalized Laplaican
% mclc = 2: random walk normalized adjacency matrix

format shortE

mclc = 2
npts = 100
fname = "1000/sim" + int2str(npts) + ".json"
fpath = "sim"+ int2str(npts)  +".png"

% TODO 4: bi-clustering for a few times v.s. clustering with k eigenpairs
% TODO 5: whether we use k-means in the second step;

% prepare a toy example
%fig = figure();
%subplot(1,2,1);
%npts = 50;
x1 = 1 + randn(npts/2,1)/9;
x2 =  randn(npts/2,1)/9;
x = [x1,x2];
h(1) = plot(x1,x2,'or'); hold on;
x1 =  randn(npts/2,1)/9;
x2 =  1 + randn(npts/2,1)/9;
y = [x1,x2];
x = [x;y];
h(2) = plot(x1,x2,'*b');
axis square;
title('Given clusters')

% compute the similarity matrix A and the matrix L
% TODO 1: design a matrix-free method so that we don't need to generate A,
% Lnorm, and P
%npts=size(x,1);
%sigma = 0.1;
%A=zeros(npts,npts);
%for i=1:npts
%    for j=1:npts
%        A(i,j) = exp(-norm(x(i,:)-x(j,:))^2/sigma);
%    end
%end
% binary example
% A = zeros(npts,npts);
% A(1:npts/4,1:npts/4) = 1;
% A(npts/2+1:end,npts/2+1:end) = 1;
% A(npts/4+1:npts/2,npts/4+1:npts/2) = 1;

fid = fopen(fname);
raw = fread(fid, inf);
str = char(raw');
A = jsondecode(str);

D2inv = diag(1./sqrt(sum(A,2)));
Dinv = diag(1./(sum(A,2)));
size(D2inv)
size(A)
Lnorm = eye(npts) - D2inv*A*D2inv; % symmetric normalized Laplacian
P = Dinv*A; % random walk normalized adjacency matrix


% find eigen pairs
% TODO 2: Lnorm matrix is too singular and needs preconditioning
switch mclc
    case 1
        [vec,val] = eigs(Lnorm,2,'smallestabs');
        vec = vec(:,2);
        idx = sign(vec - median(vec));
    case 2
        tic;
        for i = 1:5
            [vecr,valr] = eigs(P,1); % working
            idx = sign(vecr - median(vecr));
        end
        time = toc/5;
end

% visualize binary clustering
subplot(1,2,2);
loc = find(idx==1);
h(3) = plot(x(loc,1),x(loc,2),'or'); hold on;
loc = find(idx==-1);
h(4) = plot(x(loc,1),x(loc,2),'ob'); hold on;
axis square;
title("Identified clusters("+int2str(npts)+","+num2str(time)+")")
saveas(fig, fpath);
hold off;
exit
