program Arkanoid;

uses allegro;

const
      ScreenWidth = 1000;
      ScreenHeight = 600;

type
      Wymiary_klocka = record
         x1 : integer;
         x2 : integer;
         y1 : integer;
         y2 : integer;
      end;

      Wspolrzedne_bonusow = record
         bonus_x : integer;
         bonus_y : integer;
         cd : boolean;
      end;


var
      Trwanie_Gry, Wybor : boolean;
      key : char;
      pozycja_belki : integer;
      temp_pozycja_belki : integer;
      kulka_x, kulka_y : integer;
      temp_kulka_x, temp_kulka_y : integer;
      kierunek_kulki : byte;
      bufor : ^al_bitmap;
      m1, m2 : integer;
      i,j : integer;
      ktory_klocek : Array[1..75] of Wymiary_klocka;    //rzedy po 15 klockow!
      klocek_exist : Array[1..75] of boolean;
      ktory_bonus : Array[1..10] of Wspolrzedne_bonusow;
      temp_ktory_bonus : Array[1..11] of Wspolrzedne_bonusow;
      rozmiar, zycia: byte;
      przylepienie : boolean;
      start : boolean;

label nowa_gra;

procedure inicjalizacja;
begin

      //#include <allegro.h>
      al_init;
      al_install_keyboard;
      //al_install_timer;
      //al_install_sound(AL_DIGI_AUTODETECT, AL_MIDI_AUTODETECT);
      //glebia koloru 8(256kolorow), 16, 32...
      al_set_color_depth(32);
      al_set_palette(al_default_palette);
      //wlaczamy tryb graficzny (uzyje automatycznie wykrytego sterownika) [w oknie]
      al_set_gfx_mode(Al_GFX_AUTODETECT_WINDOWED,ScreenWidth,ScreenHeight,0,0);
      //nazwa okna
      al_set_window_title('ARKANOID');

end;

procedure rysowanie_tla;
begin

      bufor:=nil;
      bufor:=al_create_bitmap(1000,600);
      al_rectfill(bufor,0,0,800,600,al_makecol(128, 128, 130));
      al_rectfill(bufor,5,5,795,595,al_makecol(0,0,0));
      al_rectfill(bufor,800,0,804,600,al_makecol(255,191,0));
      al_rectfill(bufor,804,0,1000,600,al_makecol(128,30,30));

      al_rectfill(bufor,810,440,990,500,al_makecol(255,255,255));
      al_rectfill(bufor,812,442,988,498,al_makecol(0,0,0));

      al_circlefill(bufor, 825, 450, 5, al_makecol(226,30,19));
      al_circlefill(bufor, 825, 470, 5, al_makecol(147,246,19));
      al_circlefill(bufor, 825, 490, 5, al_makecol(127,255,212));
      al_textout_centre_ex(bufor,al_font,':wydluzenie paletki', 909, 445, al_makecol(255,255,255), -1);
      al_textout_centre_ex(bufor,al_font,':dodatkowe zycie', 898, 465, al_makecol(255,255,255), -1);
      al_textout_centre_ex(bufor,al_font,':przylepienie', 887, 485, al_makecol(255,255,255), -1);
      al_textout_centre_ex(bufor,al_font,'zycia:', 835, 510, al_makecol(255,255,255), -1);

end;

procedure startup;
begin

      al_acquire_screen();
      al_rectfill(bufor, pozycja_belki, 560, pozycja_belki+30, 570, al_makecol(0, 0, 255));
      al_circlefill (bufor, kulka_x, kulka_y, 5, al_makecol( 128, 255, 0));
      al_draw_sprite(al_screen, bufor, 0,0);
      al_release_screen();

end;

procedure ruch_kulki;
begin

      temp_kulka_x:=kulka_x;
      temp_kulka_y:=kulka_y;

      {0 - góra, lewo
       1 - góra, prawo
       2 - dól, lewo
       3 - dól, prawo}

      {w przypadku odbicia od scian}
      if(kierunek_kulki=0) and (kulka_x=11) then kierunek_kulki:=1;
      if(kierunek_kulki=1) and (kulka_x=789) then kierunek_kulki:=0;
      if(kierunek_kulki=2) and (kulka_x=11) then kierunek_kulki:=3;
      if(kierunek_kulki=3) and (kulka_x=789) then kierunek_kulki:=2;

      {leci góra, lewo}
      if(kierunek_kulki=0) and (kulka_x>10) and (kulka_x<790) and (kulka_y>=10) then
      begin
          if(kulka_y=10) then
          kierunek_kulki:=2
          else begin
              kulka_x:=kulka_x-1;
              kulka_y:=kulka_y-1;
          end;
      end

      {leci góra, prawo}
      else if(kierunek_kulki=1) and (kulka_x>10) and (kulka_x<790) and (kulka_y>=10) then
      begin
          if(kulka_y=10) then
          kierunek_kulki:=3
          else begin
              kulka_x:=kulka_x+1;
              kulka_y:=kulka_y-1;
          end;
      end

      {leci dol, lewo}
      else if(kierunek_kulki=2) and (kulka_x>10) and (kulka_x<790) and (kulka_y<=580) then
      begin
          if(kulka_y=555) and (kulka_x>=pozycja_belki) and (kulka_x<=pozycja_belki+rozmiar) then
          kierunek_kulki:=0
          else
          begin
               kulka_y:=kulka_y+1;
               kulka_x:=kulka_x-1;
          end;
      end

      {leci dol, prawo}
      else if(kierunek_kulki=3) and (kulka_x>10) and (kulka_x<790) and (kulka_y<=580) then
      begin
          if(kulka_y=555) and (kulka_x>=pozycja_belki) and (kulka_x<=pozycja_belki+rozmiar) then
          kierunek_kulki:=1
          else
          begin
               kulka_y:=kulka_y+1;
               kulka_x:=kulka_x+1;
          end;
      end;

      {rysowanie z buforem}
      al_acquire_screen();
      al_circlefill(bufor, temp_kulka_x, temp_kulka_y, 5, al_makecol(0,0,0));
      al_circlefill(bufor, kulka_x, kulka_y, 5, al_makecol(255,255,255));
      al_draw_sprite(al_screen, bufor, 0, 0);
      al_release_screen();
      al_rest(0);

