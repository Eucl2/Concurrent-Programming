class Estado {
    Player player;
    String pid; 
    ArrayList<Player> enemies;
    ArrayList<Corpo> corpos;
    //ArrayList<Player> leadboard;
    Estado(){
    this.player = new Player();
    this.enemies = new ArrayList<Player>();
    this.corpos = new ArrayList<Corpo>();
  }
  Estado(Player p,ArrayList<Player> en,ArrayList<Corpo> c){
    this.player = p;
    this.enemies = en;
    this.corpos = c;
  }
  synchronized void update(Player p,ArrayList<Player> en,ArrayList<Corpo> c){
   this.player = p;
    this.enemies = en;
    this.corpos = c;
    
  }
  synchronized Estado getState(){
    Estado s = new Estado();
    s.player=this.player;
    s.enemies=this.enemies;
    s.corpos=this.corpos;
    return s;
  }
  
void show() {
    textAlign(LEFT);
    textSize(20);

    // barra do fuel
    fill(255, 0, 0);  // vermelho se fuel estiver baixo
    if (player.fuel > 20) {
        fill(0, 255, 0);  // verde se fuel estiver ok
    }
    float fuelWidth = map(player.fuel, 0, 100, 0, 200);
    rect(10, height - 30, fuelWidth, 20);  // barra de fuel

    fill(0);
    text("Combustível: " + (int) player.fuel + "%", 10, height - 35);

    // combustível acabou e exibe uma mensagem
    if (player.fuel <= 0) {
        fill(255, 0, 0); // Cor vermelha para a mensagem de alerta
        textSize(20);
        text("Combustível Esgotado", 10, height - 15);
    }

    int i = 1;
    for (Player play : this.enemies) {
        play.show();
        i += 1;
        textAlign(LEFT);
        textSize(20);
        // info dos inimigos
        text(play.username + ": " + (int) play.fuel + "%", 10, height - 25 - (20 * i));
    }

    for (Corpo corp : this.corpos) {
        corp.show();
    }
    player.show();
}


}
