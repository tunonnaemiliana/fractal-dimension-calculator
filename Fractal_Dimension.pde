//Variables//Edge Detection//Variables//
PImage img,imgGray,imgBlur,sobelX,sobelY,sobelMagnitude;
boolean start=false;
int matrixsize = 3;

final int BLURS = 0;
final color FILTER = color(192,192,192);

float[][] gaussianBlurKernel={
                             { 0.0625, 0.125, 0.0625 },
                             { 0.125, 0.25, 0.125 },
                             { 0.0625, 0.123, 0.0625 }
                             };
float[][]sobelOperatorX={
                        { -1, 0, 1 },
                        { -2, 0, 2 },
                        { -1, 0, 1 }
                        };
float[][]sobelOperatorY={
                        { -1, -2, -1 },
                        { 0, 0, 0 },
                        { 1, 2, 1 }
                        };

//Variables//Nearest Neightnour and Box Counting Algorythm//Variables//
final int DATASET_SIZE = 16;

PImage fractal;
float[] dataset_boxes = new float[DATASET_SIZE];
float[] dataset_scaling_factors = new float[DATASET_SIZE];

//Varibles//Computing the Fractal Dimension//Variables//
float m = 1;
float q = 0;


void setup(){
  //fullScreen(2);
  size(2048,2048);
  selectInput("Seleziona immagine","imageAssigner");
  while(!start){
    println();
  }
  noSmooth();
}

void imageAssigner(File selection){
  String h = selection.getAbsolutePath();
  img = loadImage(selection.getAbsolutePath());
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
  }
  start=true;
}

void draw(){
  //Start//Edge Detection//Start//

  img.filter(GRAY);
  img.save("1-imgGray.jpg");
  
  imgGray = loadImage("1-imgGray.jpg");
    
  int xstart = 0;
  int ystart = 0;
  int xend = imgGray.width;
  int yend = imgGray.height;
    
  for(int i = 0; i<BLURS; i++){
    for (int x = xstart; x < xend; x++) {
      for (int y = ystart; y < yend; y++ ) {
        color c = convolution(x, y, gaussianBlurKernel, matrixsize, imgGray);
        int loc = x +y*imgGray.width;
        imgGray.pixels[loc] = c;
      }
    }
  }
  
  imgGray.save("2-imgBlur.jpg");
  
  sobelX=loadImage("2-imgBlur.jpg");
  image(sobelX, 0, 0);
  
  loadPixels();
  for (int x = xstart; x < xend; x++) {
    for (int y = ystart; y < yend; y++ ) {
      color c = convolution(x, y, sobelOperatorX, matrixsize, sobelX);
      int loc = x + y*width;
      pixels[loc] = c;
    }
  }
  updatePixels();
    
  sobelX = get(0,0,sobelX.width,sobelX.height);
  sobelX.save("3-sobelX.jpg");
  
  background(0);
  sobelY=loadImage("2-imgBlur.jpg");
  image(sobelY, 0, 0);
    
  loadPixels();
  for (int x = xstart; x < xend; x++) {
    for (int y = ystart; y < yend; y++ ) {
      color c = convolution(x, y, sobelOperatorY, matrixsize, sobelY);
      int loc = x + y*width;
      pixels[loc] = c;
    }
  }
  updatePixels();
    
  sobelY = get(0,0,sobelY.width,sobelY.height);
  sobelY.save("4-sobelY.jpg");
  
  //background(0);
  sobelX = loadImage("3-sobelX.jpg");
  sobelY = loadImage("4-sobelY.jpg");
  sobelMagnitude = loadImage("3-sobelX.jpg");
  
  for (int x = xstart; x < xend; x++) {
    for (int y = ystart; y < yend; y++ ) {
      color c = 0;
      int loc = x + y*sobelMagnitude.width;
      sobelMagnitude.pixels[loc] = c;
    }
  }

  //background(0);
  
  loadPixels();
  for (int x = xstart; x < xend; x++) {
    for (int y = ystart; y < yend; y++ ) {
      int loc = x + y*sobelX.width;
      
      if(sobelX.pixels[loc]<=FILTER)//metà sarebbe -8388608
        sobelX.pixels[loc] = #000000;
      else
        sobelX.pixels[loc] = #FFFFFF;
      
      if(sobelY.pixels[loc]<=FILTER)//metà sarebbe -8388608
        sobelY.pixels[loc] = #000000;
      else
        sobelY.pixels[loc] = #FFFFFF;
        
      //pixels[loc] = Math.round(sqrt(pow(sobelX.pixels[loc],2) + pow(sobelY.pixels[loc],2)));
      //pixels[loc] = sobelX.pixels[loc] + sobelY.pixels[loc];
        
      sobelMagnitude.pixels[loc] = sobelX.pixels[loc] + sobelY.pixels[loc];
    }
  }
  updatePixels();
  
  sobelX.save("6-sobelX-debug.jpg");
  sobelY.save("7-sobelY-debug.jpg");
  sobelMagnitude.save("5-LivingOnTheEdge.jpg");  
    
  //End//Edge Detection//End//
  
  //Start//Scaling and Box Counting Algorythm//Start//
  
  fractal=loadImage("5-LivingOnTheEdge.jpg");
  fractal.save("8-ScaledFractal.jpg");
  
  for(int i=0; i<DATASET_SIZE; i++){ //<>//
    Scale(i,fractal,DATASET_SIZE);
    dataset_boxes[i] = countBoxes();
    println("[",i,"] = ",countBoxes());
  }
  
  //End//Scaling//End//
  
  //Start//Computing the Fractal Dimension//Start// //<>//
  pushMatrix();
  rotate(PI/2);
  translate(-width/2,height/2);
  for(int i = 0; i < DATASET_SIZE; i++){
    dataset_scaling_factors[i] = log(dataset_scaling_factors[i]);
    dataset_boxes[i] = log(dataset_boxes[i]);
  }
  background(51);  
  Normalize(); //<>//
  for(int i = 0; i < dataset_scaling_factors.length; i++){
    float x = map(dataset_scaling_factors[i], 0, 1, 0, width);
    float y = map(dataset_boxes[i], 1, 0, 0, height);
    fill(255);
    stroke(255);
    ellipse(x,y,8,8);
  }
  
  linearRegression(dataset_scaling_factors,dataset_boxes);
  drawLine();
  popMatrix();
  println("the dimension of the fractal is : ",m);
  exit();
   //End//Computing The Fractal Dimension//End//
}
  
 