end;

procedure cegielki;
begin

      for i:=0 to 14 do
      begin
           al_rectfill(bufor,28+i*50,40,76+i*50,60,al_makecol(192,170,190));
           al_rectfill(bufor,30+i*50,42,74+i*50,57,al_makecol(0,128,0));

           al_rectfill(bufor,28+i*50,62,76+i*50,82,al_makecol(128,128,128));
           al_rectfill(bufor,30+i*50,64,74+i*50,80,al_makecol(255,191,20));

           al_rectfill(bufor,28+i*50,84,76+i*50,104,al_makecol(128,128,0));
           al_rectfill(bufor,30+i*50,86,74+i*50,102,al_makecol(128,0,128));

           al_rectfill(bufor,28+i*50,106,76+i*50,126,al_makecol	(128,128,128));
           al_rectfill(bufor,30+i*50,108,74+i*50,124,al_makecol	(0,0,230));

           al_rectfill(bufor,28+i*50,128,76+i*50,148,al_makecol(128,128,0));
           al_rectfill(bufor,30+i*50,130,74+i*50,146,al_makecol(195,68,68));
      end;

      for i:=1 to 75 do
          klocek_exist[i]:=TRUE;

      {wpisywanie wspolrzednych do cegielek 1-15 (pierwszy rzad)}
      j:=0;
      for i:=1 to 15 do
      begin
           ktory_klocek[i].x1:=28+50*j;
           ktory_klocek[i].x2:=77+50*j;
           ktory_klocek[i].y1:=40;
           ktory_klocek[i].y2:=60;
           j:=j+1;
      end;

      {wpisywanie wspolrzednych do cegielek 16-30 (drugi rzad)}
      j:=0;
      for i:=16 to 30 do
      begin
           ktory_klocek[i].x1:=28+50*j;
           ktory_klocek[i].x2:=77+50*j;
           ktory_klocek[i].y1:=62;
           ktory_klocek[i].y2:=82;
           j:=j+1;
      end;

      {wpisywanie wspolrzednych do cegielek 31-45 (trzeci rzad)}
      j:=0;
      for i:=31 to 45 do
      begin
           ktory_klocek[i].x1:=28+50*j;
           ktory_klocek[i].x2:=77+50*j;
           ktory_klocek[i].y1:=84;
           ktory_klocek[i].y2:=104;
           j:=j+1;
      end;

      {wpisywanie wspolrzednych do cegielek 46-60 (czwarty rzad)}
      j:=0;
      for i:=46 to 60 do
      begin
           ktory_klocek[i].x1:=28+50*j;
           ktory_klocek[i].x2:=77+50*j;
           ktory_klocek[i].y1:=106;
           ktory_klocek[i].y2:=126;
           j:=j+1;
      end;

      {wpisywanie wspolrzednych do cegielek 61-75 (piaty rzad)}
      j:=0;
      for i:=61 to 75 do
      begin
           ktory_klocek[i].x1:=28+50*j;
           ktory_klocek[i].x2:=77+50*j;
           ktory_klocek[i].y1:=128;
           ktory_klocek[i].y2:=148;
           j:=j+1;
      end;

end;

