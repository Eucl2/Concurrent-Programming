import java.io.InputStreamReader;
import java.net.Socket;
import static javax.swing.JOptionPane.*;
Socket s;
BufferedReader in;
PrintWriter out;
import controlP5.*;

float x1;
float y1;
float fuel1;
float easing = 0.01;
float speed = 80;
float angle;
boolean keyLeft = false;
boolean keyRight = false;
boolean keyUp = false;
float titleSize = 75;
boolean increasing = true;


ControlP5 cp5;
Group login;
Group sala;
boolean mainM= true;
boolean startM=false;
boolean leaderboardM=false;
boolean loginM=false;
boolean registerM=false;
boolean removeM=false;
boolean salaM=false;
boolean esperaM= false;
boolean gameM=false;
boolean perdeM=false;
boolean winM=false;
boolean pode=false;

boolean overLeaderboard=false;
boolean overStart=false;
boolean overBack=false;
boolean overLogin=false;
boolean overRegister=false;
boolean overRemove=false;
boolean overSala1=false;
boolean overSala2=false;
boolean overSala3=false;
boolean overSala4=false;

String username  = "";
String password  = "";
String nomeSala="";

int x = 350;
int y = 55;


Thread reader ;
Estado estado=new Estado();

void setup() {
  
   //frameRate(60);
  //fullScreen(P2D);
  
  size(1440, 900);
  ellipseMode(CENTER);
  
  try {
    s = new Socket("localhost", 1234);

    in = new BufferedReader(new InputStreamReader(s.getInputStream()));
    out = new PrintWriter(s.getOutputStream());
  } catch (Exception e) {
    showMessageDialog(null, "Não foi possível conectar com o servidor!", "Erro", INFORMATION_MESSAGE);
    exit();
    return;
  }
  
  
  
   cp5        = new ControlP5(this);
     PFont font = createFont("Arial", 20);

   login      = cp5.addGroup("login");
   cp5.addTextfield( "Username" )
     .setGroup(login)
     .setPosition(width/2 - x/2, height/2 - y )
     .setSize( x, y )
     .setFocus(true)
     .setColorActive(color(0))
     .setColorBackground(color(200))
     .setColor(color(0) )
     .setFont(font)
      .setAutoClear(true)
     .setColorCaptionLabel(color(0))
     ;
    cp5.addTextfield( "Password" )
     .setGroup(login)
     .setPosition( width/2 - x/2, height/2 + y )
     .setSize( x, y)
     .setPasswordMode(true)
     .setColorActive(color(0))
     .setColor(color(0) )
     .setAutoClear(true)
     .setColorBackground(color(200))
     .setColorCaptionLabel(color(0))
     .setFont(font)
     ;
    cp5.addButton( "Login" )
     .setGroup(login)
     .setPosition( width/2 - x/2, height/2 + 3*y)
     .setSize( x, y )
     .setColorCaptionLabel(color(0))
     
     .setFont(font)
     .setColorBackground(color(200))
     .onClick( new CallbackListener() { 
        public void controlEvent(CallbackEvent theEvent) {
          username = cp5.get(Textfield.class,"Username").getText();
          password = cp5.get(Textfield.class,"Password").getText();
          System.out.println(username);
          System.out.println(password);
          
          if(login(username,password)){
          
          
          //SE DER
            loginM=false;
            salaM=true;
            cp5.getGroup("login").hide();
          }else{
          loginM=true;
        cp5.getGroup("login").show();}
         cp5.get(Textfield.class,"Nome da Sala").setText("");
        } 
      }); 
      cp5.addButton( "Register" )
     .setGroup(login)
     .setPosition( width/2 - x/2, height/2 + 4.2*y)
     .setSize( x, y )
     .setColorCaptionLabel(color(0))
     
     .setFont(font)
     .setColorBackground(color(200))
     .onClick( new CallbackListener() { 
        public void controlEvent(CallbackEvent theEvent) {
          username = cp5.get(Textfield.class,"Username").getText();
          password = cp5.get(Textfield.class,"Password").getText();
           System.out.println(username);
            System.out.println(password);
            register(username,password);
            
            

        } 
      }); 
       cp5.addButton( "Remove" )
     .setGroup(login)
     .setPosition( width/2 - x/2, height/2 + 5.4*y)
     .setSize( x, y )
     .setColorCaptionLabel(color(0))
     
     .setFont(font)
     .setColorBackground(color(200))
     .onClick( new CallbackListener() { 
        public void controlEvent(CallbackEvent theEvent) {
          username = cp5.get(Textfield.class,"Username").getText();
          password = cp5.get(Textfield.class,"Password").getText();
           System.out.println(username);
          System.out.println(password);
            remover(username,password);
          


        } 
      });
     cp5.getGroup("login").hide();
     
     //salas
     sala      = cp5.addGroup("sala");
     
      cp5.addTextfield( "Nome da Sala" )
     .setGroup(sala)
     .setPosition(width/2 - x/2, height/2 - y )
     .setSize( x, y )
     .setFocus(true)
     .setColorActive(color(0))
     .setColorBackground(color(200))
     .setColor(color(0) )
     .setFont(font)
     
     .setColorCaptionLabel(color(0))
     ;
     cp5.addButton( "Entrar " )
     .setGroup(sala)
     .setPosition( width/2 - x/2, height/2 + 3*y)
     .setSize( x, y )
     .setColorCaptionLabel(color(0))
     .setFont(font)
     .setColorBackground(color(200))
     .onClick( new CallbackListener() { 
        public void controlEvent(CallbackEvent theEvent) {
          nomeSala = cp5.get(Textfield.class,"Nome da Sala").getText();
         
           System.out.println(nomeSala);
          
            if(salaMudar(username,nomeSala)){
          //SE DER
            salaM=false;
            esperaM=true;
            
           System.out.println("COMECOU\n");
          reader = new ReaderEspera(in, username,estado);
            reader.start();
            
            cp5.getGroup("sala").hide();
            }
        } 
      });
     cp5.getGroup("sala").hide();
}

