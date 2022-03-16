/**
* Joc del Sudoku en Java
* Joc que inicia un Sudoku en base a la dificultat triada per l'usuari (fàcil, mitjana o difícil) 
* crea un Sudoku que el jugador ha de resoldre.
* @author Vicent Sanchis
* @since 09/09/2022
*/
// CONSTANTS
// FASES
final int TRIA_DIFICULTAT = 0;     // Pantalla inicial on triem el nivell de dificultat   
final int INICIANT        = 1;     // Inicialitzant l'array que conté la informació del Sudoku
final int JUGANT          = 2;     // Ja hem inicialitzat el sudoku i comencem a jugar
final int MOSTRAOPCIONS   = 3;     // Quan fem clic sobre una casella buida ens mostrarà un teclat amb 9 números.
final int INTRODUINT      = 4;     // Esperant que l'usuari trie un número del 1 al 9 o punxe fora del requadre numèric
final int MOSTRAMISSATGE  = 5;     // Mostrant algun missatge superposat a tot

// NIVELLS DE DIFICULTAT
final int FACIL           = 0;     // Nivell Facil, nivell inicial  
final int MITJA           = 1;     // Nivell mitjà
final int DIFICIL         = 2;     // Nivell més difícil

// CONFIGURACIÓ 
final int TAMANYCELA      = 35;    // El tamnany de cada cel·la de la graella   
final int OFFSET_X        = 160;   // Coordenada X on es dibuixarà el Sudoku
final int OFFSET_Y        = 65;    // Coordenada Y on es dibuixarà el Sudoku
final int TITOL           = 120;   // Tamany de la font del títol
final int TITOL2          = 60;    // Tamany de la font quan estem jugant
final int OPCIONS         = 35;    // Tamany de la font de les opcions
final int NUMEROS         = 22;    // Tamany de la font dels números

// VARIABLES GLOBALS
PFont  fntSudoku;                  // Font que utilitza l'apliació per als títols
PImage fons;                       // Imatge del fons de l'aplicació
color  cSombrejat, cOmbraFosca;    // Colors dels ombrejats de cel·les i diàlegs
int    iFaseActual;                // Fase en la que es troba el joc: TRIA_DIFICULTAT, INICIANT, JUGANT, MOSTRAOPCIONS, INTRODUINT o MOSRAMISSATGE
int    iNivellDificultat;          // Indica el nivell de dificultat que ha triat el jugador
int    iNumerosOcultar;            // Total de números a ocultar segons el nivell de dificultat.
int    iTotalEncertats;            // Total de números resolts al Sudoku
int    filOpcions, colOpcions;     // Fila i columna a la que volem introduir un número amb valors entre 0 i 8
int    optRelativeX, optRelativeY; // Determinaran l'àrea on es fa clic per triar un número, fora d'aquesta area canviem de fase a JUGANT
int    optHoverXabs, optHoverYabs; // Ens determina l'origen de coordenades del requadre d'opcions (números)
int    iValorIntroduit;            // Opció sobre la que fem clic per introduir al sudoku.
int    iMissatge;                  // Número del missatge a mostrar per pantalla

// MEMBRES DEL JOC
int     [][] arraySudoku;          // Matriu que conté el Sudoku complet i sol·lucionat
boolean [][] arrayOcults;          // Matriu de booleans que ens indica quins números estan ocults (true) i quins no (false)
boolean [][] arrayUsuari;          // Matriu amb els números que va introduint l'usuari

