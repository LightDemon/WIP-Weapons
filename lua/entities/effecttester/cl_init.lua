 include('shared.lua')     
 //[[---------------------------------------------------------     
 //Name: Draw     Purpose: Draw the model in-game.     
 //Remember, the things you render first will be underneath!  
 //-------------------------------------------------------]]  
 function ENT:Draw()      
 
 self.Entity:DrawModel()       // Draw the model.  
Wire_Render(self.Entity) 
 end  
 
