pkg load image

# USES PACKAGE: http://www1.idc.ac.il/toky/videoProc-07/projects/SuperRes/srproject.html
# Note:
# Every line cmd that has ";" at the end, will not display
# its content on the Terminal Output. Every line without will.
# Really annoying if you read a 160x240 big image and and you 
# can see every, single, element (Octave doesn't truncat an 
# Matrix output like Numpy in Python does).
 
# Settings. This is the Playarea
#
# res_factor    - scaling factor
# psfSig        - Gaussian Sigma Value
# psfSize       - Gaussian Kernel Size
#
# alpha         - See "GradientRegulization.m"
# beta          - "learning" rate in the minimazation
# lambda        - "learning" rate two
# P             - Speical Window Size. See "GradientRegulization.m"
# maxItr        - maximum iterations for minimazation approach 
#                 (you could also stop if the change is not so big anymore -> faster)
# 
# amount_img    - amount of images inside the "img" folder, that
#                 are named ""%d.png"
res_factor = 2
psfSig = 3
psfSize = 3

props.alpha = 0.7;
props.beta = 1;
props.lambda = 0.04;
props.P = 1;
props.maxIter = 50

amount_img = 30

### END - Plazarea

Hpsf = fspecial('gaussian', [psfSize psfSize], psfSig);


# Adds the all files (LKOFlow/*.m) under the path LKOFlow
# to the import dir. Octave & Matlab will execute cmd, without
# having a user import statement. A bit like Java. 
addpath("LKOFlow/")

# Define my LR image array
LR = []
# Because this definition is praticly not an empty definition,
# but if I add an element, the first elment (index: 1) of the 
# array LR will be filled with 0zeros after the shape of the
# added element (LR(:,:,end+1) = X; would add a new frame)
aI = 1

# Read every image. Because I was to bored to actually
# get the amount of images with code, I declared it to
# a users job.
for i = 1:amount_img
    img = imread( strcat("img/", num2str(i), ".png")); # Read image
    img = rgb2gray(img); # Convert to RGB image
    LR(:,:,aI++) = img; # Add Image to LR
end

# This method is declared inside "LKOFlow/RegisterImageSeq.m"
# Read description inside the source file.
D = RegisterImageSeq(LR);

# Round displacement to use it for acutal pixel translation. 
D=round(D.*res_factor);

% Shift all images so D is bounded from 0-resFactor
# Copied from the SRDemo.m file (Can't be used, because
# of GUI related functions, that are missing in Matlab.)
Dr=floor(D/res_factor);
D=mod(D,res_factor)+res_factor;
[X,Y]=meshgrid(1:size(LR, 2), 1:size(LR, 1));
for i=1:size(LR, 3)
  LR(:,:,i)=interp2(X+Dr(i,1), Y+Dr(i,2), LR(:,:,i), X, Y, '*nearest');
end

# This is the acutall piece of code. Here I begin to the
# the actual processing.
HR = FastRobustSR(LR(3:end-2,3:end-2,:), D,res_factor, Hpsf, props);

# Print the min and max to the user
size(HR), max(max(HR)), min(min(HR))
# Trim the image to 0...1 range. Because this line returns
# a float value the imwrite method will assume, that the image
# values are decimals and will use the color in the range 0...1.
# This saves me the extra "*255" in "HR/max(max(HR))*255"
out = HR/max(max(HR));

# Save image
imwrite(out, "img/out/out.png")