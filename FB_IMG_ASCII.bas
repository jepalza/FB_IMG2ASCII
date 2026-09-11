
' para imagescale (de D.J.Peters https://www.freebasic.net/forum/viewtopic.php?t=15819 )
#include "fbgfx.bi"

' para JPG normal, entrelazado (tipico de telefenos moviles) y PNG
#include "SDL2/SDL.bi"
#include "SDL2/SDL_image.bi"
	
' https://www.freebasic.net/forum/viewtopic.php?t=15819
Function ImageScale(s As fb.Image Ptr, Scale as single=1.0) As fb.Image Ptr
  static As fb.Image Ptr t=0
  If s        =0 Then Return 0
  If s->width <1 Then Return 0
  If s->height<1 Then Return 0
  scale=abs(scale)
  dim as integer w = s->width *Scale
  dim as integer h = s->height*Scale
  If w<4 Then w=4
  If h<4 Then h=4
  if t then ImageDestroy(t) : t=0
  t=ImageCreate(w,h)
  Dim As Integer xs=(s->width /t->Width ) * (1024*64)
  Dim As Integer ys=(s->height/t->height) * (1024*64)
  Dim As Integer x,y,sy
  Select Case As Const s->bpp
    Case 4
      Dim As Ulong Ptr ps=cptr(Ulong Ptr,s)+8
      Dim As Uinteger     sp=(s->pitch Shr 2)
      Dim As Ulong Ptr pt=cptr(Ulong Ptr,t)+8
      Dim As Uinteger     tp=(t->pitch Shr 2)-t->width
      For ty As Integer = 0 To t->height-1
        Dim As Ulong Ptr src=ps+(sy Shr 16)*sp
        For tx As Integer = 0 To t->width-1
          *pt=src[x Shr 16]:pt+=1:x+=xs
        Next
        pt+=tp:sy+=ys:x=0
      Next
    Case 2
      Dim As Ushort Ptr ps=cptr(Ushort Ptr,s)+16
      Dim As Uinteger   sp=(s->pitch Shr 1)
      Dim As Ushort Ptr pt=cptr(Ushort Ptr,t)+16
      Dim As Uinteger   tp=(t->pitch Shr 1)-t->width
      For ty As Integer = 0 To t->height-1
        Dim As Ushort Ptr src=ps+(sy Shr 16)*sp
        For tx As Integer = 0 To t->width-1
          *pt=src[x Shr 16]:pt+=1:x+=xs
        Next
        pt+=tp:sy+=ys:x=0
      Next
    Case 1
      Dim As Ubyte Ptr ps=cptr(Ubyte Ptr,s)+32
      Dim As Uinteger   sp=s->pitch
      Dim As Ubyte Ptr pt=cptr(Ubyte Ptr,t)+32
      Dim As Uinteger   tp=t->pitch-t->width
      For ty As Integer = 0 To t->height-1
        Dim As Ubyte Ptr src=ps+(sy Shr 16)*sp
        For tx As Integer = 0 To t->width-1
          *pt=src[x Shr 16]:pt+=1:x+=xs
        Next
        pt+=tp:sy+=ys:x=0
      Next
  End Select
  Return t
End Function


	

' parametros de la imagen
dim as long anchopan,altopan,depth,bpp,pitch

' empezamos con un tamaño normal y luego se adapta
altopan=640
anchopan=480
Screenres altopan, anchopan, 8 ' temporal, luego se cambia segun tamaño de imagen




locate 15,20
color 11:print "Pulsa cualquier tecla para ASCII Color" 
locate 20,20
color 15:Print "Pulsa 'B' para ASCII en Blanco y Negro"
while inkey<>"":wend
dim as string coloreada="C"  ' por defecto en color
dim as string tecla
while 1
	tecla=inkey
	if tecla=chr(27) then end
	if tecla<>"" then tecla=ucase(tecla):exit while
wend
if tecla="B" then coloreada="" ' resto de casos B&N


CLS
DIM as integer grises(256,3)


dim as string fichero
fichero=command

' solo depuracion
if fichero="" then
	dim as string ruta="img\" 
	'fichero=ruta+"mini-yo.jpg"
	fichero=ruta+"prueba.jpg"
	'fichero=ruta+"Donald.bmp"
	'fichero=ruta+"Mona_Lisa.bmp" 
	'fichero=ruta+"skoda.jpg" 
	'fichero=ruta+"micky.bmp" 
	'fichero=ruta+"mijo.jpg" 
	fichero=ruta+"entrelazada.jpg" 
	'fichero=ruta+"gigante.png" 
	'fichero=ruta+"grande.jpg" 
endif


' cojo extension para saber si es BMP o JPG, o PNG
dim as string ext=ucase(mid(fichero,instrrev(fichero,".")+1))


