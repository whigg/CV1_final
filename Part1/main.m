function main(class, color_space, sift_method, K, no_vocab_images)

run('../Dependencies/vlfeat-0.9.21/toolbox/vl_setup')

% init parameters
if nargin < 1
    class = 'motorbikes';
end
if nargin < 2
    color_space = 'gray';
end
if nargin < 3
    sift_method = 'sift';
end
if nargin < 4
    K = 400;
end
if nargin < 5
    no_vocab_images = 1000;
end

% load (if already created) or create descriptors
file_name = strcat(color_space, '_', sift_method, '_', ...
    int2str(no_vocab_images), '.mat');
if exist(fullfile('descriptors', file_name), 'file')
    d = load(fullfile('descriptors', file_name));
    descriptors = d.descriptors;
    disp('Loaded descriptors.');
else
    descriptors = cat_descriptors(color_space, sift_method, no_vocab_images);
    disp('Created descriptors.');
end
    
% load (if already created) or create visual vocabulary
file_name = strcat('visual_vocab', '_', int2str(K), '_', ...
    color_space, '_', sift_method, '.mat');
if exist(fullfile('vocab', file_name), 'file')
    v = load(fullfile('vocab', file_name));
    visual_vocab = v.visual_vocab;
    disp('Loaded visual vocabulary.');
else
    visual_vocab = visual_vocabulary(descriptors, K, color_space, sift_method);
    disp('Created visual vocabulary.');
end

% load (if already trained) or train SVM model
file_name = strcat('model_', color_space, '_', sift_method, '_', class, '.mat');
if exist(fullfile('models', strcat('vocab_size_', int2str(K)), file_name), 'file')
    m = load(fullfile('models', strcat('vocab_size_', int2str(K)), file_name));
    model = m.model;
    disp('Loaded SVM model.');
else
    model = SVM(class, color_space, sift_method, K, visual_vocab);
    disp('Created SVM model.');
end

% predict on test data using trained model
[ predicted_label, accuracy ] = evaluate(class, color_space, sift_method, K, visual_vocab, model, true);
disp('Finished prediction on test data.')
disp('Predicted labels:')
disp(predicted_label)
disp('Accuracy:')
disp(accuracy)