procedure kolizja_cegielki;
begin

      {kulka leci gora prawo}
      if (kierunek_kulki=1) then
      for i:=1 to 75 do
      begin
           {styczna od dolu}
           if(kulka_x>=ktory_klocek[i].x1) and (kulka_x<=ktory_klocek[i].x2) and (kulka_y-ktory_klocek[i].y2<=5) and (kulka_y-ktory_klocek[i].y2>0) and (klocek_exist[i]=TRUE) then
           begin
                klocek_exist[i]:=FALSE;
                al_rectfill(bufor,ktory_klocek[i].x1,ktory_klocek[i].y1,ktory_klocek[i].x2,ktory_klocek[i].y2,al_makecol(0,0,0));
                kierunek_kulki:=3;
                break;
           end;
           {styczna od lewej}
           if(kulka_y>=ktory_klocek[i].y1) and (kulka_y<=ktory_klocek[i].y2) and (kulka_x-ktory_klocek[i].x1<=5) and (kulka_x-ktory_klocek[i].x1>0) and (klocek_exist[i]=TRUE) then
           begin
                klocek_exist[i]:=FALSE;
                al_rectfill(bufor,ktory_klocek[i].x1,ktory_klocek[i].y1,ktory_klocek[i].x2,ktory_klocek[i].y2,al_makecol(0,0,0));
                kierunek_kulki:=0;
                break;
           end;
      end;

      {kulka leci gora lewo}
      if (kierunek_kulki=0) then
      for i:=1 to 75 do
      begin
           {styczna od dolu}
           if(kulka_x>=ktory_klocek[i].x1) and (kulka_x<=ktory_klocek[i].x2) and (kulka_y-ktory_klocek[i].y2<=5) and (kulka_y-ktory_klocek[i].y2>0) and (klocek_exist[i]=TRUE) then
           begin
                klocek_exist[i]:=FALSE;
                al_rectfill(bufor,ktory_klocek[i].x1,ktory_klocek[i].y1,ktory_klocek[i].x2,ktory_klocek[i].y2,al_makecol(0,0,0));
                kierunek_kulki:=2;
                break;
           end;
           {styczna od prawej}
           if(kulka_y>=ktory_klocek[i].y1) and (kulka_y<=ktory_klocek[i].y2) and (kulka_x-ktory_klocek[i].x2<=5) and (kulka_x-ktory_klocek[i].x2>0) and (klocek_exist[i]=TRUE) then
           begin
                klocek_exist[i]:=FALSE;
                al_rectfill(bufor,ktory_klocek[i].x1,ktory_klocek[i].y1,ktory_klocek[i].x2,ktory_klocek[i].y2,al_makecol(0,0,0));
                kierunek_kulki:=1;
                break;
           end;
      end;

      {kulka leci dol prawo}
      if (kierunek_kulki=3) then
      for i:=1 to 75 do
      begin
           {styczna od góry}
           if(kulka_x>=ktory_klocek[i].x1) and (kulka_x<=ktory_klocek[i].x2) and (ktory_klocek[i].y1-kulka_y<=5) and (ktory_klocek[i].y1-kulka_y>0) and (klocek_exist[i]=TRUE) then
           begin
                klocek_exist[i]:=FALSE;
                al_rectfill(bufor,ktory_klocek[i].x1,ktory_klocek[i].y1,ktory_klocek[i].x2,ktory_klocek[i].y2,al_makecol(0,0,0));
                kierunek_kulki:=1;
           end;
           {styczna od lewej}
           if(kulka_y>=ktory_klocek[i].y1) and (kulka_y<=ktory_klocek[i].y2) and (ktory_klocek[i].x1-kulka_x<=5) and (ktory_klocek[i].x1-kulka_x>0) and (klocek_exist[i]=TRUE) then
           begin
                klocek_exist[i]:=FALSE;
                al_rectfill(bufor,ktory_klocek[i].x1,ktory_klocek[i].y1,ktory_klocek[i].x2,ktory_klocek[i].y2,al_makecol(0,0,0));
                kierunek_kulki:=2;
           end;
      end;

      {kulka leci dol lewo}
      if (kierunek_kulki=2) then
      for i:=1 to 75 do
      begin
           {styczna od góry}
           if(kulka_x>=ktory_klocek[i].x1) and (kulka_x<=ktory_klocek[i].x2) and (ktory_klocek[i].y1-kulka_y<=5) and (ktory_klocek[i].y1-kulka_y>0) and (klocek_exist[i]=TRUE) then
           begin
                klocek_exist[i]:=FALSE;
                al_rectfill(bufor,ktory_klocek[i].x1,ktory_klocek[i].y1,ktory_klocek[i].x2,ktory_klocek[i].y2,al_makecol(0,0,0));
                kierunek_kulki:=0;
           end;
           {styczna od prawej}
           if(kulka_y>=ktory_klocek[i].y1) and (kulka_y<=ktory_klocek[i].y2) and (kulka_x-ktory_klocek[i].x2<=5) and (kulka_x-ktory_klocek[i].x2>0) and (klocek_exist[i]=TRUE) then
           begin
                klocek_exist[i]:=FALSE;
                al_rectfill(bufor,ktory_klocek[i].x1,ktory_klocek[i].y1,ktory_klocek[i].x2,ktory_klocek[i].y2,al_makecol(0,0,0));
                kierunek_kulki:=3;
           end;
      end;

end;