' en caso de JPG o PNG se encarga SDL2
if ext="JPG" orelse ext="PNG" then 
    if (SDL_Init(SDL_INIT_VIDEO) < 0) then
        print "SDL No ha podido iniciarse: "; SDL_GetError()
        sleep:end
    endif
    
    dim as integer imgFlags
	if ext="JPG" then imgFlags = IMG_INIT_JPG
	if ext="PNG" then imgFlags = IMG_INIT_PNG
	 
    if (IMG_Init(imgFlags) and imgFlags)<>imgFlags then
        print "SDL_image no se ha podido iniciar:"; IMG_GetError()
        SDL_Quit()
        sleep:end
    endif

    dim as SDL_Surface ptr loadedSurface = IMG_Load(fichero)
    if loadedSurface = NULL then
        print "No he podido cargar imagen:"; IMG_GetError()
		sleep:end
    'else
        'print "JPG entrelazado cargado. Resolucion:";loadedSurface->w;" x ";loadedSurface->h
	endif

	' puntero a la imagen dentro del "buffer" del SDL
	dim as ubyte ptr pp=loadedSurface->pixels

	'screen 0
	'screeninfo anchopan,altopan,depth,bpp,pitch
	anchopan=loadedSurface->w
	altopan =loadedSurface->h
	'pitch   =loadedSurface->pitch

	' ya sabemos las medidas de la imagen, adapto la pantalla
	screenres anchopan,altopan, 32
	' datos de la "pantalla" (no de la imagen)
	screeninfo ,,depth,bpp,pitch

	' espacio para  traspasar del BUFFER SDL al BUFFER FREEBASIC
	Dim buffer As Any Ptr = ScreenPtr()
	Dim As Long fpp=0

	ScreenLock()
		Dim As Any Ptr row = buffer
		For y As Integer = 0 To altopan - 1
			Dim As ULong Ptr pixel = row
			For x As Integer = 0 To anchopan - 1
				*pixel = RGB(pp[fpp],pp[fpp+1],pp[fpp+2]) 
				fpp+=3 ' JPG RGB
				if ext="PNG" then fpp+=1 ' el PNG emplea 4 bytes (RGBA)
				pixel += 1
			Next x
			row += pitch
		Next y
	ScreenUnlock()

    SDL_FreeSurface(loadedSurface)

    IMG_Quit()
    SDL_Quit()
	
elseif ext="BMP" then
	' abro el BMP para ver sus medidas previamente
    Open fichero For Binary Access Read As 1
		Get #1, 19, anchopan
		Get #1, 23, altopan
    Close 1
	screenres anchopan,altopan,32
	bload fichero,0
else
	print "Solo puedo cargar extensiones BMP,PNG o JPG":sleep:end
endif





' factor de escala para pantallas SOLO FULLHD 1920x1080, para no liarme mucho
' deshabilitar para que use tamaño original, que funciona bien, pero salen fotos ENORMES
#if 1
	' factor de escala para adaptar a un maximo de 1920x1080 clasico
	dim as single escala=1
	dim as single escala_ancho=0,escala_alto=0
	if (anchopan>1920) then
		if anchopan>1920 then escala_ancho=1920/anchopan
	end if
	if (altopan>1080) then
		if altopan>1080 then escala_alto=1080/altopan
	end if
	if escala_ancho<escala_alto then escala=escala_ancho else escala=escala_alto
	if escala_ancho=0 then escala=escala_alto ' para imagenes cuadradas
	if escala>0.0001 then
		dim as fb.image ptr pp2=imagecreate(anchopan,altopan)
		get (0,0)-(anchopan-1,altopan-1),pp2
		cls:pp2=ImageScale(pp2,escala)
		imageinfo pp2,anchopan,altopan
		screenres anchopan,altopan,32
		put (0,0),pp2
		imagedestroy(pp2)
	endif
#endif






' ... y ahora.... la MAGIA
' nota: la rutina basica es de un ejemplo de RFO-BASIC ( Aat Don @2013 )
'       muy retocada para adaptarse a FREEBASIC
dim as integer yP,YSt
dim as integer xP,XSt
dim as integer iP,jP
dim as integer xR,yR

' medidas del caracrer, uso solo el estandar 8x8
dim as integer anchochar=8 
dim as integer altochar=8

xP=anchopan
xSt=anchochar

yP=altopan
ySt=altochar

jP=(anchochar-1)
iP=(altochar-1)

xR=anchochar
yR=altochar

dim as integer numorden ' no vale para nada, solo para saber su numero de orden
FOR i as integer=1 TO 256
	read numorden,grises(i,1),grises(i,2),grises(i,3)
NEXT i

