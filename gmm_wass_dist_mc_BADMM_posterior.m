function [ fval, matching ] = gmm_wass_dist_mc_BADMM_posterior( gmm1,gmm2,sample_size )



    [X,~]=gmm1.rndlist_complist_gen(sample_size);
    [Y,~]=gmm2.rndlist_complist_gen(sample_size);

    n = size(X,2);
    m = size(Y,2);
    
    wX=ones(1,n);
    wY=ones(1,m);
    
    D = pdist2(X', Y', 'sqeuclidean');
    if (sample_size < 500)
        [~, x] = OptimalTransport_IBP_Sinkhorn(D, wX', wY',2.*mean(D(:)) / 100,300);
    else
        [~, x] = OptimalTransport_BADMM(D,wX',wY',2.*mean(D(:)),300);
    end
    X_softmembership=gmm1.softmembership(X);
    Y_softmembership=gmm1.softmembership(Y);
    
    matching=X_softmembership*x*Y_softmembership';
    %% Iterates to conform the matching matrix with the following constraints:
    %       sum(matching(i,:))=gmm1.weights(i)
    %       sum(matching(:,j))=gmm2.weights(j)
%     ITER=100;
%     for i=1:ITER
%         matching=normalize_row(matching,(sum(matching,2)+eps)'./gmm1.weights);
%         matching=normalize_col(matching,(sum(matching,1)+eps)./gmm2.weights);
% %         matching=bsxfun(@times,matching,1./sum(matching,2)'.*gmm1.weights));
% %         matching=bsxfun(@times,matching,1./sum(matching,1)./gmm2.weights)');
%     end
%     [~,matching]=OptimalTransport_IBP_Sinkhorn(matching, gmm1.weights', gmm2.weights', 1., 100);
    fval=gmm_wass_dist_naive_withmatchinginput(gmm1,gmm2,matching);
end