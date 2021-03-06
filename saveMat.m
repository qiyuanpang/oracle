close all;
startup;

sizes = [50000000]
%sizes = [5000000]
kwant = 4
repeat = 1;
what = "abs"

% parameters for Chebyshev-Davidson method
m = 9;
tau = 1e-6
itermax = 200
opts = struct('polym', m, 'tol', tau, 'itmax', itermax, 'chksym', 1, 'nomore', 1);

% parameters for Coordinate-wise Descent
stepsize = 0.1
w = 0
alpha = 0.9

%ncores = 34
%parpool(ncores, 'IdleTimeout', 360);
for n_samples = sizes
    % n_samples = 5000
    fprintf("\n\n")
    fprintf("========================= #samples = %10d ============================\n", n_samples)
    fname = "sparsedata/" + "sparse"  + num2str(n_samples) + "/sparse" + num2str(n_samples) + ".json"; 
    fid = fopen(fname, 'r'); 
    raw = fread(fid, inf); 
    str = char(raw');     
    
    tic;
    A = sparseSim(str, n_samples, what);
    %A = (A+A')/2;
    toc
    
    savefile = "sparsedata/" + "sparse" + num2str(n_samples) + "/sparse" + num2str(n_samples) + what  + ".mat";
    save(savefile, 'A', '-v7.3');
    fprintf("%s saved! \n", savefile);
end

exit