dim as integer AvgR,AvgG,AvgB
dim as integer i,j,a,r,g,b
dim as integer q
dim as ULONG p,COLORS
FOR y as integer =0 TO yP STEP YSt
	FOR x as integer =0 TO xP STEP XSt
		AvgR=0
		AvgG=0
		AvgB=0
		q=0
		FOR j=y TO y+jP
			FOR i=x TO x+iP
				p=point (i,j)
				a=255' siempre 255? (p shr 24) and 255
				r=(p shr 16) and 255
				g=(p shr  8) and 255
				b=p and 255
				AvgR=(q*AvgR+r)/(q+1)
				AvgG=(q*AvgG+g)/(q+1)
				AvgB=(q*AvgB+b)/(q+1)
				q=q+1
			NEXT i
		NEXT j
		dim as ULong GV=int((AvgR+AvgG+AvgB)/3)
		' identifica caracteres segun la tabla ASCII
		' primero, el color del recuadro de fondo
		IF grises(GV+1,3)=1 THEN
			COLORS= rgba(0,0,0,255) ' negro 100%
		ELSE
			COLORS= rgba(255,255,255,255) ' blanco 100%
		ENDIF
		line (x,y)-(x+xR-1,y+yR-1),COLORS ,bf

		' ahora, el color del caracter
		IF coloreada="C" THEN
			COLORS= rgba(AvgR,AvgG,AvgB,255)
		ELSE
			a=grises(GV+1,2)
			IF grises(GV+1,3)=1 THEN
				'COLORS= rgba(255,255,255,a)
				COLORS= rgb(a,a,a) ' blanco predominante
			ELSE
				'COLORS= rgba(0,0,0,a)
				a=255-a ' intento de que sea negro predominante 
				COLORS= rgb(a,a,a)
			ENDIF
		ENDIF
		DRAW String (x,y),CHR(grises(GV+1,1)),COLORS
	NEXT x
NEXT Y


' ya tenemos imagen ASCII. pasamos a guardar en formato BMP
a=instrrev(fichero,".")
fichero=left(fichero,a-1)+"_ASC.BMP"
bsave fichero,0 ' el "0" final indica guardar el buffer de pantalla actual que vemos

beep
sleep
end