procedure inicjowanie_gry;
begin

      {ustawienia planszy na start}
      //al_clear_to_color(bufor,al_makecol(0,0,0));
      rysowanie_tla;
      pozycja_belki:=385;
      temp_pozycja_belki:=385;
      kulka_x:=400;
      kulka_y:=200;
      temp_kulka_x:=400;
      temp_kulka_y:=200;
      randomize;
      kierunek_kulki:=random(2)+2;
      rozmiar:=50;
      zycia:=3;
      przylepienie:=FALSE;
      start:=TRUE;
      for i:=1 to 11 do begin
          ktory_bonus[i].cd:=TRUE;
      end;
      ktory_bonus[1].bonus_y:=140;
      ktory_bonus[1].bonus_x:=651;
      ktory_bonus[2].bonus_y:=116;
      ktory_bonus[2].bonus_x:=601;
      ktory_bonus[3].bonus_y:=92;
      ktory_bonus[3].bonus_x:=251;
      ktory_bonus[4].bonus_y:=72;
      ktory_bonus[4].bonus_x:=351;
      ktory_bonus[5].bonus_y:=50;
      ktory_bonus[5].bonus_x:=701;

      ktory_bonus[6].bonus_y:=116;
      ktory_bonus[6].bonus_x:=401;
      ktory_bonus[7].bonus_y:=94;
      ktory_bonus[7].bonus_x:=501;
      ktory_bonus[8].bonus_y:=72;
      ktory_bonus[8].bonus_x:=51;

      ktory_bonus[9].bonus_y:=138;
      ktory_bonus[9].bonus_x:=151;
      ktory_bonus[10].bonus_y:=72;
      ktory_bonus[10].bonus_x:=651;
      ktory_bonus[11].bonus_y:=50;
      ktory_bonus[11].bonus_x:=201;


end;

