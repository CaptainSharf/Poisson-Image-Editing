# Poisson-Image-Editing
<h2>Introduction</h2>
In normal cut and paste algorithms,naive methods like feathering are used which do not completely hide the boundaries between
the merged images.Also the saliency of the composite image also gets affected.The algorithms used try minimize the integral of the difference between the
gradient of the source Image and a guidance vector field with boundary conditions.The solution to the obtained equation is a poisson equation.
<h2>How to use</h2>
Replace source and destination images in each of the file you are using with the required src and dest images
#Results
## Seamless cloning
<img src="https://github.com/CaptainSharf/Poisson-Image-Editing/blob/master/imgs/Screenshot%20(19).png" width = "800" />
<h2>Mixed gradient cloning</h2>
<img src = "https://github.com/CaptainSharf/Poisson-Image-Editing/blob/master/imgs/Screenshot%20(16).png" width = "800"/>
<h2>Texture flattening</h2>
<img src = "https://github.com/CaptainSharf/Poisson-Image-Editing/blob/master/imgs/Screenshot%20(21).png" width = "800"/>
