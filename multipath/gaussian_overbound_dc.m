function [sample_mean, sig_bound, sample_sig, flag]= gaussian_overbound_dc(sample_data, epsilon,Nbins)
    % mean값은 그냥 sample mean이고 cdf overbounding 한 sigma를 output함
    %
    % input
    % sample _data : 샘플 데이터
    % Nbins : 빈 갯수
    %
    % output
    % sample_mean : 그냥 mean
    % sigma_overbound : normalize 해서 cdf overbounding 한 sigma
    % sample_sigma : 그냥 sigma
    
    sample_mean=mean(sample_data);
    sample_sig=std(sample_data);
    
    norm_sample_data=(sample_data-sample_mean)/sample_sig;
    [cdf_sample, edges_sample]=histcounts(norm_sample_data,Nbins,'Normalization','cdf');
    bin_size=edges_sample(2)-edges_sample(1);
    mid_sample=edges_sample(1:end-1)+bin_size/2;
%     idx_posi=find(mid_sample>0);
%     idx_nega=find(mid_sample<0);
    idx_posi=find(cdf_sample>(1-epsilon));
    idx_nega=find(cdf_sample<epsilon);
    
    
    max_std=10;
    min_std=1;
    
    while 1        
        mid_std=(max_std+min_std)/2;
        cdf_norm_mid=normcdf(mid_sample,0,mid_std);
        checksum_mid=sum(cdf_sample(idx_posi)<cdf_norm_mid(idx_posi))+sum(cdf_sample(idx_nega)>cdf_norm_mid(idx_nega));
%         if checksum_mid<0
%             checksum_mid=0;
%         end
        
        if checksum_mid
            min_std=mid_std;
        else
            max_std=mid_std;
        end
        
        
        if (max_std-min_std)<0.001
            if checksum_mid < 2
                flag=0;
                break
            else
                flag=1;
                break
            end
        end
    end
    
    sig_bound=max_std*sample_sig;
   
  

end