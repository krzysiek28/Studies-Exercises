with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Float_Random;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Float_Random;

package body lab3_Pkg is


 procedure Show(V: in Vector) is
   begin
      for I in V'Range loop
         Put(V(I)'Img & ",");
      end loop;
   end show;

   procedure RandomVector(V: out Vector) is
   Gen: Generator;
   begin
      Reset(Gen);
      for I in V'Range loop
         V(I) := 10.0*Random(Gen);
      end loop;
   end RandomVector;

   function VectorIsSorted(V: in Vector) return Boolean is
      (for all I in V'First .. V'Last-1 => V(I) <= V(I+1));

   procedure SortVector(V: in out Vector) is
      tmp: Float;
   begin
      for J in V'First .. V'Last-1 loop
         for I in V'First .. V'Last-1 loop
            if(V(I)>V(I+1)) then
               tmp:=V(I);
               V(I):=V(I+1);
               V(I+1):=tmp;
            end if;
         end loop;
      end loop;
   end SortVector;

   procedure SaveToFile(V: in Vector) is
      file: File_Type;
      Name: String := "measurement.txt";
   begin
      Create(file, Out_File, Name);
      Put_Line("Create file: " & Name);
      for I in V'Range loop
         Put(file, V(I)'Img & ",");
      end loop;
      Close(file);
   end SaveToFile;

end lab3_Pkg;
