import ddf.minim.spi.*; //<>//
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Table table;
Table notetable;
FFT fft;
Minim minim;
AudioPlayer player;
int noteNum;
boolean startFlag;
TimeManager timemanager;
TouchState touchState;
GameState gameState;
noteCursor ncursor;
BpmFrame bpm;
final int MUSIC_SPEED=20;
//toruko
final float BPM_SETING=126.8;
//final float BPM_SETING=171.9;
final  int FPS=60; //<>//
final int BASE_FPS=60;
final int START_MUSIC_FRAME=BASE_FPS*100;
String fileName;
NoteClass note;

void setup() {
  frameRate(FPS);
  noteNum=1;
  fileName="toruko";
  String  fileNamePathCsv=fileName+".csv";  
  String  fileNamePathMusic=fileName+".mp3";
  table = loadTable(fileNamePathCsv);
 // print(table.getInt(1,0));
  notetable=new Table();
  notetable.addColumn("frame");
  startFlag=false;
  minim = new Minim(this);
  player = minim.loadFile(fileNamePathMusic,1024); 
  //playerl.play();  
  
  timemanager=new TimeManager(millis());
  size(640, 480);
  noStroke();
  touchState=new TouchState(TouchState.NO_TOUCH);
  gameState=new GameState(GameState.PLAYMODE);
  ncursor=new noteCursor(40,height/2,40);
  bpm=new BpmFrame(BPM_SETING,MUSIC_SPEED);
  note=new NoteClass();
  println("total:"+table.getRowCount());
  fft=new FFT(player.bufferSize(),player.sampleRate());
  
}
void stop() {
  minim.stop();
  super.stop();
}
 
void draw() {
  initial_draw();
  timemanager.manageTime();
  text(gameState.StateString(),20,20,255);
  text(str(frameRate),130,130);
  bpm.manage();
  touchStateEvent(); //<>//
  if(!timemanager.pState){
     if(timemanager.msCount>START_MUSIC_FRAME&&!startFlag){
        player.play();      
        startFlag=true;
      }
        bpm.move();
   }

  //on WRITEMODE 
  if(gameState.gState==int(GameState.WRITEMODE)){
    if(touchState.state==TouchState.OK_TOUCH&&key==ENTER){
       notetable.addRow().setInt("frame",timemanager.msCount);
    }
    
  }
  
  //on PLAYMODE 
  if(gameState.gState==int(GameState.PLAYMODE)){ 
      if(!timemanager.pState){
      //  note.manage((table.getInt(noteNum,0)-((width-ncursor.xPos)/MUSIC_SPEED)),width-8,height/2,16);    
        
        int t=int((width-ncursor.xPos)/((1.0/float(BASE_FPS))*MUSIC_SPEED));
        note.manage((table.getInt(noteNum,0)-t),width-8,height/2,16);    
      }
      for (int i = 0; i < note.spots.size(); i++) { 
        note.display(i); // Display each object
      }
  }
  displayMusicProperty();
  ncursor.display();
  noFill();
}

class NoteClass {
  ArrayList spots;
  // Constructor
  NoteClass(){
    spots=new ArrayList(); //<>//
  }

  void manage(int notef,int nxPos,int nyPos,int diameter){
      if(timemanager.msCount>=notef&&noteNum<table.getRowCount()-1){
        int a=timemanager.msCount;
        int b=notef;
        int c=a-b;
        String time=a+"-"+b+"="+c;
        //println(time)  ;
        spots.add( new Note(nxPos, nyPos, diameter, MUSIC_SPEED));
         noteNum++;
      }
      for(int i=0;i<spots.size();i++){
          Note spot=(Note)spots.get(i);
          if((ncursor.inCursor(spot.gTime,timemanager.msCount))&&(touchState.state==touchState.OK_TOUCH)){
            spots.remove(i);
            ellipse(width/2,40,40,40);
          //  print("getin!!");
          }else if(!inWindow(i)){
             spots.remove(i );
          }
        }
      for (int i = 0; i < spots.size(); i++) {
        move(i); // Move each object
      }
 }
  