void draw() {
  update(mouseX, mouseY);
  background(240);
  
  if (mainM){
    
    showMainMenu();}
  else if(startM)
    showStartMenu();
  else if(leaderboardM)
    showLeaderboard();
  else if (loginM) 
    showLogin();
  else if (registerM) 
    showRegister();  
  else if (removeM) 
    showRemove();    
  else if(salaM)
      showSala();
  else if(esperaM)
    showEspera();
  else if(gameM)
  {
    showGame();
  }
  else if(perdeM) 
    showPerde();
  else if(winM) 
    showWin();  
  
}

void showGame(){
    background(255);
  
    Estado t = new Estado();
    t = estado.getState();
    x1 = t.player.getPos().x;
    y1 = t.player.getPos().y;
 
    fuel1 = t.player.getFuel();
      if ((keyLeft) && (fuel1 >0)) {
          angle -= 0.05; // velocidade de rotação esquerda
          fuel1 -= 0.01;
      }
      if ((keyRight) && (fuel1 >0)) {
          angle += 0.05; // velocidade de rotação direita
          fuel1 -= 0.01;
      }
      if ((keyUp) && (fuel1 >0)) {
          x1 += speed * cos(angle) * 0.05; // Movimento linear na direção do ângulo
          y1 += speed * sin(angle) * 0.05;
          fuel1 -= 0.05;
      }
  
    if (pode) {
        out.println("check_pos " + estado.pid + " " + x1 + " " + y1 + " " + fuel1 +" " + t.player.username);
        out.flush();
        estado.player.move(x1, y1);
        estado.player.setFuel(fuel1);
    }
   
  
    if (t.player.alive == 0) {
        gameM = false;
        perdeM = true;
        logout(username, password);
    } else {
        boolean flag = false;
        for (Player enemie : t.enemies) {
            if (enemie.alive == 1) {
                flag = true;
            }
        }
        if (!flag) {
            out.println("Ganhou " + estado.pid + " " + t.player.username);
            out.flush();
            gameM = false;
            winM = true;
            logout(username, password);
        }
    }
    estado.show();
}

