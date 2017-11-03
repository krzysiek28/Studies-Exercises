with Ada.Text_IO, lab3_Pkg, Ada.Integer_Text_IO, Ada.Calendar, Ada.Numerics.Float_Random;
use Ada.Text_IO, lab3_Pkg, Ada.Integer_Text_IO, Ada.Calendar, Ada.Numerics.Float_Random;

procedure Main is

   v1: Vector(1..20);
   D: Duration;
   T1,T2: Time;

begin
   T1:=Clock;
   RandomVector(v1);
   Show(v1);
   SortVector(v1);
   New_Line;
   if VectorIsSorted(v1) then
      Put_Line("Vector is sorted!");
   else
      Put_Line("Vector is not sorted!");
   end if;
   SaveToFile(v1);

   T2:=Clock;
   D:=T2-T1;
   Put_Line("Calculating duration: " & D'Img & "[s]");
end Main;
