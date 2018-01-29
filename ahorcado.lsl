// LeoSevilla50
// Ahorcado V.2 
// Parte del codigo es del juego del trivial que está publicado aquí:
// http://wiki.secondlife.com/wiki/Trivia   creado por:
// [K] Kira Komarov - 2011, License: GPLv3
// Puedes modificar libremente este scrips
// Solo te pido que me notifiques los cambios y/o mejoras
// leosevilla50@gmail.com
// https://github.com/LeoSevilla/SL-Ahorcado

list MENU1 = [];
list MENU2 = [];
integer listener;
integer MENU_CHANNEL = 1000;
integer SWITCH = TRUE;
//integer acertado;
integer countLetras;

list user_scores = [];
list trivia_lines = [];
key bQuery = NULL_KEY;
integer bLine = 0;
integer comHandle = 0;
string notecard = "";
string palabra;
list Lrespuesta =[];
list answers = []; 
integer itra; 
list Charset_LeftRight      = ["   ","▏","▎","▍","▌","▋","▊","▉","█"];
float Input;
integer Length = 10;
 
string Bars( float Cur, integer Bars, list Charset ){
    // Input    = 0.0 to 1.0
    // Bars     = char length of progress bar
    // Charset  = [Blank,<Shades>,Solid];
    integer Shades = llGetListLength(Charset)-1;
            Cur *= Bars;
    integer Solids  = llFloor( Cur );
    integer Shade   = llRound( (Cur-Solids)*Shades );
    integer Blanks  = Bars - Solids - 1;
    string str;
    while( Solids-- >0 ) str += llList2String( Charset, -1 );
    if( Blanks >= 0 ) str += llList2String( Charset, Shade );
    while( Blanks-- >0 ) str += llList2String( Charset, 0 );
    return str; }
 
// opens menu channel and displays dialog
Dialog(key id, list menu)
{
    llListenRemove(listener);
    listener = llListen(MENU_CHANNEL, "", NULL_KEY, "");
    llDialog(id, "Selecione una categoría de preguntas: ", menu, MENU_CHANNEL);
}
 

qNext(integer q) {
    if(!llGetListLength(trivia_lines)) {//retorna un entero con numero de elementos en lista
        llOwnerSay("Se acabó el juego, ¿otra partida?");
        llSay(0, "Se acabó el juego, ¿otra partida?");
        llOwnerSay("Pulse de nuevo para continuar...");
        llSetColor(<1.000,0.255,0.212>, ALL_SIDES);
        llResetScript();
        SWITCH=TRUE;
    }
    //lista separandas por "#", la 0 es el tema de las preguntas, después pregunta y respuesta 
    list caSplit = llParseString2List(llList2String(trivia_lines, q), ["#"], [""]);
    //la respuesta la metemos en nueva lista
    list answers = (list)llList2String(caSplit, 2);
    palabra = (string)answers;
    integer itra;
    //creamos bucle 
    for(itra=0; itra<llStringLength(palabra); ++itra) {
        string letra = llGetSubString(palabra, itra, itra);
        if(letra == " ") {Lrespuesta += (list)" ";}
        else {Lrespuesta += (list)"-";}
    }
    //borrar la linea con la pregunta y respuestas
    trivia_lines = llDeleteSubList((trivia_lines=[]) + trivia_lines, q, q);
    //presentar la pregunta en el canal publico
    countLetras == 1;
    llSay(0, "[" + llList2String(caSplit, 0) + "]" + " " + llList2String(caSplit, 1) + "\n" + (string)Lrespuesta);
}
  
 
 
default
{
    
    on_rez(integer num) {
       llResetScript(); 
    }
    
    
    state_entry(){
        //llResetScript(); 
        llListenRemove(comHandle);
        user_scores = [];
        trivia_lines = [];
        bQuery = NULL_KEY;
        bLine = 0;
        comHandle = 0;
        Lrespuesta =[];
        answers = [];
        //acertado = FALSE;
        state menuAhorcado;
    } 
} 