/**
* S'executa només una vegada a l'inici de l'aplicació i configura el joc 
*/
void setup () {
  size(640,480);
  smooth(8);
  
  //  Configurem la font del joc i el fons
  fntSudoku = createFont("fonts/Sudoku.ttf",TITOL);
  textFont(fntSudoku);
  textAlign(CENTER,CENTER);
  fons = loadImage("img/fons1.jpg");
  
  // Configurem les variables d'aplicació
  iFaseActual     = TRIA_DIFICULTAT;
  arraySudoku     = new int [9][9];
  cSombrejat      = color(200,200);
  cOmbraFosca     = color(100,220);
  
  iNumerosOcultar = 0;
  iTotalEncertats = 0;
}
/**
* Funció principal del joc. Bucle de joc
*/
void draw () {
  clear();
  background(fons);
  fill(0);
  
  switch (iFaseActual) {
    case TRIA_DIFICULTAT:
      mostrarPrimeraPantalla();
    break;
  
    case INICIANT:
      iValorIntroduit = -1;
      iTotalEncertats = 0;
      arrayOcults = new boolean[9][9];
      arrayUsuari = new boolean[9][9];
      inicialitzaArraySudoku ();
      iFaseActual = JUGANT;
    break;
      
    case JUGANT:
      titol2();
      if (quedenNumerosPerEncertar()) {
        emplenarSudoku ();
        dibuixaContenidor ();
      }
      else {
        iMissatge   = 2;
        iFaseActual = MOSTRAMISSATGE;
      }
      
    break;
      
    case MOSTRAOPCIONS:
      titol2();
      emplenarSudoku ();
      dibuixaContenidor  ();
      mostraOpcions(filOpcions, colOpcions);
    break;
      
    case INTRODUINT:
      introdueixValor();
    break;
    
    case MOSTRAMISSATGE:
      mostraMissatge();      
    break;
  }
  delay(0);
}
/**
* Comprova si queden encara caselles del Sudoku en blanc, en cas de quedar-ne
* torna true si ja no en queden buides torna false
*/
boolean quedenNumerosPerEncertar() {
  return iTotalEncertats != 81;
}
// FUNCIONS DE CONTROL DEL JOC
/**
* En cas que el número a introduir siga vàlid, es modifiquen les matrius d'ocults i d'introduits
* pel jugador i es mostra el missatge 0 (vàlid) en cas contrari es mostra (no vàlid)
*/
void introdueixValor() {
  if (iValorIntroduit != -1 ) {
    if(validarNumero(filOpcions,colOpcions,iValorIntroduit)) {
      iMissatge = 0;
      iFaseActual = MOSTRAMISSATGE;
      arrayOcults[filOpcions][colOpcions] = false;
      arrayUsuari[filOpcions][colOpcions] = true;
      iTotalEncertats ++;
      
      if (!quedenNumerosPerEncertar())
        iMissatge = 2;
    }
    else 
      iMissatge   = 1;
  }
  iFaseActual = MOSTRAMISSATGE;
}
/**
* Inicialitza els valors del Sudoku segons el nivell de dificultat que l'usuari haja escollit
* a l'inici del joc.
*/
void inicialitzaArraySudoku ( ) {
  // Primera fase: inicialitzem la matriu
  for(int fil=0; fil < 9; fil ++) {
    for(int col=0; col < 9; col ++) {
      if (fil == 0 || fil == 3 || fil == 6) 
        arraySudoku[fil][col] = (col + fil/3)%9+1;
      else if ((fil > 0 && fil < 3) || (fil > 3 && fil < 6) || (fil > 6 && fil < 9))
        arraySudoku[fil][col] = (arraySudoku[(fil/3)*3][col]+3*fil-1)%9+1;
    }
  }
  
  // Segona fase: barallem files
  for(int fil = 0; fil < 9; fil += 3) {
    int f1, f2;
    do {
      f1 = (int)random(fil,fil+3);
      f2 = (int)random(fil,fil+3);
    }
    while(f1 == f2);
    
    for (int col=0; col < 9; col ++) {
      int aux = arraySudoku[f1][col];
      arraySudoku[f1][col] = arraySudoku[f2][col];
      arraySudoku[f2][col] = aux;
    }
  }
  
  // Tercera fase: barallem les columnes
  for(int col = 0; col < 9; col += 3) {
    int c1, c2;
    do {
      c1 = (int)random(col,col+3);
      c2 = (int)random(col,col+3);
    }
    while(c1 == c2);
    
    for (int fil=0; fil < 9; fil ++) {
      int aux = arraySudoku[fil][c1];
      arraySudoku[fil][c1] = arraySudoku[fil][c2];
      arraySudoku[fil][c2] = aux;
    }
  }
  
  // Quarta fase: interncanviem dues files de submatrius 
  int sm1, sm2;
  do {
    sm1 = (int)random(0,3);
    sm2 = (int)random(0,3);
  }
  while(sm1 == sm2);
  
  for (int i = 0; i < 3; i ++) {
    for(int j = 0; j < 9; j ++) {
      int val1 = 3*sm1+i;
      int val2 = 3*sm2+i;
      int aux = arraySudoku[val1][j];
      arraySudoku[val1][j] = arraySudoku[val2][j];
      arraySudoku[val2][j] = aux;
    }
  }
  
  // Cinquena fase: Ocultar Números segons nivell de dificultat per començar a jugar.
  ocultaNumeros();
  iTotalEncertats = iNumerosOcultar;
}
/**
* Marca a la matriu arrayOcults, en base al nivell de dificultat, els números del Sudoku
* que no es mostraran per pantalla
*/
void ocultaNumeros() {
  int totalOcults = 0;
  while (totalOcults <= iNumerosOcultar) {
    int x = (int)random(0,9);
    int y = (int)random(0,9);
    if ( !arrayOcults[x][y]) {
      arrayOcults[x][y] = true;
      totalOcults ++;
    }
  }
}
/**
* Comporva que el número que es vol insertar a la posició (x,y) és un número vàlid
* Per comprovar-ho primer mira si compleix les restriccions de fila, després comprova
* les restriccions de columna i finalment les de la submatriu on volem inserir el número.
* Si tot és correcte returna true sino torna false.
* @param x fila a la que volem inserir un nou número
* @param y columna a la que volem inserir un nou número
* @param possibleValor número que volem inserir
*/
boolean validarNumero(int x, int y, int possibleValor) {
  return possibleValor == arraySudoku[x][y];
  
  /*boolean validFila    = validaFila(x, possibleValor);
  boolean validColumna = validaColumna(y, possibleValor);
  boolean validBox     = validaSubMatriu(x,y, possibleValor);
  
  return validFila && validColumna && validBox;*/
}
/**
* Comprova que el número que es vol posar (valor) no existeix a la mateixa fila x
* @param x fila en la que volem inserir valor
* @param valor número que volem inserir a la fila x
*/
boolean validaFila(int x, int valor) {
  for (int i = 0; i < 9; i ++ )
    if(arraySudoku[x][i] == valor && !arrayOcults[x][i]) 
      return false;
      
  return true;
}
/**
* Comprova que el número que es vol posar (valor) no existeix a la mateixa columna y
* @param y columna en la que volem inserir valor
* @param valor número que volem inserir a la columna y
*/
boolean validaColumna(int y, int valor) {  
  for (int i = 0; i < 9; i ++)
    if (arraySudoku[i][y] == valor && !arrayOcults[i][y])
      return false;
  return true;
}
/**
* Comprova que el número que es vol posar (valor) no existeix a la submatriu on 
* es troba la cel·la (x,y)
* @param x fila de la submatriu que es vol comprovar
* @param y columna de la submatriu que es vol comprovar
* @param valor número que volem inserir a la submatriu
*/
boolean validaSubMatriu(int x, int y, int valor) {
  int iniciX = x / 3;
  iniciX *= 3;
  int iniciY = y / 3;
  iniciY *= 3;
  
  for (int i = iniciX; i < iniciX + 3; i ++)
    for (int j = iniciY; j < iniciY + 3; j ++ )
      if(arraySudoku[i][j] == valor && !arrayOcults[i][j]) 
        return false;
        
  return true;
}
// FUNCIONS GRÀFIQUES
/**
* Mostra el títol de la pantalla on estem jugant al sudoku
*/
void titol2 ( ) {
  textSize(TITOL2);
  text("SUDOKU", width/2, 27);
}
/**
* Mostra la pantalla inicial del joc on el jugador podra triar el nivell de dificultat
*/
void mostrarPrimeraPantalla() {
  textSize(TITOL);
  text("SUDOKU", width/2, 50);
  rectMode(CENTER);
  fill(cSombrejat);
  rect(width/2,235,200,200);
  rectMode(CORNER);
  textSize(OPCIONS);
  fill(50);
  text("1. Facil", width/2, 180);
  text("2. Mitja", width/2, 235);
  text("3. Dificil", width/2, 290);
}
/**
* Dibuixa la graella on es contindrà el Sudoku
*/
void dibuixaContenidor () {
  stroke(0);
  noFill();
  pushMatrix();
  // Amb açò aconseguim que el punt de referència per dibuixar la matriu siga el 160,140
  // En aquestes línees de codi es dibuixa el contenidor del Sudoku: vores, fons i linies grosses.
  translate(OFFSET_X,OFFSET_Y);    
  strokeWeight(3);
  rect(0,0,315,315);
  line(105,0,105,315);
  line(210,0,210,315);
  line(0,105,315,105);
  line(0,210,315,210);
  
  strokeWeight(1);
  for (int i = 0; i < 9; i ++ ) 
    for (int j = 0; j < 9; j ++ ) 
      rect(i*TAMANYCELA, j*TAMANYCELA, TAMANYCELA, TAMANYCELA);
     
  popMatrix();
}
/**
* Emplena la graella del Sudoku amb els valors de l'array que conté la informació del joc
* que s'ha inicialitzat segons el nivell de dificultat a l'inici de l'aplicació.
*/
void emplenarSudoku () {
  int posTextCelaX = 0;
  int posTextCelaY = 0;
  int posCelaX     = 0;
  int posCelaY     = 0;
 
  textSize(NUMEROS);
  pushMatrix();
  translate(OFFSET_X,OFFSET_Y);  // Amb açò aconseguim que el punt de referència per dibuixar la matriu siga el 160,140
  fill(255);
  strokeWeight(0);
  rect(0,0,315,315);
  
  for (int i = 0; i < 9; i ++ ) {
    for (int j = 0; j < 9; j ++ ) {
      if ( !arrayOcults[i][j] ) {
        posCelaX = j*TAMANYCELA;
        posCelaY = i*TAMANYCELA;  
        
        if (!arrayUsuari[i][j])
          fill(cSombrejat);
        else
          fill(255);
          
        rect(posCelaX, posCelaY, TAMANYCELA, TAMANYCELA);
        fill(0);
        posTextCelaX = j*TAMANYCELA + TAMANYCELA/2;
        posTextCelaY = i*TAMANYCELA + TAMANYCELA/2;
        
        if (arrayUsuari[i][j])
          fill(255,0,0);
          
        text(arraySudoku[i][j], posTextCelaX, posTextCelaY);
      }
    }
  }
  popMatrix();
}
/**
* Quan fem clic sobre una casella que no té número mostra un diàleg amb 
* @param fil fila sobre la que es mostraran les opcions
* @param col columna sobre la que es dibuixaran les opcions
*/
void mostraOpcions(int fil, int col) {

  // Si a aquestos valors els sumes el OFFSET_X i OFFSET_Y donaria el valor absolut.
  optRelativeX = col*TAMANYCELA;
  optRelativeY = fil*TAMANYCELA;
  
  pushMatrix();
  // Primer pas, enfosquir el Sudoku amb un gris per destacar les opcions
  translate(OFFSET_X,OFFSET_Y);
  fill(cSombrejat);
  rect(0,0,315,315);
  
  // Primer marquem la casella a la que volem posar un número.
  fill(cOmbraFosca);
  strokeWeight(1);
  translate(optRelativeX, optRelativeY);
  fill(255,120,60,170);
  rect(0,0,35,35);
  strokeWeight(10);
 
  // Movem el sistema de coordenades al lloc on dibuixarem el punter del tauler d'opcions
  translate(TAMANYCELA/2, TAMANYCELA); // Posicio BOTTOM CENTER de la casella a la que volem posar els números
  stroke(0);
  strokeWeight(0);
  fill(60,240);
  
  // Dibuixem l'ombra
  rect(-45,7,105,105);
  strokeWeight(2);
  fill(240);
  rect(-52,0,105,105);
  
  // Dibuixem el punter del tauler d'opcions
  strokeWeight(1);
  fill(0);
  triangle(-8,0,8,0,0,-8);
  line(-50,35,50,35);
  line(-50,70,50,70);
  line(-15,0,-15,105);
  line(20,0,20,105);
  
  // Posem els números al seu lloc
  text("1",-35,17);
  text("2",0,17);
  text("3",35,17);
  text("4",-35,52);
  text("5",0,52);
  text("6",35,52);
  text("7",-35,87);
  text("8",0,87);
  text("9",35,87);
 
  popMatrix();
  
  // A partir d'ací hem de saber quin és el rang X, Y on podem fer clic triant una opció correcta.
  optHoverXabs = OFFSET_X + optRelativeX - TAMANYCELA; // Des d'aci fins a 105 píxels més
  optHoverYabs = OFFSET_Y + optRelativeY + TAMANYCELA; // Des d'aci fins a 105 píxels més
}
/**
* Una vegada hem inserit un número a una casella del Sudoku ens mostrarà 
* un missatge valid - no valid o enhorabona
*/
void mostraMissatge () {
  titol2();
  emplenarSudoku ();
  dibuixaContenidor  ();
  pushMatrix();
  translate(OFFSET_X,OFFSET_Y);
  // Fem el sombrejat
  fill(cSombrejat);
  rect(0,0,315,315);
  
  // Dibuixem l'ombra
  strokeWeight(0);
  fill(cOmbraFosca);
  rect(75,110,175,105);
  
  strokeWeight(2);
  stroke(0);
  fill(255);
  rect(70,105,175,105);
  fill(0);
  
  textSize(32);
  if(iMissatge == 0) {
    fill(50,200);
    text("Correcte",160,155);
  }
  else if (iMissatge == 1) {
    fill(50,200);
    text("No valid",160,155);
  }
  else if (iMissatge == 2) {
    fill(0,255,0,200);
    text("Enhorabona",160,155);
  }
  popMatrix(); 
}
// ESDEVENIMENTS
/**
* Esdeveniment que s'executa quan fem clic sobre el botó esquerre del ratolí
*/
void mouseClicked() {
  switch (iFaseActual) {
      case JUGANT:
        if(mouseX >= OFFSET_X && mouseX <= OFFSET_X+315 && mouseY >= OFFSET_Y && mouseY <= OFFSET_Y+315) {
          filOpcions = (mouseY-OFFSET_Y) / TAMANYCELA;
          colOpcions = (mouseX-OFFSET_X) / TAMANYCELA;
          
          if (arrayOcults[filOpcions][colOpcions])
            if (mouseX >= OFFSET_X && mouseX <= OFFSET_X+315 && mouseY >= OFFSET_Y && mouseY <= OFFSET_Y+315)
              iFaseActual = MOSTRAOPCIONS;
        }
      break;
      
      case MOSTRAOPCIONS:
        if ( mouseX < optHoverXabs || mouseX > optHoverXabs+105 || mouseY < optHoverYabs || mouseY > optHoverYabs+105)
          iFaseActual = JUGANT;
          
        else {
          iFaseActual = INTRODUINT;  // Per tal que no canvie el requadre opcions de lloc
          
          int f = (mouseY-optHoverYabs)/TAMANYCELA;
          int c = (mouseX-optHoverXabs)/TAMANYCELA;
          
          iValorIntroduit = f*3+c+1;
        }
      break;
      
      case MOSTRAMISSATGE:
        if(iMissatge == 2)
        iFaseActual = INICIANT;
      else
        iFaseActual = JUGANT;
      break;
  }
}
/**
* Esdeveniment que s'executa quan premem qualsevol tecla al teclat
*/
void keyPressed ( ) {
  switch(iFaseActual) {
    case TRIA_DIFICULTAT:
      if (key == '1') {
        iFaseActual       = INICIANT;
        iNivellDificultat = FACIL;
        iNumerosOcultar   = 40;
      }
      else if (key == '2') {
        iFaseActual = INICIANT;
        iNivellDificultat = MITJA;
        iNumerosOcultar = 50;
      }
      else if (key == '3') {
        iFaseActual = INICIANT;
        iNivellDificultat = DIFICIL;
        iNumerosOcultar = 60;
      }
    break;
    
    case MOSTRAMISSATGE:
      if(iMissatge == 2)
        iFaseActual = INICIANT;
      else
        iFaseActual = JUGANT;
    break;
  }
}