' tabla de caracteres ASCII y su tonos (original de ( Aat Don @2013 ))
'   GV,ASCII,alpha,Invert
Data 0,32,255,1
Data 1,183,25,1
Data 2,183,50,1
Data 3,183,75,1
Data 4,183,100,1
Data 5,183,125,1
Data 6,183,150,1
Data 7,183,175,1
Data 8,183,185,1
Data 9,183,200,1
Data 10,183,225,1
Data 11,183,255,1
Data 12,96,180,1
Data 13,96,200,1
Data 14,96,220,1
Data 15,96,235,1
Data 16,96,255,1
Data 17,58,195,1
Data 18,58,200,1
Data 19,58,220,1
Data 20,58,235,1
Data 21,58,255,1
Data 22,185,200,1
Data 23,185,210,1
Data 24,185,220,1
Data 25,185,230,1
Data 26,185,240,1
Data 27,185,255,1
Data 28,126,210,1
Data 29,126,220,1
Data 30,126,230,1
Data 31,126,235,1
Data 32,126,255,1
Data 33,60,220,1
Data 34,60,225,1
Data 35,60,230,1
Data 36,60,235,1
Data 37,60,255,1
Data 38,43,220,1
Data 39,43,223,1
Data 40,43,230,1
Data 41,43,235,1
Data 42,43,255,1
Data 43,187,220,1
Data 44,187,225,1
Data 45,187,230,1
Data 46,187,235,1
Data 47,187,239,1
Data 48,187,255,1
Data 49,99,223,1
Data 50,99,230,1
Data 51,99,235,1
Data 52,99,240,1
Data 53,99,255,1
Data 54,42,230,1
Data 55,42,232,1
Data 56,42,235,1
Data 57,42,240,1
Data 58,42,255,1
Data 59,120,231,1
Data 60,120,233,1
Data 61,120,235,1
Data 62,120,238,1
Data 63,120,240,1
Data 64,120,255,1
Data 65,89,232,1
Data 66,89,233,1
Data 67,89,235,1
Data 68,89,239,1
Data 69,89,255,1
Data 70,101,232,1
Data 71,101,233,1
Data 72,101,235,1
Data 73,101,240,1
Data 74,101,255,1
Data 75,83,232,1
Data 76,83,233,1
Data 77,83,235,1
Data 78,83,239,1
Data 79,83,240,1
Data 80,83,255,1
Data 81,72,232,1
Data 82,72,235,1
Data 83,72,239,1
Data 84,72,240,1
Data 85,72,255,1
Data 86,88,231,1
Data 87,88,235,1
Data 88,88,239,1
Data 89,88,240,1
Data 90,88,255,1
Data 91,109,232,1
Data 92,109,235,1
Data 93,109,238,1
Data 94,109,239,1
Data 95,109,240,1
Data 96,109,255,1
Data 97,65,235,1
Data 98,65,238,1
Data 99,65,239,1
Data 100,65,240,1
Data 101,65,255,1
Data 102,79,236,1
Data 103,79,237,1
Data 104,79,238,1
Data 105,79,255,1
Data 106,37,224,1
Data 107,37,225,1
Data 108,37,230,1
Data 109,37,231,1
Data 110,37,232,1
Data 111,37,233,1
Data 112,37,235,1
Data 113,37,238,1
Data 114,37,239,1
Data 115,37,240,1
Data 116,37,255,1
Data 117,77,255,0
Data 118,77,240,0
Data 119,77,240,0
Data 120,77,240,0
Data 121,77,240,0
Data 122,64,255,0
Data 123,64,240,0
Data 124,64,239,0
Data 125,64,238,0
Data 126,64,236,0
Data 127,64,235,0
Data 128,169,255,0
Data 129,169,239,0
Data 130,169,238,0
Data 131,169,237,0
Data 132,169,235,0
Data 133,87,255,0
Data 134,87,239,0
Data 135,87,238,0
Data 136,87,237,0
Data 137,87,235,0
Data 138,37,255,0
Data 139,37,240,0
Data 140,37,239,0
Data 141,37,238,0
Data 142,37,235,0
Data 143,37,233,0
Data 144,37,232,0
Data 145,37,231,0
Data 146,37,230,0
Data 147,37,225,0
Data 148,37,224,0
Data 149,79,255,0
Data 150,79,238,0
Data 151,79,237,0
Data 152,79,236,0
Data 153,79,235,0
Data 154,65,255,0
Data 155,65,240,0
Data 156,65,239,0
Data 157,65,238,0
Data 158,65,235,0
Data 159,109,255,0
Data 160,109,240,0
Data 161,109,239,0
Data 162,109,238,0
Data 163,109,235,0
Data 164,109,232,0
Data 165,88,255,0
Data 166,88,240,0
Data 167,88,239,0
Data 168,88,235,0
Data 169,88,231,0
Data 170,72,255,0
Data 171,72,240,0
Data 172,72,239,0
Data 173,72,235,0
Data 174,72,232,0
Data 175,83,255,0
Data 176,83,240,0
Data 177,83,239,0
Data 178,83,235,0
Data 179,83,233,0
Data 180,83,232,0
Data 181,101,255,0
Data 182,101,240,0
Data 183,101,235,0
Data 184,101,233,0
Data 185,101,232,0
Data 186,89,255,0
Data 187,89,239,0
Data 188,89,235,0
Data 189,89,233,0
Data 190,89,232,0
Data 191,120,255,0
Data 192,120,240,0
Data 193,120,238,0
Data 194,120,235,0
Data 195,120,233,0
Data 196,120,231,0
Data 197,42,255,0
Data 198,42,240,0
Data 199,42,235,0
Data 200,42,232,0
Data 201,42,230,0
Data 202,99,255,0
Data 203,99,240,0
Data 204,99,235,0
Data 205,99,230,0
Data 206,99,223,0
Data 207,187,255,0
Data 208,187,239,0
Data 209,187,235,0
Data 210,187,230,0
Data 211,187,225,0
Data 212,187,220,0
Data 213,43,255,0
Data 214,43,235,0
Data 215,43,230,0
Data 216,43,223,0
Data 217,43,220,0
Data 218,60,255,0
Data 219,60,235,0
Data 220,60,230,0
Data 221,60,225,0
Data 222,60,220,0
Data 223,126,255,0
Data 224,126,235,0
Data 225,126,230,0
Data 226,126,220,0
Data 227,126,210,0
Data 228,185,255,0
Data 229,185,240,0
Data 230,185,230,0
Data 231,185,220,0
Data 232,185,210,0
Data 233,185,200,0
Data 234,58,255,0
Data 235,58,235,0
Data 236,58,220,0
Data 237,58,200,0
Data 238,58,195,0
Data 239,96,255,0
Data 240,96,235,0
Data 241,96,220,0
Data 242,96,200,0
Data 243,96,180,0
Data 244,183,255,0
Data 245,183,225,0
Data 246,183,200,0
Data 247,183,185,0
Data 248,183,175,0
Data 249,183,150,0
Data 250,183,125,0
Data 251,183,100,0
Data 252,183,75,0
Data 253,183,50,0
Data 254,183,25,0
Data 255,32,255,0