state menuAhorcado{
    touch_start(integer numero){
        if(SWITCH) {
            //llSay(0,"true");
            SWITCH = FALSE;
            integer i = 0;
            MENU1 = [];
            MENU2 = [];
         // count the textures in the prim to see if we need pages
            integer c = llGetInventoryNumber(INVENTORY_NOTECARD);
            if (c <= 12)
            {
                for (; i < c; ++i)
                    MENU1 += llGetInventoryName(INVENTORY_NOTECARD, i);
            }
            else
            {        
                for (; i < 11; ++i)
                    MENU1 += llGetInventoryName(INVENTORY_NOTECARD, i);
                if(c > 22)
                    c = 22;
                for (; i < c; ++i)
                    MENU2 += llGetInventoryName(INVENTORY_NOTECARD, i); 
                MENU1 += ">>";
                MENU2 += "<<";                          
            }
            // display the dialog 
            Dialog(llDetectedKey(0), MENU1);
        }else {
            //llSay(0,"FALSE");
            SWITCH = TRUE;
            qNext((integer)llFrand(llGetListLength(trivia_lines)));
            state trivia;   
        }
    }
    listen(integer channel, string name, key id, string message) 
    {
        if (channel == MENU_CHANNEL)
        {
            llListenRemove(listener);  
            if (message == ">>")
            {
                Dialog(id, MENU2);
            }
            else if (message == "<<")
            {
                Dialog(id, MENU1);
            }        
            else                    
            {
                    trivia_lines = [];
                    bLine = 0;
                    llOwnerSay("Leyendo archivo..."+message);
                    Input = 0.0;
                    llSetText( "",<0.004,1.000,0.439>, 1.0 );
                    notecard=message;
                    bQuery = llGetNotecardLine(message, bLine);                
            }      
        }
    }

            
                    
    dataserver(key id, string data) {
        if(id != bQuery) return;
        if(data == EOF) {
            //llOwnerSay("Lectura archivo: " + notecard);
            llSetText( "", <0.004,1.000,0.439>, 1.0 );
            llOwnerSay("Pulse de nuevo para comenzar el juego...");
            llSay(0, "### COMIENZA EL JUEGO ###");
            llSay(0, "Para resolver !r palabra y para buscar letras !l letra");
            bLine = 0;
            return;
        }
        if(data == "") jump next_line;
        trivia_lines += data;
        Input += 0.02 ;
        string Text = Bars( Input, Length, Charset_LeftRight );
        llSetText( Text, <0.004,1.000,0.439>, 1.0 );
        
@next_line;
        bQuery = llGetNotecardLine(notecard, ++bLine);
    }      
        
            

}
 

state trivia
{
    state_entry() {
        comHandle = llListen(0, "", "", "");
        llSetColor(<0.004,1.000,0.439>, ALL_SIDES);
        //llSay(0,"stateentry");
    }
    listen(integer chan,string name,key id,string mes) {
        mes = llToLower(mes);
        list Split = llParseString2List(mes, [""], [""]);
        if (llGetSubString(mes, 0, 0) == "!"   ){
            if(llGetSubString(mes, 1, 1) == "l"){
               string letra = llGetSubString(mes, 3, 3);
                for(itra=0; itra<llStringLength(palabra); ++itra) {
                    if(letra == llGetSubString(palabra, itra, itra)){
                        Lrespuesta = llListReplaceList(Lrespuesta, [letra], itra, itra);
                    }
                }
                llSay(0, (string)Lrespuesta);
                integer index;// default is 0
                countLetras = 0;
                while (index < llGetListLength(Lrespuesta))
                {
                    if (llList2String(Lrespuesta, index)=="-")countLetras =1;
                    //llSay(0, llList2String(Lrespuesta, index));
                    ++index;
                }
                if (countLetras == 0){
                    jump solucion;
                }
            }
        }
        
        if("!r "+palabra != mes) return;
@solucion;
        llSay(0, name + " acertaste! " + mes + " es la respuesta correcta!");
        llSleep(3);
        //acertado = FALSE;
        integer itra;
        for(itra=0; itra<llGetListLength(user_scores); ++itra) {
            list usList = llParseString2List(llList2String(user_scores, itra), ["#"], [""]);
            if(llList2String(usList, 0) == name) {
                user_scores = llListReplaceList((user_scores=[]) + user_scores, (list)(name + "#" + (string)(llList2Integer(usList, 1)+1)), itra, itra);
                jump score_updated;
            }
        }
        user_scores += (list)(name + "#1");
@score_updated;
        Lrespuesta = [];
        //countLetras = 0;
        state puntos;
    }
 
    touch_start(integer num) {
        if(llDetectedKey(0)!=llGetOwner()) return;
        llListenRemove(comHandle);
        llOwnerSay("Ha detenido el juego. Pulse de nuevo para menu");
        SWITCH = TRUE;
        llSetColor(<1.000,0.255,0.212>, ALL_SIDES);
        state default;
    }
 
} 

state puntos {
    state_entry() { 
            integer itra;
            llSay(0, "--- PUNTOS ---");
            for(itra=0; itra<llGetListLength(user_scores); ++itra) {
                list usList = llParseString2List(llList2String(user_scores, itra), ["#"], [""]);
                llSay(0, llList2String(usList, 0) + "'s puntos: " + llList2String(usList, 1));
            }
            llSay(0, "--- PUNTOS ---");
        qNext((integer)llFrand(llGetListLength(trivia_lines)));
        state trivia;
    }
}

