/**
 * This sketch opens a stream from the line-in of your computer and performs
 * FFT spectrum analysis on it. The sample sketch draws a simple visualization 
 * but you can modify this code to interact with your arduino using Firmata.
 *
 * (cc) 2015 Luis Rodil-Fernandez for IDA Arnhem
 */
import ddf.minim.*;
import ddf.minim.analysis.*;
 
Minim minim;
AudioInput in;
FFT fft;
int highest=0;
float[] angle;
float[] y, x;
boolean bShowData = false;

void setup()
{
  size(512, 512, P3D);
 
  minim = new Minim(this);
  minim.debugOn();
  
  // use the getLineIn method of the Minim object to get an AudioInput
  in = minim.getLineIn(Minim.MONO, 4096, 44100);
  fft = new FFT(in.left.size(), 44100);
  y = new float[fft.specSize()];
  x = new float[fft.specSize()];
  angle = new float[fft.specSize()];
  frameRate(240);
  
  bShowData = false;
}

void vizualz() {
  noStroke();

  pushMatrix();
  translate(width/2, height/2);
  for (int i = 0; i < fft.specSize() ; i++) {
    y[i] = y[i] + fft.getBand(i)/100;
    x[i] = x[i] + fft.getFreq(i)/100;
    angle[i] = angle[i] + fft.getFreq(i)/2000;
    rotateX(sin(angle[i]/2));
    rotateY(cos(angle[i]/2));
    //    stroke(fft.getFreq(i)*2,0,fft.getBand(i)*2);
    fill(fft.getFreq(i)*2, 0, fft.getBand(i)*2);
    pushMatrix();
    translate((x[i]+50)%width/3, (y[i]+50)%height/3);
    box(fft.getBand(i)/20+fft.getFreq(i)/15);
    popMatrix();
  }
  popMatrix();
}

void draw()
{
  if(!bShowData) {
    background(0);
    fft.forward(in.mix);
    vizualz();
  } else {
    background(0);
    stroke(255);
   
   fft.forward(in.mix);
   
    // draw the waveforms so we can see what we are monitoring
    for(int i = 0; i < in.bufferSize() - 1; i++)
    {
      line( i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50 );
      line( i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50 );
    }
   
    // perform a forward FFT on the samples in jingle's left buffer
    // note that if jingle were a MONO file, 
    // this would be the same as using jingle.right or jingle.left
    fft.forward(in.left);
    for(int i = 0; i < fft.specSize(); i++)
    {
      // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
      line(i, height, i, height - fft.getBand(i)*10);
    }
    fill(128);
    
    String monitoringState = in.isMonitoring() ? "enabled" : "disabled";
    text( "Input monitoring is currently " + monitoringState + ".", 5, 15 );
  }
}
 
void keyPressed()
{
  switch(key) {
    case 'm':
    case 'M':
        if ( in.isMonitoring() )
        {
          in.disableMonitoring();
        }
        else
        {
          in.enableMonitoring();
        }
      break;
    
    case 'd':
    case 'D':
      bShowData = !bShowData;
      break;
  }
  

}
