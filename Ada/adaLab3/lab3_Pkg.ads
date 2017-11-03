package lab3_Pkg is

   type Vector is array(Integer range <>) of Float;
   procedure Show(V: in Vector);
   procedure RandomVector(V: out Vector);
   function VectorIsSorted(V: in Vector) return Boolean;
   procedure SortVector(V: in out Vector);
   procedure SaveToFile(V: in Vector);

end lab3_Pkg;
