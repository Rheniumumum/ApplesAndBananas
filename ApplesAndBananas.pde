import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;

Capture cap;
OpenCV opencv;
Rectangle[] faces;
PImage basket,apple,banana,heart;
PImage oimg;
PFont font;
float px, py;//自機の左上のx座標とy座標
int oy[] = new int[10]; //降ってくる物体を割り当てる用
int oType[] = new int[10]; //appleかbananaかを決める
int oTime[] = new int[10]; //降ってくる物体の待ち時間を決める
float pw, ph, ow, oh, hw, hh;
int score;
int hp;
int gameManager;

void setup() {
  size(1280, 960);
  font = loadFont("data/AgencyFB-Bold-48.vlw");
  textFont(font);
  textAlign(CENTER);
  gameManager = 0;
  String[] cameras = Capture.list();
  while (cameras.length == 0) {
    cameras = Capture.list();
  }
  cap = new Capture(this, width, height, cameras[0]); 
  cap.start(); 
  frameRate(30);
  basket = loadImage("image/basket.png");
  apple = loadImage("image/apple.png");
  banana = loadImage("image/banana.png");
  heart = loadImage("image/heart.png");
  pw = basket.width;
  ph = basket.height;
  ow = apple.width*0.8;
  oh = apple.height*0.8;
  hw = heart.width*0.4;
  hh = heart.height*0.4;
  for(int i=0;i<10;i++){
    objectInit(i);
  }
  score = 0;
  hp = 5;
}

void captureEvent(Capture cap) {
  cap.read();
}

void player(float x,float y){
  image(basket,x,y);
}

void objectInit(int i){
  oy[i] = 60;
  oType[i] = int(random(2));
  oTime[i] = int(random(1,40));
}

void hit(){
  int ox;
  for(int i=0;i<10;i++){
    ox = i*128+5;
    if((px < (ox+pw)) && ((px+pw) > ox) && (py < (oy[i]+oh) && (py+ph) > oy[i])){
      if(oType[i] == 0){ //appleに衝突した時
        score += 20;
      }else{ //bananaに衝突した時
        hp--;
      }
      objectInit(i);
    }
  }
}

void objectDisp(){
  for(int i=0;i<10;i++){
    if(oType[i] == 0){
      oimg = apple;
    }else{
      oimg = banana;
    }
    image(oimg,i*128+5,oy[i],ow,oh);
  }
}

void objectMove(){
  for(int i=0;i<10;i++){
    if(oTime[i] > 0){
      oTime[i]--;
    }else{
      oy[i] += 20;
    }
    if(oy[i] > height){
      objectInit(i);
    }
  }
}

void scoreDisp(){
  textSize(40);
  fill(255);
  text("score:" + score, 70,50);
  text("hp:",220,50);
  for(int i=0;i<hp;i++){
    image(heart,250+i*hw,15,hw,hh);
  }
}

void gameStanby(){
  textSize(150);
  text("Apples and Bananas",width/2, height/2-50);
  textSize(90);
  if(frameCount/10 % 2 != 0){
    text("click to start !",width/2, height/2+150);
  }
  if(mousePressed == true){
    gameManager = 1;
  }
}
void gamePlay(){
  //image(cap, 0, 0); //カメラ表示用
  opencv = new OpenCV(this, cap);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  faces = opencv.detect();
  for(int i=0;i<faces.length;i++){
    px = width - faces[i].x;
    py = 800;
    player(px, py);
  }
  objectMove();
  objectDisp();
  hit();
  scoreDisp();
  if(hp < 1){
    gameManager = 2; //gameoverへ画面遷移
  }
}

void gameOver(){
  textAlign(CENTER);
  textSize(150);
  fill(255,0,0);
  text("GAME OVER……",width/2, height/2-50);
  textSize(90);
  fill(255);
  text("Your score : " + score,width/2, height/2+70);
  if(frameCount/10 % 2 != 0){
    text("retry",width/2, height/2+250);
  }
  if(mousePressed == true){
    gameManager = 1;
    score = 0;
    hp = 5;
  }
}

void draw() {
  background(0);
  if(gameManager == 0){
    gameStanby();
  }else if(gameManager == 1){
    gamePlay();
  }else if(gameManager == 2){
    gameOver();
  }
}