void showWin(){
  textSize(100);
  fill(0);
  textAlign(CENTER,CENTER);
  text("GANHASTE", width/2, height/2 - y/2);
}
void showPerde(){
  textSize(100);
  fill(0);
  textAlign(CENTER,CENTER);
  text("PERDESTE", width/2, height/2 - y/2);
}
void showEspera(){
  textSize(100);
  fill(0);
  textAlign(CENTER,CENTER);
  text("WAITING ROOM", width/2, height/2 - y/2);
  ///
  //BACK
  stroke(0);
  if ( overRect(0.05*width, 0.9*height, x/2, y) ) {
    overBack=true;
    strokeWeight(3.5);
  }else{
    overBack=false;
    strokeWeight(0);
  }
  fill(200) ;
  rect(0.05*width, 0.9*height, x/2, y);
  textSize(24);
  fill(0);
  textAlign(CENTER, CENTER);
  text("BACK", 0.05*width + x/4, 0.9*height + y/2);
}
void showSala(){
  textSize(75);
  fill(0);
  textAlign(CENTER,CENTER);
  text("SALAS", width/2, height/5);
  
    cp5.getGroup("sala").show();
  //BACK
  stroke(0);
  if ( overRect(0.05*width, 0.9*height, x/2, y) ) {
    overBack=true;
    strokeWeight(3.5);
  }else{
    overBack=false;
    strokeWeight(0);
  }
  fill(200) ;
  rect(0.05*width, 0.9*height, x/2, y);
  textSize(24);
  fill(0);
  textAlign(CENTER, CENTER);
  text("BACK", 0.05*width + x/4, 0.9*height + y/2);
}
void showLogin(){
  textSize(75);
  fill(0);
  textAlign(CENTER,CENTER);
  text("LOGIN", width/2, height/5);
  ///
  cp5.show();
    cp5.getGroup("login").show();

  
  //BACK
  stroke(0);
  if ( overRect(0.05*width, 0.9*height, x/2, y) ) {
    overBack=true;
    strokeWeight(3.5);
  }else{
    overBack=false;
    strokeWeight(0);
  }
  fill(200) ;
  rect(0.05*width, 0.9*height, x/2, y);
  textSize(24);
  fill(0);
  textAlign(CENTER, CENTER);
  text("BACK", 0.05*width + x/4, 0.9*height + y/2);
}
void showRegister(){
  textSize(75);
  fill(0);
  textAlign(CENTER,CENTER);
  text("REGISTER", width/2, height/5);
  //BACK
  stroke(0);
  if ( overRect(0.05*width, 0.9*height, x/2, y) ) {
    overBack=true;
    strokeWeight(3.5);
  }else{
    overBack=false;
    strokeWeight(0);
  }
  fill(200) ;
  rect(0.05*width, 0.9*height, x/2, y);
  textSize(24);
  fill(0);
  textAlign(CENTER, CENTER);
  text("BACK", 0.05*width + x/4, 0.9*height + y/2);
}
void showRemove(){
  textSize(75);
  fill(0);
  textAlign(CENTER,CENTER);
  text("REMOVE", width/2, height/5);
  //BACK
  stroke(0);
  if ( overRect(0.05*width, 0.9*height, x/2, y) ) {
    overBack=true;
    strokeWeight(3.5);
  }else{
    overBack=false;
    strokeWeight(0);
  }
  fill(200) ;
  rect(0.05*width, 0.9*height, x/2, y);
  textSize(24);
  fill(0);
  textAlign(CENTER, CENTER);
  text("BACK", 0.05*width + x/4, 0.9*height + y/2);
}
void showStartMenu(){
  textSize(75);
  fill(0);
  textAlign(CENTER,CENTER);
  text("START", width/2, height/5);
  //LOGIN
  stroke(0);
  if ( overRect(width/2 - x/2, height/2 - y, x, y) ) {
    overLogin=true;
    strokeWeight(3.5);
  }else{
    overLogin=false;
    strokeWeight(0);
  }
  fill(200) ;
  rect(width/2 - x/2, height/2 - y, x, y);
  textSize(24);
  fill(0);
  textAlign(CENTER, CENTER);
  text("LOGIN", width/2, height/2 - y/2);
  
  
  //BACK
  stroke(0);
  if ( overRect(0.05*width, 0.9*height, x/2, y) ) {
    overBack=true;
    strokeWeight(3.5);
  }else{
    overBack=false;
    strokeWeight(0);
  }
  fill(200) ;
  rect(0.05*width, 0.9*height, x/2, y);
  textSize(24);
  fill(0);
  textAlign(CENTER, CENTER);
  text("BACK", 0.05*width + x/4, 0.9*height + y/2);
  
  
}
void showLeaderboard(){
  textSize(75);
  fill(0);
  textAlign(CENTER,CENTER);
  text("LEADERBOARD", width/2, height/5);
    //BACK
  stroke(0);
  if ( overRect(0.05*width, 0.9*height, x/2, y) ) {
    overBack=true;
    strokeWeight(3.5);
  }else{
    overBack=false;
    strokeWeight(0);
  }
  fill(200) ;
  rect(0.05*width, 0.9*height, x/2, y);
  textSize(24);
  fill(0);
  textAlign(CENTER, CENTER);
  text("BACK", 0.05*width + x/4, 0.9*height + y/2);
}
void showMainMenu(){
  //TITULO
  textSize(titleSize);
  fill(0);
  textAlign(CENTER,CENTER);
  text("Gravidade", width/2, height/5);
  // animacao
  if (increasing) {
    titleSize += 0.5;
    if (titleSize > 85) { // Máximo tamanho
        increasing = false;
    }
  } else {
      titleSize -= 0.5;
      if (titleSize < 65) { // Mínimo tamanho
          increasing = true;
      }
}
  
  //START
  stroke(0);
  if ( overRect(width/2 - x/2, height/2 - y, x, y) ) {
    overStart=true;
    strokeWeight(3.5);
  }else{
    overStart=false;
    strokeWeight(0);
  }
  fill(200) ;
  rect(width/2 - x/2, height/2 - y, x, y);
  textSize(24);
  fill(0);
  textAlign(CENTER, CENTER);
  text("START", width/2, height/2 - y/2);
  
  //LEADERBOARD
  stroke(0);
  if ( overRect(width/2 - x/2, height/2 + y, x, y) ) {
    overLeaderboard=true;
    strokeWeight(3.5);
  }else{
    overLeaderboard=false;
    strokeWeight(0);
  }
  fill(200) ;
  rect(width/2 - x/2, height/2 + y, x, y);
  textSize(24);
  fill(0);
  textAlign(CENTER, CENTER);
  text("LEADERBOARD", width/2, height/2 + y + y/2);
  
}

