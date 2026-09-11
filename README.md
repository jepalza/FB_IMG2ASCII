# FB_IMG2ASCII
Freebasic conversor de imagenes BMP,PNG,JPG a texto ASCII  

Un conversor entre formatos de imagen BMP, PNG y JPG (normales y entrelazados) a un formato con caracteres ASCII coloreados o blanco y negro.  

Los BMP los lee de forma nativa con FreBasic BLOAD y la salida final se hace en formato BMP con BSAVE. Los otros dos formatos (PNG,JPG) los lee mediante SDL2_IMAGE, por lo que son necesarias las DLL de SDL2 y SD2_IMAGE.  

El programa lee cualquier tamaño de imagen, y la convierte al mismo tamaño de entrada, pero he incluido una rutina que puede o no emplearse para escalar la imagen a un tamaño mas adecuado, tipico 1920x1080 máximo, para no perjudicar la visualizion. Si se quiera la salida al mismo tamaño, ocultar la linea de escalado que está en el código fuente.  

La rutina de escalado es originaria de D.J.Peters en el foro Freebasic (ver código para saber dónde), y la rutina de conversión a ascii es del foro RFO-BASIC (igualmente, en el coódigo indico su autor original).  

![img1](https://github.com/jepalza/FB_IMG2ASCII/blob/main/img/img1.jpg)
![img2](https://github.com/jepalza/FB_IMG2ASCII/blob/main/img/img2.bmp)
![img3](https://github.com/jepalza/FB_IMG2ASCII/blob/main/img/img3.bmp)