  void move(int i) { 
    Note spot=(Note)spots.get(i);
    int d;
    int dist=(timemanager.msCount-spot.gTime);

    d=int((1.0/float(BASE_FPS))*(timemanager.msCount-spot.gTime)*spot.speed);
    
    //println(d);
    spot.x =width-d;
    
  }
  boolean inWindow(int i){
    Note spot=(Note)spots.get(i);
    if (((spot.x > (width + spot.diameter / 2)) || (spot.x < -spot.diameter / 2))||((spot.y > (height + spot.diameter / 2)) || (spot.y < -spot.diameter / 2))) {
    //  print("miss...");
      return false;
    }else{
      return true;
    }
  }
  void display(int i) {
   // fill(255,width/2-dist(x,y,width/2,height/2));
    Note spot=(Note)spots.get(i);
    strokeWeight(1);
    ellipse(spot.x, spot.y, spot.diameter, spot.diameter);
  }
}
class Note{
  int x, y; // X-coordinate, y-coordinate
  int diameter; // Diameter of the circle
  float speed; // Distance moved each frame
  int gTime;
  Note(int xpos, int ypos, int dia, float sp) {
    x = xpos;
    y = ypos;
    diameter = dia;
    speed = sp;
    gTime=timemanager.msCount;
  }
}
class noteCursor{
  int xPos;
  int yPos;
  int diameter;
  final int exsp=2;
  int EX_COUNTER;
  int excounter;
  noteCursor(int x,int y,int d){
    xPos=x;
    yPos=y;
    diameter=d;
    EX_COUNTER=d+10;
    excounter=0;
  }
  boolean inCursor(int g_time,int ms_Count){
    int t=int((width-ncursor.xPos)/((1.0/float(BASE_FPS))*MUSIC_SPEED));
    int noteTime=g_time+t;
    if(abs(noteTime-ms_Count)<100){
      return true;
    }else{
      return false;
    }
//    if(dist(xPos,yPos,n_x,n_y)<diameter/2+dia/2&&keyPressed){
//      return true;   
//    }else{
//      return false;
//    }
  }  
  
  void display(){
    pushStyle();
    noFill();
    stroke(340,30,30);
    strokeWeight(5);
    ellipse(xPos,yPos,diameter,diameter);
    popStyle();
  }

}
public class TouchState
{
  public int state;
  TouchState(int st){
    state=st;
  }
  private final static int    NO_TOUCH  = 0;  //ゲーム開始前
  private final static int    OK_TOUCH = 1;  //ゲーム中
  private final static int    RELEASE_WAIT = 2;  //ゲームオーバー
  
}
public class GameState
{
  public int gState;
  GameState(int st){
    gState=st;
  }
  private final static int    PLAYMODE  = 0;  //ゲーム開始前
  private final static int    EDITMODE = 1;  //ゲーム中
  private final static int    WRITEMODE = 2;  //ゲームオーバー
  
   String StateString(){
    switch(gState){
      case PLAYMODE:
        return "PLAYMODE";
      case EDITMODE:
        return "EDITMODE";
      case WRITEMODE:
        return "WRITEMODE";
      default:
        return "????";
    }
  }
}
class BpmFrame{
  float bpm;
  int lineLenght=16;
  int speed;
  int n_frame;
  ArrayList<PVector> frames;
  ArrayList<PVector> times;
  BpmFrame(float b,int sp){
    frames=new ArrayList();
    times=new ArrayList();
    bpm=b;
    speed=sp/4;
    n_frame=1;
  }
  void manage(){
    if((60.0/bpm)*1000*n_frame<timemanager.msCount){
      //print("addframe");
      n_frame++;
      frames.add(new PVector(width,height/2));
    }
    
    for(int i=0;i<frames.size();i++){
      if(!inWindow(int(frames.get(i).x))){
          frames.remove(i);
         // print("framend");
      }
    }
    display();
  }
  
   void move(){
    for(int i=0;i<frames.size();i++){
       //need to fix to time_based
      frames.get(i).x-=speed;
    }
  }
  
