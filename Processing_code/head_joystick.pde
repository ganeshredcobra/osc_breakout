

import codeanticode.gsvideo.*; 

import monclubelec.javacvPro.*; o
import java.awt.*; // pour classes Point , Rectangle..

PImage img;
Rectangle[] faceRect; 

GSCapture cam; 


OpenCV opencv; 

int widthCapture=320; 
int heightCapture=240;
int fpsCapture=30; 

int millis0=0; // variable mémorisation millis()

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup(){ // fonction d'initialisation exécutée 1 fois au démarrage

        //--- initialise fenêtre Processing 
        size (widthCapture, heightCapture); // crée une fenêtre Processing de la 2xtaille du buffer principal OpenCV
        //size (img.width, img.height); // aalternative en se basant sur l'image d'origine
        frameRate(fpsCapture); // taux de rafraichissement de l'image 

       //---- initialise la webcam ---
       cam = new GSCapture(this, widthCapture, heightCapture,"/dev/video0"); // forme simplifiée
       //cam = new GSCapture(this, widthCapture, heightCapture,"v4l2src","/dev/video0", fpsCapture); // Initialise objet GSCapture désignant webcam - forme complète

        //--- initialise OpenCV ---
	opencv = new OpenCV(this); // initialise objet OpenCV à partir du parent This
        opencv.allocate(widthCapture, heightCapture); // initialise les buffers OpenCv à la taille de l'image
        
      	cam.start();  // démarre objet GSCapture = la webcam 
      
        //-- charge le fichier de description ---        
        //opencv.cascade("FRONTALFACE_ALT", true); // initialise détection de visage 
        opencv.cascade("/usr/local/share/OpenCV/haarcascades/","haarcascade_frontalface_alt.xml"); // utilise chemin absolu Rép + nom fichier
        // supporte chemin absolu avec ou sans / en fin de chaine

  //oscP5 = new OscP5(this, 8000);
  //myRemoteLocation = new NetAddress("127.0.0.1",8000);
  oscP5 = new OscP5(this, 8000);
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
}


void  draw() { // fonction exécutée en boucle

// Code capture GSVideo 


  
  if (cam.available() == true) { // si une nouvelle frame est disponible sur la webcam

        //background(0);  // fond noir entre 2 images 
  
        //------ gestion image webcam par GSCapture ------ 
        cam.read(); // acquisition d'un frame 
        //image(cam1, 0, 0); // affiche image
        //set(0, 0, cam); // affiche image - plus rapide 
  
        //------- gestion image par Opencv ---------- 
  
        img=cam.get(); // récupère l'image GS video dans Pimage

        millis0=millis(); // mémorise millis()  
        opencv.copy(img); // charge l'image GSVideo dans le buffer openCV
        println("Durée chargement buffer OpenCV=" + (millis()-millis0)+"ms."); 
        
        //--- affiche image de départ avant opération sur image ---         
        image(img,0,0); // affiche le buffer principal OpenCV dans la fenêtre Processing

        //--- opérations sur image ---

        millis0=millis(); // mémorise millis()  

        //faceRect = opencv.detect(true); // détection des visages avec messages debug
        faceRect = opencv.detect(3,true); // détection des visages avec coeff vitesse élevée et messages debug
        
        opencv.drawRectDetect(true); // affiche les rectangles détectés avec messages debug
        if(faceRect.length >0){
          float xaxis = (float)(faceRect[0].getX()+faceRect[0].getWidth()/2)/width;
          float yaxis = (float)(faceRect[0].getY()+faceRect[0].getHeight()/2)/height;
          println(yaxis);
          OscMessage myMessage = new OscMessage("/head");
          myMessage.add(xaxis);
          myMessage.add(yaxis);
          oscP5.send(myMessage, myRemoteLocation); 
         /* myMessage = new OscMessage("/jump");
          if (yaxis < 0.45){
            myMessage.add(yaxis);
            oscP5.send(myMessage, myRemoteLocation);
          }*/ 
          
        } 
       // println("Nombre de visages de face détectés =" + faceRect.length + "."); 
 
       
       // println("Durée traitement image par OpenCV=" + (millis()-millis0)+" ms."); 
        
        //--- affiche image finale --- 

        //image(opencv.getBuffer(),widthCapture,0); // affiche le buffer principal OpenCV dans la fenêtre Processing        

  } // fin if available



} // fin draw



