
train_image_template = 'DRIVE/Training/images/%02d_training.tif';
train_mask_template = 'DRIVE/Training/mask/%02d_training_mask.gif';
train_truth_template = 'DRIVE/Training/1st_manual/%02d_manual1.gif';

test_image_template = 'DRIVE/Test/images/%02d_test.tif';
test_mask_template = 'DRIVE/Test/mask/%02d_test_mask.gif';
test_truth_template = 'DRIVE/Test/1st_manual/%02d_manual1.gif';

% set to 0 if to ignore out of bound pixels for
% metric calculation, otherwise 1
dontignoreoutofbounds = 0;

if dontignoreoutofbounds == 0
    fprintf('Ignoring out of bound pixels in metric calcualtions\n');
end

for j = 1:2
    
    if j == 1
        image_template = test_image_template;
        mask_template = test_mask_template;
        truth_template = test_truth_template;
    else
        image_template = train_image_template;
        mask_template = train_mask_template;
        truth_template = train_truth_template;
    end
    
    accuracy = zeros([1, 20]);
    sensitivity = zeros([1, 20]);
    specificity = zeros([1, 20]);
    dicescore = zeros([1, 20]);

    for i = 1:20
        filenumber = i + (j - 1) * 20;
        I = im2double(imread(sprintf(image_template, filenumber)));
        Imask = logical(im2double(imread(sprintf(mask_template, filenumber))));
        Itruth = logical(im2double(imread(sprintf(truth_template, filenumber))));

        V = ExtractVessels(I, Imask);
        imshow([im2gray(I), Itruth, V]);

        [accuracy(i), sensitivity(i), specificity(i), dicescore(i)] ...
            = CalculateMetrics(V, Itruth, Imask | dontignoreoutofbounds);
    end
    
    if j == 1
        fprintf('test set:\n');
    else
        fprintf('train set:\n');
    end
    fprintf('accuracy = %f, ', mean(accuracy));
    fprintf('sensitivity = %f, ', mean(sensitivity));
    fprintf('specificity = %f, ', mean(specificity));
    fprintf('dice score = %f\n', mean(dicescore));
    
    disp([accuracy', sensitivity', specificity', dicescore']);
end


function [acc, sens, spec, dice] = CalculateMetrics(I, Truth, Mask)
    tp = sum(sum((I & Truth) & Mask));
    fp = sum(sum((I & ~Truth) & Mask));
    tn = sum(sum((~I & ~Truth) & Mask));
    fn = sum(sum((~I & Truth) & Mask));
    acc = (tp + tn) / (tp + fp + tn + fn);
    sens = tp / (tp + fn);
    spec = tn / (tn + fp);
    dice = 2 * tp / (2 * tp + fp + fn);
end
