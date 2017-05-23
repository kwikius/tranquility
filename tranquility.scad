/*

Tranquility FPV thermal soarer.

Copyright (C) 2017 Andy Little

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program. If not, see http://www.gnu.org/licenses./
*/


module fuselage_pod(){
   scale([6,1,1]){
      sphere(d = 80);
   }
}

module tail_boom(){
  translate([-650,0,0]){
     rotate([0,90,0]){
       cylinder (d = 16, h = 420);
     }
  }
}

module pylon(){
  translate([-50,0,35]){
     rotate([0,-3,0]){
     linear_extrude(height = 125){
       scale([90,90,1]){
       rotate([0,0,180]){
          NACA66021();
       }
      }
     }
   }
  }
}

wing_span = 1800;
root_chord = 180;
mid_chord = 170;
tip_chord = 120;
centre_section_width = 25;

module wing(){
   translate([-80,0,160]){
      rotate([2,-3,0]){
        polygon( points = [
         [root_chord/3,0],
         [root_chord/3,centre_section_width/2],
         [mid_chord/3,wing_span/4 + centre_section_width/2],
         [tip_chord/3,wing_span/2 - tip_chord/3 + centre_section_width/2],
         [0,wing_span/2 + centre_section_width/2],
         [-tip_chord *2/3,wing_span/2 + centre_section_width/2],
         [-mid_chord *2/3,wing_span/4 + centre_section_width/2],
         [-root_chord*2/3,centre_section_width/2],
         [-root_chord*2/3,0]
        ]);
      }
   }
}
tail_span= wing_span / 4;
tail_root_chord = 120;
tail_tip_chord = 90;

module tail()
{
 
    translate([-700,0,20]){
    rotate([0,-1.5,0]){
       polygon( points = [
         [0,0],
         [tail_root_chord,0],
         [tail_tip_chord,tail_span/2- tail_tip_chord/2],
         [tail_tip_chord/2,tail_span/2],
         [0,tail_span/2]
       ]);
    }
  }
}

fin_height = 200;
module fin(){
   translate([-700,0.5,0]){
      rotate([90,0,0]){
         polygon( points = [
            [0,0],
            [tail_root_chord,0],
            [tail_tip_chord,fin_height- tail_tip_chord/2],
            [tail_tip_chord/2,fin_height],
            [0,fin_height]
         ]);
      }
   }
}

module camera()
{
  color([0.3,0.3,0.3]){
    rotate([0,10,0]){
		 cube([14,25,25],center= true);
	   rotate([0,90,0]){
	  	   cylinder(r=7.5,h=25);
	   }
    }
  }
}

module motor(){
         rotate([0,-3,0]){
     translate([-20,0,0]){
        rotate([0,90,0]){
            
            %difference(){
                  cylinder(r=120, h = 0.25);
                  translate([0,0,-1]){
                  cylinder( r = 119, h= 12);
                  }
            }
        }
     }
     difference(){
      scale([8.2,1,1]){
         sphere(d=35);
      }
      translate([-200,-50,-50]){
         cube([220,100,100]);
      }
   }
   }
}

module battery()
{
  color([0.1,0.2,0.6]){
	  cube([110,25,45],center = true);
  }
}

%fuselage_pod();

pylon();
tail_boom();

   wing();
   mirror([0,1,0]){wing();}


tail();
mirror([0,1,0]){tail();}

fin();

translate([210,0,0]){
   camera();
}

translate([-220,0,153]){
  motor();
}
translate([120,0,0]){
   rotate([0,0,0]){
      battery();
   }
}

module NACA66021(){
   polygon(points = [
      [1,0.005]
      ,[0.95,0.01192]
      ,[0.9,0.02374]
      ,[0.85,0.03749]
      ,[0.8,0.05196]
      ,[0.75,0.06626]
      ,[0.7,0.0796]
      ,[0.65,0.09118]
      ,[0.6,0.09992]
      ,[0.55,0.10461]
      ,[0.5,0.10684]
      ,[0.45,0.10725]
      ,[0.4,0.10607]
      ,[0.35,0.10329]
      ,[0.3,0.09888]
      ,[0.25,0.09278]
      ,[0.2,0.08476]
      ,[0.15,0.07444]
      ,[0.1,0.06102]
      ,[0.075,0.052705]
      ,[0.05,0.04294]
      ,[0.025,0.030575]
      ,[0.0125,0.0224625]
      ,[0.0075,0.0180775]
      ,[0.005,0.015275]
      ,[0,0]
      ,[0.005,-0.015275]
      ,[0.0075,-0.0180775]
      ,[0.0125,-0.0224625]
      ,[0.025,-0.030575]
      ,[0.05,-0.04294]
      ,[0.075,-0.052705]
      ,[0.1,-0.06102]
      ,[0.15,-0.07444]
      ,[0.2,-0.08476]
      ,[0.25,-0.09278]
      ,[0.3,-0.09888]
      ,[0.35,-0.10329]
      ,[0.4,-0.10607]
      ,[0.45,-0.10725]
      ,[0.5,-0.10684]
      ,[0.55,-0.10461]
      ,[0.6,-0.09992]
      ,[0.65,-0.09118]
      ,[0.7,-0.0796]
      ,[0.75,-0.06626]
      ,[0.8,-0.05196]
      ,[0.85,-0.03749]
      ,[0.9,-0.02374]
      ,[0.95,-0.01192]
      ,[1,-0.005]

   ]);
}






