#FPGA design project for the course "Reti Logiche" of Politecnico di Milano, a.y. 2018/2019 #
The pdf file is an italian version of the official documentation of the project.

##Summary##
This project requires the design of a VHDL component which is able to interface with a RAM memory in order to read the bidimensional coordinates of:
* a reference point;
* 8 centroids;
* an 8-bit string representing the input mask.
The main task of the component is to find the closest centroid to a specified reference point using the Manhattan distance (there could be more than one centroid equidistant from the reference point).
Also, an input mask is specified in order to identify which centroids have to be taken into account:
if the i-ith bit of the mask is set to 1, the i-ith centroid will be taken into account, otherwise, it will not.
After processing the valid centroids, the component will write an 8-bit output mask, which ones represent the closest centroids with respect to the reference point.