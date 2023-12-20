About this code

This code is intended for the rapid detection of fluorescent cells as described on Guzelsoy, Elorza, et al. 2024. It was written by Spencer Hobson-Gutierrez and Carlos Carmona-Fontaine based on a Matlab implementation of the IDL particle tracking algorithm (https://site.physics.georgetown.edu/matlab/) developed by Daniel Blair and Eric Dufresne. Information about the original IDL algorithm by David Grier, John C. Crocker, and Eric R. Weeks can be found at https://physics.emory.edu/faculty/weeks/idl/index.html.

The IDL algorithm was originally intended for the detection and tracking of stars from telescopic images. We repurposed it for the detection of fluorescent cells. A major advantage of the IDL algorithm is that rather than relying on conventional threshold and segmentation, it detects cells as peaks in a Fourier transformed space. This change dramatically increases detection speed and is makes the detection more robust to differences in fluorescence levels.

On a standard desktop computer or laptop, the image analysis of XX would take XX.

This package contains three main parts:
•	The core image analysis code. This code counts cells in multidimensional images. Fluorescent cell nuclei are ideal for this code to work. A typical input would be a folder with images from timelapses collected at different positions with cells labelled with different fluorophores. This code outputs a table with counts for each channel, position, and timepoint.
•	A GUI to analyze images. A simple graphic user interface that allows opening a sample image and test different parameters for cell detection.
•	A script to produce to plot the data. A script that uses the table produced by the core image analysis code as an input and outputs simple cell counts over time plots. Often data would require more sophisticated or customized plots but this is a good to tool to rapidly overview the data.

1. System requirements:

This code requires a version of Matlab (tested on Ver 8.1 and later versions including Ver 23.2). The code also requires Matlab’s Image Processing Toolbox and Statistics and Machine Learning Toolbox.

There is no specific minimum for computer memory and processing power. However, the size and number of images to be analyzed may impose limitations. No special hardware is required.

2. Installation guide:
Instructions
Typical install time on a "normal" desktop computer

3. Instructions for use:
Install all the files contained on our repository and make sure their path is accessible to Matlab. 
All the files necessary to analyze the images are located in the “image analysis” folder. The file Controller.m opens the GUI that prompts to set three key parameters to count cells on different channels. These parameters are analogous to the original IDL parameters. The first two are used in bpass.m, which is a spatial bandpass filter resulting on a smooter image with lower background. The first parameter (Lnoise) is usually '1'. The second parameter should be close to the diameter of the cell nuclei or the particles you are trying to detect.
The final parameter (Threshold) is required for pkfnd.m which detects cells from the image produced by bpass.m. Thus, the value of ‘Threshold’ will depend on the band-passed image, the pixel depth of your image, and the brightness and signal-to-noise ratio of the original image. The GUI facilitates testing different values of these parameters.

4. Example with Demo data:
A typical experiment where we would use this tool, would include:
•	Fluorescently labelled cells, typically with nuclear YFP. Note that cell culture autofluorescence is dramatically reduced by a YFP filter compared to a GFP filter.
•	Cells seeded on a 96-well plate. We would typically collect 4 timelapses per well and have 3 wells as technical replicates. So, we would have 384 timelapses for 32 different conditions (e.g. different nutrient levels, different cell densities, etc.).
•	Propidium iodide (PI) dissolved in the media. This produces virtually no autofluorescence, but it is incorporated by non-viable cells producing bright red nuclei.
•	Image these cultures every 4-6 hours for 3 to 5 days (~12-30 timesteps).

Download our demo data set.

Controller.m and set parameters for the YFP and Texas Red (PI). Start with Threshold: 600, Size: 8, and Lnoise: 1 for YFP and the same for Size and Lnoise for Texas Red with a Threshold of: 300. Adjust if necessary.
The images can now be analyzed. The run time will depend on the number of images, RAM and CPU, but it usually takes 20-30min on a basic computer. A count matrix that will be generated and stored in a folder named “Edit”. The next step is to plot the data. The file “growth_plots_1” contains the code necessary to generate curve plots from the data stored in the count matrix.
