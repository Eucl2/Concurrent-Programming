boolean login(String username, String pass){
  if(username.equals("") || pass.equals("")){
    showMessageDialog(null, "Campos não preenchidos. Por favor preencha.", "Erro", INFORMATION_MESSAGE);
    return false;
  }
  
  out.println("login " + username + " " + password);
  out.flush();
  try{
   String msg = in.readLine();
   
   if(msg.equals("Logou")){
      //showMessageDialog(null, "Logou :)", "Aviso", INFORMATION_MESSAGE);
      return true;
   }
   else if (msg.indexOf("Error:")>=0){
     showMessageDialog(null, msg, "Aviso", INFORMATION_MESSAGE);
     return false;
   }
  } catch (Exception e) {
  System.out.println(e);}

  return false;
}

boolean register(String username, String pass){
  if(username.equals("") || pass.equals("")){
    showMessageDialog(null, "Campos não preenchidos. Por favor preencha.", "Erro", INFORMATION_MESSAGE);
    
    return false;
  }
  out.println("create_account " + username + " " + password);
  out.flush();
  
  try{
   String msg = in.readLine();
   if(msg.equals("Criada")){
     showMessageDialog(null, "Conta criada com sucesso.", "Aviso", INFORMATION_MESSAGE);
     return true;
   }
   else if (msg.indexOf("Error:")>=0){
     showMessageDialog(null, msg, "Aviso", INFORMATION_MESSAGE);
     return false;
   }
  } catch (Exception e) {
  System.out.println(e);}
  return false;
}

boolean remover(String username, String pass){
  if(username.equals("") || pass.equals("")){
    showMessageDialog(null, "Campos não preenchidos. Por favor preencha.", "Erro", INFORMATION_MESSAGE);
    return false;
  }
  out.println("close_account " + username + " " + password);
  out.flush();
  
  try{
   String msg = in.readLine();
      System.out.println(msg);

   if(msg.equals("Removida")){
     showMessageDialog(null, "Conta removida com sucesso", "Aviso", INFORMATION_MESSAGE);
     return true;
   }
   else if (msg.indexOf("Error:")>=0){
     showMessageDialog(null, msg, "Aviso", INFORMATION_MESSAGE);
     return false;
   }
  } catch (Exception e) {
    System.out.println(e);
  }
  return false;
}
boolean salaMudar(String username ,String sala){

  if(username.equals("") || sala.equals("")){
    showMessageDialog(null, "Campos não preenchidos. Por favor preencha.", "Erro", INFORMATION_MESSAGE);
    return false;
  }
  out.println("join " + sala + " " + username);
  out.flush();
   try{
   String msg = in.readLine();
   if(msg.equals("JoinedRoom")){
     //showMessageDialog(null, "Entrou na sala", "Aviso", INFORMATION_MESSAGE);
     
     
     return true;
   }
   else if (msg.indexOf("Error:")>=0){
     showMessageDialog(null, msg, "Aviso", INFORMATION_MESSAGE);
     return false;
   }
  } catch (Exception e) {
  System.out.println(e);}
  return false;
}
boolean logout(String username, String pass){
  if(username.equals("") || pass.equals("")){
    showMessageDialog(null, "Preencha", "Erro", INFORMATION_MESSAGE);
    return false;
  }
  out.println("logout " + username + " " + password);
  out.flush();
  try{
   String msg = in.readLine();
   if(msg.equals("Logged out")){
    // showMessageDialog(null, "logout", "Aviso", INFORMATION_MESSAGE);
     
     
     return true;
   }
   else if (msg.indexOf("Error:")>=0){
     showMessageDialog(null, msg, "Aviso", INFORMATION_MESSAGE);
     return false;
   }
  } catch (Exception e) {
  System.out.println(e);}
  return false;
  
}
