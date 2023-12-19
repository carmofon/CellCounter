About this code
This code as described on Guzelsoy, Elorza, et al. 2024.
It is based on the IDL implementation. 

This version was optimized for cell detection, and it was written by Spencer Hobson-Gutierrez and Carlos Carmona-Fontaine.
This package contains three main parts:
•	The core image analysis code. This code counts cells in multidimensional images. Fluorescent cell nuclei are ideal for this code to work. A typical input would be a folder with images from timelapses collected at different positions with cells labelled with different fluorophores. This code outputs a table with counts for each channel, position, and timepoint.
•	A GUI to analyze images. A simple graphic user interface that allows opening a sample image and test different parameters for cell detection.
•	A script to produce to plot the data. A script that uses the table produced by the core image analysis code as an input and outputs simple cell counts over time plots. Often data would require more sophisticated or customized plots but this is a good to tool to rapidly overview the data.

1. System requirements:

This code requires a version of Matlab (tested on Ver 8.1 and later versions including Ver 23.2). The code also requires Matlab’s Image Processing Toolbox and Statistics and Machine Learning Toolbox.

There is no specific minimum for computer memory and processing power. However, the size and number of images to be analyzed may impose limitations.

2. Installation guide:
Instructions
Typical install time on a "normal" desktop computer

3. Demo:
Instructions to run on data

4. Instructions for use:
How to run the software on your data
(OPTIONAL) Reproduction instructions
We encourage you to include instructions for reproducing all the quantitative results in the manuscript