//functions//Edge Detection//functions//

color convolution(int x, int y, float[][] matrix, int matrixsize, PImage img){
  float rtotal = 0.0;
  float gtotal = 0.0;
  float btotal = 0.0;
  int offset = matrixsize / 2;
  for (int i = 0; i < matrixsize; i++){
    for (int j= 0; j < matrixsize; j++){
      int xloc = x+i-offset;
      int yloc = y+j-offset;
      int loc = xloc + img.width*yloc;
      loc = constrain(loc,0,img.pixels.length-1);
      rtotal += (red(img.pixels[loc]) * matrix[i][j]);
      gtotal += (green(img.pixels[loc]) * matrix[i][j]);
      btotal += (blue(img.pixels[loc]) * matrix[i][j]);
    }
  }
  rtotal = constrain(rtotal, 0, 255);
  gtotal = constrain(gtotal, 0, 255);
  btotal = constrain(btotal, 0, 255);
  return color(rtotal, gtotal, btotal);
}

//functions//Scaling and Box Counting Algorythm//functions//

void Scale(int iteration, PImage image,int dataset){
  float scalingFactor;
  
  if(image.width >= image.height){
    float lengthDifference = height - image.height;
    float increment = iteration*lengthDifference/dataset;
    float supposedLenght = image.height + increment;
    scalingFactor = supposedLenght/image.height;
    println(supposedLenght/image.height);
  }
  else if(image.width < image.height){
    int lengthDifference = width - image.width;
    int increment = iteration*lengthDifference/dataset;
    int supposedLenght = image.width + increment;
    scalingFactor = supposedLenght/image.width;
  }
  else if(image.width == width){
    scalingFactor = 0.9;
  }
  else{
    scalingFactor = 1.0;
  }
  dataset_scaling_factors[iteration] = scalingFactor;
  pushMatrix();
  scale(scalingFactor);
  background(0);
  image(image,0,0);
  popMatrix();
};

int countBoxes(){
  loadPixels();
  int counter = 0;
  for(int i = 0; i < width; i++){
    for(int j = 0; j < height; j++){
      int loc = i + j*width;
      if(pixels[loc] == #FFFFFF)
        counter++;
    }
  }
  updatePixels();
  return counter;
}

//Functions//Computing the Fractal Dimension//Functions//
void drawLine(){
  float x1 = 0;
  float y1 = m * x1 + q;
  float x2 = 1;
  float y2 = m * x2 + q;
  
  x1 = map(x1, 0, 1, 0, width);
  y1 = map(y1, 0, 1, height, 0);
  x2 = map(x2, 0, 1, 0, width);
  y2 = map(y2, 0, 1, height, 0);
  
  stroke(255,0,255);
  line(x1,y1,x2,y2);
}

void linearRegression(float[] dataX, float[] dataY){
  float xsum = 0;
  float ysum = 0;
  for(int i = 0; i < dataX.length; i++){
    xsum += dataX[i];
    ysum += dataY[i];
  }
  float xmean = xsum / dataX.length;
  float ymean = ysum / dataX.length;

  float num = 0; //numerator
  float den = 0; //denominator

  for(int i = 0; i < dataX.length; i++){
    float x = dataX[i];
    float y = dataY[i];

    num += (x - xmean) * (y - ymean);
    den += (x - xmean) * (x - xmean);
  }
  m = num / den;
  q = ymean - m * xmean;
}

void Normalize(){
  float minX = dataset_scaling_factors[0];
  float maxX = dataset_scaling_factors[dataset_scaling_factors.length - 1];
  float minY = dataset_boxes[0];
  float maxY = dataset_boxes[dataset_boxes.length - 1];
  
  for(int i = 0; i < dataset_scaling_factors.length; i++){
    dataset_scaling_factors[i] = map(dataset_scaling_factors[i],minX,maxX,0,1);
  }
  for(int i = 0; i < dataset_boxes.length; i++){
    dataset_boxes[i] = map(dataset_boxes[i],minY,maxY,0,1);
  }
}
