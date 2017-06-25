# Poisson-Image-Editing
<h2>Introduction</h2>
In normal cut and paste algorithms,naive methods like feathering are used which do not completely hide the boundaries between
the merged images.Also the saliency of the composite image also gets affected.The algorithms used try minimize the integral of the difference between the
gradient of the source Image and a guidance vector field with boundary conditions.The solution to the obtained equation is a poisson equation.
# How to use
Replace source and destination images in each of the file you are using with the required src and dest images.
<h3>Results</h3>
<h4>Seamless cloning </h4>
<img src="https://github.com/CaptainSharf/Poisson-Image-Editing/blob/master/imgs/Screenshot%20(19).png" width = "800" />
<h4>Mixed gradient cloning</h4>
<img src = "https://github.com/CaptainSharf/Poisson-Image-Editing/blob/master/imgs/Screenshot%20(16).png" width = "800"/>
<h4>Texture flattening</h4>
<img src = "https://github.com/CaptainSharf/Poisson-Image-Editing/blob/master/imgs/Screenshot%20(21).png" width = "800"/>