  void display(){
    
    for(int i=0;i<frames.size();i++){
      pushStyle();
      stroke(255,20,20);
      line(int(frames.get(i).x),frames.get(i).y+lineLenght/2,int(frames.get(i).x),frames.get(i).y-lineLenght/2); 
      popStyle();
    } 
  }
  boolean inWindow(int x){
    if(x<0){
      return false;
    }else{
    return true;
    }
  }
}
void keyTyped(){
//  int b=timemanager.msCount;
//  println(b);
//  newRow = table.addRow();
//  newRow.setInt("frame",count);
  if(timemanager.msCount<START_MUSIC_FRAME){
    if(key=='e'){
      gameState.gState=GameState.EDITMODE;
    }
    if(key=='w'){
      gameState.gState=GameState.WRITEMODE;
    }
    if(key=='p'){
      gameState.gState=GameState.PLAYMODE;
    }
  }
  if(key=='q'){
    if(gameState.gState==GameState.WRITEMODE){
      print("saved!!"); 
      saveTable(notetable,"toruko.csv") ;
    }
  }
  if(key==' '){
    if(!timemanager.pState){
      player.pause();
      timemanager.saveTime();
    }else{
       timemanager.addDiffer();
      if(timemanager.msCount>START_MUSIC_FRAME){
        player.play();
      }
    } //<>//
  }
}

void touchStateEvent(){
  if(keyPressed){
  if((touchState.state==touchState.NO_TOUCH)||(touchState.state==touchState.OK_TOUCH))
    touchState.state++;
 
  }else{
    if((touchState.state==touchState.RELEASE_WAIT)||(touchState.state==touchState.OK_TOUCH)){
      touchState.state=touchState.NO_TOUCH;
    }
  }
}

void initial_draw(){
  stroke(0,255);
 // fill(0, 24);
  fill(0, 255);
  rect(0, 0, width, height);
  fill(255);
}
void leftTimeDisplay(){
   pushStyle();
  float  soundPos  =  map(player.position(),0,player.length(),0,width-1);
  stroke(255);
  fill(120);
  rect(0,height-160,soundPos,50);
  popStyle();
}
void displayMusicProperty(){
  leftTimeDisplay();
  fft.forward(player.mix);
  for (int i = 0; i < fft.specSize()/3; i++) {
    float x = map(i*3, 0, fft.specSize(), 0, width);
 //   stroke(122);
    int bandLength=4;
    stroke(255);
    int bandNum;
    bandNum=int((fft.getBand(i)*8)/bandLength);
    for(int j=0;j<bandNum;j++){   
      int c=j*bandLength;
      stroke( c,128,128);
      line(x,height-bandLength*j,x,height-bandLength*(j+1)+3);
//      stroke(255);
//      line(x,height-bandLength*(j+1)+2,x,height-bandLength*(j+1)+2);
    }
    //line(x, height, x, height - fft.getBand(i) * 8);
   }
   stroke(122);
   for(int  i  =  0;  i  <  player.left.size()  -  1;  i++){
      line(i,  50  +  player.mix.get(i)*50,  i+1,  50  +  player.left.get(i+1)*50);
      //line(i,  150  + player.right.get(i)*50,  i+1,  150  +  player.right.get(i+1)*50);
   }
}
class TimeManager{
  int msCount;
  int msDiffer;
  int tempTime;
  boolean pState;
  TimeManager(int time){
    msDiffer=time;
    msCount=millis()-msDiffer;
    pState=false;
  //  print(msCount);
  }
  void manageTime(){
    if(!pState){
      msCount=millis()-msDiffer;
    }
  }
  void saveTime(){
      tempTime=millis();
      pState=true;
  }
  void addDiffer(){
    msDiffer+=millis()-tempTime;
    pState=false;
   // println(msDiffer);
  }
}
//
////still in the way of implement
//class touchEffect{
//   final int efnum=5;
//   int[] Pos=new int[efnum*efnum];
//   float diameter;
//   touchEffect(float dia,int x,int y){
//     diameter=dia;
//      for(int i=0;i<2;i++){
//        for(int j=0;j<efnum;j++){
//          Pos[i*efnum+j]=(i==0)?x:y;
//        }
//      }
//   }
//   void move(){
//   }
//   void display(){
//      ellipse(random(width),random(height ),diameter,diameter);
//   }
//
//}