procedure sterowanie_belka;
begin

      temp_pozycja_belki:=pozycja_belki;
      if al_keypressed() then
      begin
          key:=char(al_readkey);
          if(key<>#27) then // #27[ESC]
          begin
              if(key=#97) and (pozycja_belki>5) then pozycja_belki:=pozycja_belki-10;   //#97[A]
              if(key=#100) and (pozycja_belki<795-rozmiar) then pozycja_belki:=pozycja_belki+10;    //#100[D]
          end
          else Trwanie_Gry:=FALSE;
      end;

      {rysowanie z buforem}
      al_acquire_screen();
      al_rectfill(bufor,temp_pozycja_belki,560,temp_pozycja_belki+rozmiar,570,al_makecol(0,0,0));
      al_rectfill(bufor,pozycja_belki,560,pozycja_belki+rozmiar,570,al_makecol(65,105,225));
      al_release_screen();

end;

procedure menu;
begin

      if al_keypressed() then
      begin
          key:=char(al_readkey);
          if(key<>#13) then // #13[ENTER]
          begin
              if(key=#119) then begin m1:=255; m2:=0; end;  //#119[W]
              if(key=#115) then begin m1:=0; m2:=255; end;  //#115[S]
          end else
          begin
          if (m1=255) then Wybor:=TRUE
          else halt(1);
          end;
      end;

      al_acquire_screen();
      al_textout_centre_ex(bufor,al_font,'NOWA GRA',900, 290, al_makecol(m1,m1,m1), -1);
      al_textout_centre_ex(bufor,al_font,'  EXIT  ',900, 310, al_makecol(m2,m2,m2), -1);
      al_draw_sprite(al_screen,bufor,0,0);
      al_release_screen();

end;

procedure stan;
begin
      if(start=TRUE) then begin
          al_rectfill(al_screen,ScreenWidth div 3-100,200,ScreenWidth div 3+200,400,al_makecol(255,165,0));
          al_rectfill(al_screen,ScreenWidth div 3-95,205,ScreenWidth div 3+195,395,al_makecol(255,255,255));
          al_textout_centre_ex(al_screen,al_font,'START',ScreenWidth div 3+50, ScreenHeight div 2, al_makecol(0,0,0), -1);
          start:=FALSE;
          al_readkey();
      end;


      if(kulka_y>575) then begin
          zycia:=zycia-1;
          rozmiar:=50;
          przylepienie:=FALSE;
          al_rectfill(al_screen,ScreenWidth div 3-100,200,ScreenWidth div 3+200,400,al_makecol(255,165,0));
          al_rectfill(al_screen,ScreenWidth div 3-95,205,ScreenWidth div 3+195,395,al_makecol(255,255,255));
          al_textout_centre_ex(al_screen,al_font,' tracisz życie! ',ScreenWidth div 3+50, ScreenHeight div 2-10, al_makecol(0,0,0), -1);
          al_circlefill(bufor, kulka_x, kulka_y, 5, al_makecol(0,0,0));
          al_readkey();
          pozycja_belki:=385;
          temp_pozycja_belki:=385;
          kulka_x:=400;
          kulka_y:=200;
          temp_kulka_x:=400;
          temp_kulka_y:=200;
          randomize;
          kierunek_kulki:=random(2)+2;
      end;
      if(zycia=0) then Trwanie_Gry:=FALSE;

      if(zycia=0) then begin
          al_rectfill(bufor,810,530,990,540,al_makecol(128,30,30));
      end;

      if(zycia=1) then begin
          al_rectfill(bufor,810,530,990,540,al_makecol(128,30,30));

          al_rectfill(bufor,810,530,830,540,al_makecol(207,41,41));
          al_rectfill(bufor,813,530,827,540,al_makecol(255,255,255));
      end;

      if(zycia=2) then begin
          al_rectfill(bufor,810,530,990,540,al_makecol(128,30,30));

          al_rectfill(bufor,810,530,830,540,al_makecol(207,41,41));
          al_rectfill(bufor,813,530,827,540,al_makecol(255,255,255));
          al_rectfill(bufor,840,530,860,540,al_makecol(207,41,41));
          al_rectfill(bufor,843,530,857,540,al_makecol(255,255,255));
      end;

      if(zycia=3) then begin
          al_rectfill(bufor,810,530,990,540,al_makecol(128,30,30));

          al_rectfill(bufor,810,530,830,540,al_makecol(207,41,41));
          al_rectfill(bufor,813,530,827,540,al_makecol(255,255,255));
          al_rectfill(bufor,840,530,860,540,al_makecol(207,41,41));
          al_rectfill(bufor,843,530,857,540,al_makecol(255,255,255));
          al_rectfill(bufor,870,530,890,540,al_makecol(207,41,41));
          al_rectfill(bufor,873,530,887,540,al_makecol(255,255,255));
      end;

      if(zycia=4) then begin
          al_rectfill(bufor,810,530,990,540,al_makecol(128,30,30));

          al_rectfill(bufor,810,530,830,540,al_makecol(207,41,41));
          al_rectfill(bufor,813,530,827,540,al_makecol(255,255,255));
          al_rectfill(bufor,840,530,860,540,al_makecol(207,41,41));
          al_rectfill(bufor,843,530,857,540,al_makecol(255,255,255));
          al_rectfill(bufor,870,530,890,540,al_makecol(207,41,41));
          al_rectfill(bufor,873,530,887,540,al_makecol(255,255,255));
          al_rectfill(bufor,900,530,920,540,al_makecol(207,41,41));
          al_rectfill(bufor,903,530,917,540,al_makecol(255,255,255));
      end;

      if(zycia=5) then begin
          al_rectfill(bufor,810,530,990,540,al_makecol(128,30,30));

          al_rectfill(bufor,810,530,830,540,al_makecol(207,41,41));
          al_rectfill(bufor,813,530,827,540,al_makecol(255,255,255));
          al_rectfill(bufor,840,530,860,540,al_makecol(207,41,41));
          al_rectfill(bufor,843,530,857,540,al_makecol(255,255,255));
          al_rectfill(bufor,870,530,890,540,al_makecol(207,41,41));
          al_rectfill(bufor,873,530,887,540,al_makecol(255,255,255));
          al_rectfill(bufor,900,530,920,540,al_makecol(207,41,41));
          al_rectfill(bufor,903,530,917,540,al_makecol(255,255,255));
          al_rectfill(bufor,930,530,950,540,al_makecol(207,41,41));
          al_rectfill(bufor,933,530,947,540,al_makecol(255,255,255));
      end;

      if(zycia=6) then begin
          al_rectfill(bufor,810,530,990,540,al_makecol(128,30,30));

          al_rectfill(bufor,810,530,830,540,al_makecol(207,41,41));
          al_rectfill(bufor,813,530,827,540,al_makecol(255,255,255));
          al_rectfill(bufor,840,530,860,540,al_makecol(207,41,41));
          al_rectfill(bufor,843,530,857,540,al_makecol(255,255,255));
          al_rectfill(bufor,870,530,890,540,al_makecol(207,41,41));
          al_rectfill(bufor,873,530,887,540,al_makecol(255,255,255));
          al_rectfill(bufor,900,530,920,540,al_makecol(207,41,41));
          al_rectfill(bufor,903,530,917,540,al_makecol(255,255,255));
          al_rectfill(bufor,930,530,950,540,al_makecol(207,41,41));
          al_rectfill(bufor,933,530,947,540,al_makecol(255,255,255));
          al_rectfill(bufor,960,530,980,540,al_makecol(207,41,41));
          al_rectfill(bufor,963,530,977,540,al_makecol(255,255,255));
      end;

end;

procedure paletka_bonus;
begin
      for i:=1 to 11 do begin
          temp_ktory_bonus[i].bonus_x:=ktory_bonus[i].bonus_x;
          temp_ktory_bonus[i].bonus_y:=ktory_bonus[i].bonus_y;
      end;

      //wydluzenie paletki

      if((klocek_exist[73]=FALSE) and (ktory_bonus[1].cd=TRUE)) then begin
             ktory_bonus[1].bonus_y:=ktory_bonus[1].bonus_y+2;
             if(ktory_bonus[1].bonus_y=556) and (ktory_bonus[1].bonus_x>=pozycja_belki) and (ktory_bonus[1].bonus_x<=pozycja_belki+rozmiar) then begin
                 rozmiar:=80;
                 al_circlefill(bufor, ktory_bonus[1].bonus_x, ktory_bonus[1].bonus_y+2, 5, al_makecol(0,0,0));
                 ktory_bonus[1].cd:=FALSE;
             end;

      al_acquire_screen();
      al_circlefill(bufor, temp_ktory_bonus[1].bonus_x, temp_ktory_bonus[1].bonus_y, 5, al_makecol(0,0,0));
      al_circlefill(bufor, ktory_bonus[1].bonus_x, ktory_bonus[1].bonus_y, 5, al_makecol(226,30,19));
      al_draw_sprite(al_screen, bufor, 0, 0);
      al_release_screen();
      end;

      if((klocek_exist[42]=FALSE) and (ktory_bonus[2].cd=TRUE)) then begin
             ktory_bonus[2].bonus_y:=ktory_bonus[2].bonus_y+2;
             if(ktory_bonus[2].bonus_y=556) and (ktory_bonus[2].bonus_x>=pozycja_belki) and (ktory_bonus[2].bonus_x<=pozycja_belki+rozmiar) then begin
                 rozmiar:=80;
                 al_circlefill(bufor, ktory_bonus[2].bonus_x, ktory_bonus[2].bonus_y+2, 5, al_makecol(0,0,0));
                 ktory_bonus[2].cd:=FALSE;
             end;

      al_acquire_screen();
      al_circlefill(bufor, temp_ktory_bonus[2].bonus_x, temp_ktory_bonus[2].bonus_y, 5, al_makecol(0,0,0));
      al_circlefill(bufor, ktory_bonus[2].bonus_x, ktory_bonus[2].bonus_y, 5, al_makecol(226,30,19));
      al_draw_sprite(al_screen, bufor, 0, 0);
      al_release_screen();
      end;

      if((klocek_exist[35]=FALSE) and (ktory_bonus[3].cd=TRUE)) then begin
             ktory_bonus[3].bonus_y:=ktory_bonus[3].bonus_y+2;
             if(ktory_bonus[3].bonus_y=556) and (ktory_bonus[3].bonus_x>=pozycja_belki) and (ktory_bonus[3].bonus_x<=pozycja_belki+rozmiar) then begin
                 rozmiar:=80;
                 al_circlefill(bufor, ktory_bonus[3].bonus_x, ktory_bonus[3].bonus_y+2, 5, al_makecol(0,0,0));
                 ktory_bonus[3].cd:=FALSE;
             end;

      al_acquire_screen();
      al_circlefill(bufor, temp_ktory_bonus[3].bonus_x, temp_ktory_bonus[3].bonus_y, 5, al_makecol(0,0,0));
      al_circlefill(bufor, ktory_bonus[3].bonus_x, ktory_bonus[3].bonus_y, 5, al_makecol(226,30,19));
      al_draw_sprite(al_screen, bufor, 0, 0);
      al_release_screen();
      end;

      if((klocek_exist[22]=FALSE) and (ktory_bonus[4].cd=TRUE)) then begin
             ktory_bonus[4].bonus_y:=ktory_bonus[4].bonus_y+2;
             if(ktory_bonus[4].bonus_y=556) and (ktory_bonus[4].bonus_x>=pozycja_belki) and (ktory_bonus[4].bonus_x<=pozycja_belki+rozmiar) then begin
                 rozmiar:=80;
                 al_circlefill(bufor, ktory_bonus[4].bonus_x, ktory_bonus[4].bonus_y+2, 5, al_makecol(0,0,0));
                 ktory_bonus[4].cd:=FALSE;
             end;

      al_acquire_screen();
      al_circlefill(bufor, temp_ktory_bonus[4].bonus_x, temp_ktory_bonus[4].bonus_y, 5, al_makecol(0,0,0));
      al_circlefill(bufor, ktory_bonus[4].bonus_x, ktory_bonus[4].bonus_y, 5, al_makecol(226,30,19));
      al_draw_sprite(al_screen, bufor, 0, 0);
      al_release_screen();
      end;


      if((klocek_exist[14]=FALSE) and (ktory_bonus[5].cd=TRUE)) then begin
             ktory_bonus[5].bonus_y:=ktory_bonus[5].bonus_y+2;
             if(ktory_bonus[5].bonus_y=556) and (ktory_bonus[5].bonus_x>=pozycja_belki) and (ktory_bonus[5].bonus_x<=pozycja_belki+rozmiar) then begin
                 rozmiar:=80;
                 al_circlefill(bufor, ktory_bonus[5].bonus_x, ktory_bonus[5].bonus_y+2, 5, al_makecol(0,0,0));
                 ktory_bonus[5].cd:=FALSE;
             end;

      al_acquire_screen();
      al_circlefill(bufor, temp_ktory_bonus[5].bonus_x, temp_ktory_bonus[5].bonus_y, 5, al_makecol(0,0,0));
      al_circlefill(bufor, ktory_bonus[5].bonus_x, ktory_bonus[5].bonus_y, 5, al_makecol(226,30,19));
      al_draw_sprite(al_screen, bufor, 0, 0);
      al_release_screen();
      end;

      //zycia

      if((klocek_exist[53]=FALSE) and (ktory_bonus[6].cd=TRUE)) then begin
             ktory_bonus[6].bonus_y:=ktory_bonus[6].bonus_y+2;
             if(ktory_bonus[6].bonus_y=556) and (ktory_bonus[6].bonus_x>=pozycja_belki) and (ktory_bonus[6].bonus_x<=pozycja_belki+rozmiar) then begin
                 zycia:=zycia+1;
                 al_circlefill(bufor, ktory_bonus[6].bonus_x, ktory_bonus[6].bonus_y+2, 5, al_makecol(0,0,0));
                 ktory_bonus[6].cd:=FALSE;
             end;

      al_acquire_screen();
      al_circlefill(bufor, temp_ktory_bonus[6].bonus_x, temp_ktory_bonus[6].bonus_y, 5, al_makecol(0,0,0));
      al_circlefill(bufor, ktory_bonus[6].bonus_x, ktory_bonus[6].bonus_y, 5, al_makecol(147,246,19));
      al_draw_sprite(al_screen, bufor, 0, 0);
      al_release_screen();
      end;

      if((klocek_exist[40]=FALSE) and (ktory_bonus[7].cd=TRUE)) then begin
             ktory_bonus[7].bonus_y:=ktory_bonus[7].bonus_y+2;
             if(ktory_bonus[7].bonus_y=556) and (ktory_bonus[7].bonus_x>=pozycja_belki) and (ktory_bonus[7].bonus_x<=pozycja_belki+rozmiar) then begin
                 zycia:=zycia+1;
                 al_circlefill(bufor, ktory_bonus[7].bonus_x, ktory_bonus[7].bonus_y+2, 5, al_makecol(0,0,0));
                 ktory_bonus[7].cd:=FALSE;
             end;

      al_acquire_screen();
      al_circlefill(bufor, temp_ktory_bonus[7].bonus_x, temp_ktory_bonus[7].bonus_y, 5, al_makecol(0,0,0));
      al_circlefill(bufor, ktory_bonus[7].bonus_x, ktory_bonus[7].bonus_y, 5, al_makecol(147,246,19));
      al_draw_sprite(al_screen, bufor, 0, 0);
      al_release_screen();
      end;

      if((klocek_exist[16]=FALSE) and (ktory_bonus[8].cd=TRUE)) then begin
             ktory_bonus[8].bonus_y:=ktory_bonus[8].bonus_y+2;
             if(ktory_bonus[8].bonus_y=556) and (ktory_bonus[8].bonus_x>=pozycja_belki) and (ktory_bonus[8].bonus_x<=pozycja_belki+rozmiar) then begin
                 zycia:=zycia+1;
                 al_circlefill(bufor, ktory_bonus[8].bonus_x, ktory_bonus[8].bonus_y+2, 5, al_makecol(0,0,0));
                 ktory_bonus[8].cd:=FALSE;
             end;

      al_acquire_screen();
      al_circlefill(bufor, temp_ktory_bonus[8].bonus_x, temp_ktory_bonus[8].bonus_y, 5, al_makecol(0,0,0));
      al_circlefill(bufor, ktory_bonus[8].bonus_x, ktory_bonus[8].bonus_y, 5, al_makecol(147,246,19));
      al_draw_sprite(al_screen, bufor, 0, 0);
      al_release_screen();
      end;

      //przylepienie

      if((klocek_exist[63]=FALSE) and (ktory_bonus[9].cd=TRUE)) then begin
             ktory_bonus[9].bonus_y:=ktory_bonus[9].bonus_y+2;
             if(ktory_bonus[9].bonus_y=556) and (ktory_bonus[9].bonus_x>=pozycja_belki) and (ktory_bonus[9].bonus_x<=pozycja_belki+rozmiar) then begin
                 przylepienie:=TRUE;
                 al_circlefill(bufor, ktory_bonus[9].bonus_x, ktory_bonus[9].bonus_y+2, 5, al_makecol(0,0,0));
                 ktory_bonus[9].cd:=FALSE;
             end;

      al_acquire_screen();
      al_circlefill(bufor, temp_ktory_bonus[9].bonus_x, temp_ktory_bonus[9].bonus_y, 5, al_makecol(0,0,0));
      al_circlefill(bufor, ktory_bonus[9].bonus_x, ktory_bonus[9].bonus_y, 5, al_makecol(127,255,212));
      al_draw_sprite(al_screen, bufor, 0, 0);
      al_release_screen();
      end;

      if((klocek_exist[28]=FALSE) and (ktory_bonus[10].cd=TRUE)) then begin
             ktory_bonus[10].bonus_y:=ktory_bonus[10].bonus_y+2;
             if(ktory_bonus[10].bonus_y=556) and (ktory_bonus[10].bonus_x>=pozycja_belki) and (ktory_bonus[10].bonus_x<=pozycja_belki+rozmiar) then begin
                 przylepienie:=TRUE;
                 al_circlefill(bufor, ktory_bonus[10].bonus_x, ktory_bonus[10].bonus_y+2, 5, al_makecol(0,0,0));
                 ktory_bonus[10].cd:=FALSE;
             end;

      al_acquire_screen();
      al_circlefill(bufor, temp_ktory_bonus[10].bonus_x, temp_ktory_bonus[10].bonus_y, 5, al_makecol(0,0,0));
      al_circlefill(bufor, ktory_bonus[10].bonus_x, ktory_bonus[10].bonus_y, 5, al_makecol(127,255,212));
      al_draw_sprite(al_screen, bufor, 0, 0);
      al_release_screen();
      end;

      if((klocek_exist[4]=FALSE) and (ktory_bonus[11].cd=TRUE)) then begin
             ktory_bonus[11].bonus_y:=ktory_bonus[11].bonus_y+2;
             if(ktory_bonus[11].bonus_y=556) and (ktory_bonus[11].bonus_x>=pozycja_belki) and (ktory_bonus[11].bonus_x<=pozycja_belki+rozmiar) then begin
                 przylepienie:=TRUE;
                 al_circlefill(bufor, ktory_bonus[11].bonus_x, ktory_bonus[11].bonus_y+2, 5, al_makecol(0,0,0));
                 ktory_bonus[11].cd:=FALSE;
             end;

      al_acquire_screen();
      al_circlefill(bufor, temp_ktory_bonus[11].bonus_x, temp_ktory_bonus[11].bonus_y, 5, al_makecol(0,0,0));
      al_circlefill(bufor, ktory_bonus[11].bonus_x, ktory_bonus[11].bonus_y, 5, al_makecol(127,255,212));
      al_draw_sprite(al_screen, bufor, 0, 0);
      al_release_screen();
      end;

      for i:=1 to 11 do begin
       if(ktory_bonus[i].cd=FALSE) then
          al_circlefill(bufor, ktory_bonus[i].bonus_x, ktory_bonus[i].bonus_y, 5, al_makecol(0,0,0));
          al_rectfill(bufor,pozycja_belki,560,pozycja_belki+rozmiar,570,al_makecol(0,0,0));
      end;

end;

procedure bonus_przylep;
begin

      if(przylepienie=TRUE) and (kulka_y=555) then begin
          temp_kulka_x:=kulka_x;
          temp_kulka_y:=kulka_y;

          if al_keypressed() then
          begin
              key:=char(al_readkey);
              if(key<>#27) then // #27[ESC]
              begin
                  if(key=#97) and (pozycja_belki>5) then kulka_x:=kulka_x-10;   //#97[A]
                  if(key=#100) and (pozycja_belki<795-rozmiar) then kulka_x:=kulka_x+10;    //#100[D]
                  if(key=#32) then begin
                      if(kierunek_kulki=2) then kierunek_kulki:=0
                      else if(kierunek_kulki=3) then kierunek_kulki:=1;
                  end;
              end;
          end;

          {rysowanie z buforem}
          al_acquire_screen();
          al_circlefill(bufor, temp_kulka_x, temp_kulka_y, 5, al_makecol(0,0,0));
          al_circlefill(bufor, kulka_x, kulka_y, 5, al_makecol(255,255,255));
          al_draw_sprite(al_screen, bufor, 0, 0);
          al_release_screen();
      end;
end;

begin

      inicjalizacja;
      nowa_gra:
      inicjowanie_gry;
      startup;
      cegielki;
      Trwanie_Gry:=TRUE;
      {glowna petla gry}

      while(Trwanie_Gry=TRUE) do
      begin
           sterowanie_belka;
           sterowanie_belka;
           ruch_kulki;
           kolizja_cegielki;
           paletka_bonus;
           stan;
      end;

      {Game over}

      j:=0;
      for i:=1 to 75 do
      begin
           if(klocek_exist[i]=FALSE) then
           j:=j+1;
      end;
      if(j=75) then
      begin
          {wskaźnik do struktury BITMAP, na której ma być wyświetlony napis, wskaźnik do struktury FONT, napis, pozycja X, pozycja Y,
          numer koloru, oraz numer koloru tła tekstu. Gdy za numer koloru tła tekstu podstawimy -1, tło będzie przezroczyste. }
          al_rectfill(al_screen,ScreenWidth div 3-100,200,ScreenWidth div 3+200,400,al_makecol(173,17,17));
          al_rectfill(al_screen,ScreenWidth div 3-95,205,ScreenWidth div 3+195,395,al_makecol(255,165,0));
          al_textout_centre_ex(al_screen,al_font,'   Wygrales!    ',ScreenWidth div 3+50, ScreenHeight div 2-10, al_makecol(255,255,255), -1);
          al_textout_centre_ex(al_screen,al_font,'nacisnij [ENTER]',ScreenWidth div 3+50, ScreenHeight div 2+10, al_makecol(255,255,255), -1);

      end else
      begin
          al_rectfill(al_screen,ScreenWidth div 3-100,200,ScreenWidth div 3+200,400,al_makecol(255,165,0));
          al_rectfill(al_screen,ScreenWidth div 3-95,205,ScreenWidth div 3+195,395,al_makecol(255,255,255));
          al_textout_centre_ex(al_screen,al_font,'   koniec gry   ',ScreenWidth div 3+50, ScreenHeight div 2-10, al_makecol(0,0,0), -1);
          al_textout_centre_ex(al_screen,al_font,'nacisnij [ENTER]',ScreenWidth div 3+50, ScreenHeight div 2+10, al_makecol(0,0,0), -1);
      end;

      repeat
          al_keypressed();
          key:=char(al_readkey);
      until key=#13; //#13[ENTER]

      Wybor:=FALSE;

      while(Wybor=FALSE) do
      begin
           menu;
      end;
      goto nowa_gra;

      al_exit;

end.