void update(int x, int y) {
  
    
}

void mousePressed() {
  
  if(mainM){
    if(overStart){
    
    mainM=false;
    startM=true;
    }
    else if(overLeaderboard)  {
      mainM=false;
      leaderboardM=true;
    }
  }
  else if(startM){
     if (overLogin){
       startM=false;
       loginM=true;
       
     }
     
     else if(overBack ){   
        mainM=true;
        startM=false;
      }
      
  }
  else if(leaderboardM){
  
  
    if(overBack ){   
        mainM=true;
        leaderboardM=false;
      }
    
  }else if(loginM){
    if(overBack ){   
        loginM=false;
        startM=true;
        cp5.getGroup("login").hide();
     }
  
  }else if(registerM){
    if(overBack ){   
        registerM=false;
        startM=true;
     }
  }else if(removeM){
    if(overBack ){   
        removeM=false;
        startM=true;
     }
  }else if(salaM){
    
    
    if(overBack){
      salaM=false;
      loginM=true;
      cp5.getGroup("sala").hide();
      logout(username,password);
    }
  }
  else if(gameM){
    //jogo, verificar se necessario
  }else if(esperaM){
    
    if(overBack){
      
      
      //System.out.println("MORREU?\n");
    esperaM=false;
    salaM=true;
  }
  }
  

  
}

void keyPressed() {
    if (keyCode == LEFT) {
        keyLeft = true;
    }
    if (keyCode == RIGHT) {
        keyRight = true;
    }
    if (keyCode == UP) {
        keyUp = true;
    }
}

void keyReleased() {
    if (keyCode == LEFT) {
        keyLeft = false;
    }
    if (keyCode == RIGHT) {
        keyRight = false;
    }
    if (keyCode == UP) {
        keyUp = false;
    }
}




boolean overRect(float x, float y, float width, float height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
