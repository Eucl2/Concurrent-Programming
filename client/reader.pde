class ReaderEspera extends Thread{
  BufferedReader in;
  String username;
  Estado estado2=new Estado();

  ReaderEspera(BufferedReader in, String username,Estado e){
     this.in = in;
      this.username = username;
      this.estado2=e;


  }
  
  
  public void run() {
    System.out.println("Entrou\n");

    while(true){
      if (winM || perdeM){
      break;}
       try {
         System.out.println("ESPERA\n");
        String msg = this.in.readLine();
        if(msg.equals("Comeca")){
          gameM=true;
          esperaM=false;
           msg = this.in.readLine();
           estado.pid=msg;
           System.out.println("pid "+msg);
           msg = this.in.readLine();
           System.out.println("MSG "+msg);
           Estado es=new Estado();
            String[] line =msg.split("&");
            String[] ps =line[0].split(",");
             for (int i=0;i<ps.length;i++){
               
               String[] p =ps[i].split("#");
               if (p[0].equals(this.username)){
                 es.player=new Player(p[0],Float.parseFloat(p[1]),Float.parseFloat(p[2]),Float.parseFloat(p[3]),Integer.parseInt(p[4]),false,Integer.parseInt(p[5]));
               }else{
                 Player jogador=new Player(p[0],Float.parseFloat(p[1]),Float.parseFloat(p[2]),Float.parseFloat(p[3]),Integer.parseInt(p[4]),true,Integer.parseInt(p[5]));
                 es.enemies.add(jogador);
                 
                 }
             
               
             }
             String[] cris =line[1].split(",");
             for (int z=0;z<cris.length;z++){
               String[] c =cris[z].split("#");
               Corpo corpoo= new Corpo(Float.parseFloat(c[0]),Float.parseFloat(c[1]),Float.parseFloat(c[3]),Integer.parseInt(c[2]),Float.parseFloat(c[4]));
               es.corpos.add(corpoo);
             }
             estado.update(es.player,es.enemies,es.corpos);
             pode=true;
            
        }else if(msg.equals("Vitoria")){
          gameM=false;
          winM=true;
          break;
        }
         else{
        
          
            System.out.println("MSG "+msg);
           Estado es=new Estado();
            String[] line =msg.split("&");
            String[] ps =line[0].split(",");
             for (int i=0;i<ps.length;i++){
               
               String[] p =ps[i].split("#");
               if (p[0].equals(this.username)){
                 es.player=new Player(p[0],Float.parseFloat(p[1]),Float.parseFloat(p[2]),Float.parseFloat(p[3]),Integer.parseInt(p[4]),false,Integer.parseInt(p[5]));
               }else{
                 Player jogador=new Player(p[0],Float.parseFloat(p[1]),Float.parseFloat(p[2]),Float.parseFloat(p[3]),Integer.parseInt(p[4]),true,Integer.parseInt(p[5]));
                 es.enemies.add(jogador);
                 
                 }
             
               
             }
             String[] cris =line[1].split(",");
             for (int z=0;z<cris.length;z++){
               String[] c =cris[z].split("#");
               Corpo corpoo= new Corpo(Float.parseFloat(c[0]),Float.parseFloat(c[1]),Float.parseFloat(c[3]),Integer.parseInt(c[2]),Float.parseFloat(c[4]));
               es.corpos.add(corpoo);
             }
             estado.update(es.player,es.enemies,es.corpos);
             }
        
        }catch (Exception e) {

      }

    }

  }


}
