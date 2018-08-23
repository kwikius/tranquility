

//.................................................................

enum_working = 0;
enum_show_construction = 1;
enum_show_rib_layout = 2;
enum_show_plan_view = 3;

// uncomment the view_mode_enum variable below 
// to one of the following values
// to output the various options available
//########################################################
// Use this mode for scratch testing                   ###
//view_mode_enum = enum_working;                     //###
//###                                                  ###
//### shows all the ribs, spars and webs etc           ###
  view_mode_enum = enum_show_construction;           //###
//###                                                  ###
//### Creates a plan view                              ###
//view_mode_enum = enum_show_plan_view;              //###
//###                                                  ###          
//### creates the rib profiles for laser cutting ribs  ###
//view_mode_enum = enum_show_rib_layout;             //###
//###                                                  ###
//########################################################

//................................................................
/*
  N.B many of these values depend on the shape of the
   wing blank in the tranquility_wing.stl file
*/
span = 432;
root_chord = 162;
tip_chord = 121.5;
root_aerofoil_thickness = 0.062;
root_max_thickness_point = 0.257;

root_le_offset = 0;
tip_le_offset = 10.57;

root_front_spar_pos = root_max_thickness_point * root_chord + root_le_offset;
tip_front_spar_pos = 0.26 * tip_chord  + tip_le_offset;

// diagonal ribs intersect ahead of web at front to give stronger joint with le rib in bending around y axis
root_front_diag_ribs_overhang = 3;
tip_front_diag_ribs_overhang = 2;

root_rib_thickness = 1.6;
tip_rib_thickness  = 1.6;

front_web_thickness = 1.6;
rear_web_thickness = 1.6;

// gap between 2 rear spars
hinge_gap = 3.2;

le_spar_x_width = 3;
//te_thickness = 6;

te_spar_x_width = 6;
hinge_y_gap = 2;

// z size and position of blanks for intersect/subtract with wing blank
zpos = [-4,12];
numsegs = 10;

// all ribs thickness. May need to refine this.
rib_thickness = 1.6;

root_rear_spar_pos = 0.75 * root_chord + root_le_offset;
tip_rear_spar_pos = 0.8 * tip_chord + tip_le_offset;

leading_edge_vpl = [[root_le_offset,0],[tip_le_offset,span]];
trailing_edge_vpl = leading_edge_vpl + [[root_chord,0],[tip_chord,0]];

dihedral_angle = 5;
joiner_thickness = 6;
joiner_outside_length= 50;

joinloc_dowel_thickness = 2;
joinloc_dowel_outside_length = 8;
joinloc_dowel_total_length = 16;
joinloc_dowel_front_pos = [le_spar_x_width , 3];
joinloc_dowel_rear_pos = [root_rear_spar_pos - (joinloc_dowel_thickness/2 +3), 3];

// front spar vertical plane
front_spar_vpl = 
   [ [root_front_spar_pos,0],
     [tip_front_spar_pos,span]
   ] ;

// rear spar vertical plane
rear_spar_vpl = 
   [ [root_rear_spar_pos,0],
     [tip_rear_spar_pos,span]
   ] ;

module wing(){
   translate([0,0,2.45]){
   rotate([0,0,0]){
      import("tranquility_wing.stl", convexity = 10);
   }
   
}
}

module joiner()
{
  // root_thickness = root_chord * root_aerofoil_thickness;
   difference(){
      rotate([-dihedral_angle,0,0]){
         translate([root_front_spar_pos, - joiner_outside_length,6.75]){
            rotate([-90,0,0]){
               cylinder (d = joiner_thickness, h = 300 , $fn = 20);
            }
         }
      }
     
      translate([0,0,-50]){
         cube([100,400,50.5]);
      }
   }
}

module joinloc_dowel()
{
   rotate([-dihedral_angle,0,0]){
      translate([joinloc_dowel_front_pos[0],
            -joinloc_dowel_outside_length,
               joinloc_dowel_front_pos[1]]){
            rotate([-90,0,0]){
               cylinder (d = joinloc_dowel_thickness, h = joinloc_dowel_total_length , $fn = 20);
            }
      }

       translate([joinloc_dowel_rear_pos[0],
            -joinloc_dowel_outside_length,
               joinloc_dowel_rear_pos[1]]){
            rotate([-90,0,0]){
               cylinder (d = joinloc_dowel_thickness, h = joinloc_dowel_total_length , $fn = 20);
            }
      }
   }
}

function xy_distance( p1, p2)
  = let (p = p2 - p1)
  sqrt(p[0] * p[0] + p[1] * p[1]);

function get_point (vp, ratio) 
  =  vp[0] + ratio  * ( vp[1] - vp[0]);

// vp_front vertical plane fron
// vp_rear vertical plane rear
// zpos [ bottom, top] of rectangle representing rib
// numsegs is actually number of ribs, tot of those in each zig and zag
//  rib_thickness - thickness of each rib
// root_y_offset - The offset in y from root to do the segment subdivisions
// tip y offset - The offset in y from root to do the segment subdivisions
module diagonal_rib_blank(
   vp_front, ratio_vp_front,
   vp_rear, ratio_vp_rear,
   zpos,
   rib_thickness,
   root_y_offset , tip_y_offset){

   p0 = get_point(vp_front + [[0,root_y_offset],[0,-tip_y_offset]],ratio_vp_front);

   p1 = get_point(vp_rear + [[0,root_y_offset],[0,-tip_y_offset]],ratio_vp_rear);

   pdif = p1 - p0;

   angle = atan2(pdif[1],pdif[0]);

   translate([p0[0],p0[1],zpos[0]]){
      rotate([0,0,angle]){
         translate([0,-rib_thickness/2,0]){
            cube([xy_distance(p0,p1),rib_thickness,zpos[1]-zpos[0]]);
         }
      }
   }
}

module diagonal_rib(   
   vp_front, ratio_vp_front,
   vp_rear, ratio_vp_rear,
   zpos,
   rib_thickness,
   root_y_offset , tip_y_offset)
{
   intersection(){
      difference(){
         wing();
         union(){
         spar_blanks();
         do_circular_webs(front_spar_vpl,10,numsegs,0.9,   root_rib_thickness,
            tip_rib_thickness);
         joiner();
         locating_spars();

      // this just removes a dag on the ctrl surface diagonal ribs
           spar_blank(        
      trailing_edge_vpl - 
       [[te_spar_x_width/2,0],[te_spar_x_width/2,0]],
      te_spar_x_width);
         }
      }
      diagonal_rib_blank( vp_front, ratio_vp_front,
         vp_rear, ratio_vp_rear,
         zpos, rib_thickness,
         root_y_offset , tip_y_offset
      );
   }
}
// projection onto plane
module diagonal_rib_n(
  n, nsegs,
  vp_front, 
   vp_rear,  zpos,
   rib_thickness,
   root_y_offset , tip_y_offset, sense)
{
   sense1 = (n%2) == ((sense == true)? 1 : 0);
   ratio0 = (sense1)?n / nsegs : (n+1) / nsegs;
   ratio1 = (sense1)?(n+1) / nsegs : n / nsegs;

   p0 = get_point(vp_front + [[0,root_y_offset],[0,-tip_y_offset]],ratio0);

   p1 = get_point(vp_rear + [[0,root_y_offset],[0,-tip_y_offset]],ratio1);

   pdif = p1 - p0;

   angle = atan2(pdif[1],pdif[0]);

   projection(cut = true){
   rotate([-90,0,0]){
   rotate([0,0,-angle]){
    translate([-p0[0],-p0[1],-zpos[0]]){
      
       diagonal_rib(
         vp_front,ratio0,
         vp_rear, ratio1,
         zpos,
         rib_thickness,
         root_y_offset , tip_y_offset
      );
   }
   }
   }
   }
}

module diagonal_rib_blanks(
 vp_front,vp_rear,zpos,numsegs, rib_thickness, 
   sense, root_y_offset = 0, tip_y_offset = 0
){
   for (i = [0 : numsegs-1]){
      sense1 = (i%2) == ((sense == true)? 1 : 0);
      ratio0 = (sense1)?i / numsegs : (i+1) / numsegs;
      ratio1 = (sense1)?(i+1) / numsegs : i / numsegs;

      diagonal_rib_blank(
         vp_front,ratio0,
         vp_rear,ratio1,
         zpos,
         rib_thickness,
         root_y_offset,
         tip_y_offset);
   }
}

module fore_n_aft_rib_blank(
vp_front,vp_rear,zpos,
   ratio, rib_thickness, root_y_offset = 0, tip_y_offset = 0
){
    diagonal_rib_blank(vp_front, ratio,vp_rear,ratio,zpos,rib_thickness,root_y_offset,tip_y_offset);
}

module fore_n_aft_rib_blanks( vp_front,vp_rear,zpos,
   numsegs, rib_thickness, root_y_offset = 0, tip_y_offset = 0)
{
   for ( i = [1:numsegs-1]){
      ratio = i/numsegs;
      fore_n_aft_rib_blank(
         vp_front,
         vp_rear,
         zpos,
         ratio,
         rib_thickness,
         root_y_offset,
         tip_y_offset
      );
   }
}

module fore_n_aft_rib(
 vp_front,vp_rear,zpos,
   ratio, rib_thickness, root_y_offset = 0, tip_y_offset = 0
)
{
   intersection(){
      difference(){
         wing();
         union(){
            spar_blanks();
            do_circular_webs(front_spar_vpl,10,numsegs,0.9,   root_rib_thickness,
            tip_rib_thickness);
            joiner();
            locating_spars();
         }
      }
      fore_n_aft_rib_blank(
         vp_front,
         vp_rear,
         zpos,
         ratio,
         rib_thickness,
         root_y_offset,
         tip_y_offset
      );
   }
}

module for_n_aft_rib_n( n, vp_front,vp_rear,zpos,
    rib_thickness, root_y_offset = 0, tip_y_offset = 0
)
{
   ratio = n/numsegs;
   projection(cut = false){

      rotate([-90,0,0]){
         translate([0,0,-zpos[0]]){
            fore_n_aft_rib(
               vp_front,
               vp_rear,
               zpos,
               ratio,
               rib_thickness,
               root_y_offset,
               tip_y_offset
            );
         }
      }
   }
}

module root_rib_blank(){
   fore_n_aft_rib_blank(
    leading_edge_vpl,
    trailing_edge_vpl,
    zpos,0,root_rib_thickness,root_rib_thickness/2,0);
}

// The root rib attached to pod
module root_ribA()
{
 intersection(){
      difference(){
         wing();
         union(){
            joiner();
            joinloc_dowel();
         }
      }
      root_rib_blank();
   }
}

module root_rib(){
   intersection(){
      difference(){
         wing();
         union(){
            spar_blanks();
          //  do_circular_webs(front_spar_vpl,10,numsegs,0.9, root_rib_thickness,
          //  tip_rib_thickness);
            joiner();
            locating_spars();
            joinloc_dowel();
         }
      }
      root_rib_blank();
   }
}

module tip_rib_blank(){
    fore_n_aft_rib_blank(
    leading_edge_vpl,
    trailing_edge_vpl,
    zpos,1,tip_rib_thickness,tip_rib_thickness/2,0);
}

module tip_rib(){
   intersection(){
      difference(){
         wing();
         union(){
            spar_blanks();
          //  do_circular_webs(front_spar_vpl,10,numsegs,0.9, root_rib_thickness,
          //  tip_rib_thickness);
          //  joiner();
            locating_spars();
         }
      }
      tip_rib_blank();
   }
}

module top_skin(thickness){
   difference(){
      wing();
      translate([0,0,-thickness]){
         wing();
      }
   }
}

module bottom_skin(thickness){
   difference(){
      wing();
      translate([0,0,thickness]){
         wing();
      }
   }
}

module circular_web_blank(vpl,diameter,ratio, root_y_offset = 0, tip_y_offset = 0)
{
   p0 = get_point(vpl + [[0,root_y_offset],[0,-tip_y_offset]],ratio);
   translate([p0[0],p0[1],zpos[0]]){
      cylinder(d= diameter, h =zpos[1]-zpos[0]);
   }
}

module circular_web_blank_cutout(vpl,diameter,ratio, root_y_offset = 0, tip_y_offset = 0)
{
   intersection(){
      union(){
          top_skin_spar(vpl,diameter +1,thickness);
          bottom_skin_spar(vpl,diameter +1,thickness);
      }
      circular_web_blank(vpl,diameter,ratio,root_y_offset, tip_y_offset);
   }
}

module do_circular_webs(vpl,diameter,numsegs,thickness, root_y_offset = 0, tip_y_offset = 0)
{
   intersection(){
      union(){
          top_skin_spar(vpl,diameter +1,thickness);
          bottom_skin_spar(vpl,diameter +1,thickness);
      }
      union(){
         for ( i = [1:2:numsegs-1]){
            ratio = i/numsegs;
            circular_web_blank(vpl,diameter,ratio,root_y_offset, tip_y_offset);
         }
      }
   }   
}

module spar_blank(vpl, width)
{
   translate([0,0,zpos[0]]){
      linear_extrude(height = zpos[1]-zpos[0]){
         polygon (points =[
            vpl[0] - [width/2,0], // front root
            vpl[1]- [width/2,0],  // front tip
            vpl[1] + [width/2,0], // rear root
            vpl[0]+ [width/2,0]  // rear tip
         ]);
      };
   }
}

//spar at a fixed height
module free_spar(vpl,width,z)
{
   intersection(){
      spar_blank(vpl,width);
      translate([0,0,z[0]]){
         linear_extrude(height = z[1]-z[0]){
            polygon (points =[
            vpl[0] - [width/2 +1,0], // front root
            vpl[1]- [width/2 +1,0],  // front tip
            vpl[1] + [width/2 +1,0], // rear root
            vpl[0]+ [width/2 +1,0]  // rear tip
            ]);
         };
      }
   }
}

module web_blank(vpl,thickness){
   spar_blank(vpl,thickness);
}

module spar_v_slice(vpl,width){
  intersection(){
      wing();
      spar_blank(vpl,width);
  }
}

module top_skin_spar(vpl, width, thickness)
{
   difference(){
      spar_v_slice(vpl,width);
      translate([0,0,-thickness]){
         spar_v_slice(vpl, width + 0.1);
      }
   } 
}

module top_skin_spar_blank(vpl, width, thickness)
{
   difference(){
      translate([0,0,0.1]){
         spar_v_slice(vpl,width);
      }
      translate([0,0,-thickness]){
         spar_v_slice(vpl, width + 0.1);
      }
   } 
}

module bottom_skin_spar(vpl, width, thickness)
{
   difference(){
      spar_v_slice(vpl,width);
      translate([0,0,thickness]){
         spar_v_slice(vpl, width + 0.1);
      }
   }
}

module bottom_skin_spar_blank(vpl, width, thickness)
{
   difference(){
      translate([0,0,-0.1]){
         spar_v_slice(vpl,width);
      }
      translate([0,0,thickness]){
         spar_v_slice(vpl, width + 0.1);
      }
   }
}

module leading_edge_blank()
{
   le_root =[root_le_offset,0];
   le_tip = [tip_le_offset,span];
   diff = le_tip - le_root;
   angle = atan2(-diff[0],diff[1]);
   length = xy_distance(le_tip,le_root);
   translate([le_root[0] - 0.01,le_root[1],zpos[0]]){
      rotate([0,0,angle]){
         translate([0,-1,0]){
            cube([le_spar_x_width +0.01,length+2,zpos[1]- zpos[0]]);
         }
      }
   }
}

module do_leading_edge(){
   intersection(){
      wing();
      leading_edge_blank();
   }
}

module web_blanks(){
   web_blank(front_spar_vpl,front_web_thickness,zpos);

   // hinge webs
   web_blank(rear_spar_vpl - 
         [ [hinge_gap/2,0],[hinge_gap/2,0]
         ],rear_web_thickness
   );

   web_blank(rear_spar_vpl + 
         [ [hinge_gap/2,0],[hinge_gap/2,0]
         ],rear_web_thickness
   );
}

module rib_blanks(){
   // front to rear spar ribs
   diagonal_rib_blanks(
      front_spar_vpl +
      [
         [-root_front_diag_ribs_overhang,0],
         [-tip_front_diag_ribs_overhang,0]
      ],  // front vertical plane with overhang
      rear_spar_vpl +
      [
        [-hinge_gap/2,0],
        [-hinge_gap/2,0]
      ],   // rear vertical plane
      zpos,            // z limits
      numsegs,
      rib_thickness,
      true,
      root_rib_thickness,
      tip_rib_thickness
   );       

   root_rib_blank();
   tip_rib_blank();

   // le ribs
   fore_n_aft_rib_blanks(
      leading_edge_vpl,
      front_spar_vpl,
      zpos,
      numsegs,
      rib_thickness ,
      root_rib_thickness,
      tip_rib_thickness
   );

   // le diagonal ribs
   diagonal_rib_blanks(
         [
         [root_le_offset + le_spar_x_width,0],
         [tip_le_offset + le_spar_x_width,span ]
      ],
      front_spar_vpl,
         zpos,         
         numsegs,
         rib_thickness ,
         false,
         root_rib_thickness,
         tip_rib_thickness 
   );

   // control surface diagonal ribs
   diagonal_rib_blanks(
      rear_spar_vpl  + 
         [ [hinge_gap/2,0],
            [hinge_gap/2,0]
      ],
      trailing_edge_vpl - 
         [[te_spar_x_width-1,0],
         [te_spar_x_width-1,0]
      ],
      zpos,         
      numsegs*2,
      rib_thickness ,
      true,
      root_rib_thickness + hinge_y_gap,
      tip_rib_thickness + hinge_y_gap
   ); 
}

module do_ribs() {
   intersection(){
      wing();
      rib_blanks();
   }
}
module do_webs()
{
   intersection(){
      wing();
      web_blanks();
   }   
}

module do_spars()
{
   do_leading_edge(); 
   top_skin_spar(front_spar_vpl,3,0.5);
   bottom_skin_spar(front_spar_vpl,3,0.5);

   //vpl,diameter,numsegs,thickness, root_y_offset = 0, tip_y_offset = 0
   do_circular_webs(front_spar_vpl,10,numsegs,0.9,   root_rib_thickness,
            tip_rib_thickness);

   top_skin_spar(rear_spar_vpl,10,0.8);
   bottom_skin_spar(rear_spar_vpl,10,0.8);

   top_skin_spar(
       trailing_edge_vpl - [[te_spar_x_width/2 -0.01,0],[te_spar_x_width/2 -0.01,0]],
       te_spar_x_width + 0.02,
       0.8);

   bottom_skin_spar(
       trailing_edge_vpl - [[te_spar_x_width/2 -0.01,0],[te_spar_x_width/2 -0.01,0]],
       te_spar_x_width + 0.02,
       0.8);
}

module top_main_spar()
{
   top_skin_spar_blank(front_spar_vpl,3,0.5);
}

module bottom_main_spar()
{
   bottom_skin_spar_blank(front_spar_vpl,3,0.5);
}

module spar_blanks()
{
   leading_edge_blank();
   top_main_spar();
  // bottom_main_spar();
   bottom_main_spar();

   top_skin_spar_blank(rear_spar_vpl,10,0.8);
   bottom_skin_spar_blank(rear_spar_vpl,10,0.8);

   top_skin_spar_blank(
       trailing_edge_vpl - [[te_spar_x_width/2 -0.01,0],[te_spar_x_width/2 -0.01,0]],
       te_spar_x_width + 0.02,
       0.8);

   bottom_skin_spar_blank(
       trailing_edge_vpl - [[te_spar_x_width/2 -0.01,0],[te_spar_x_width/2 -0.01,0]],
       te_spar_x_width + 0.02,
       0.8);
   
}

spar_layout_y_incr = 12;

module le_diagonal_ribs()
{
  for(diagonal_rib_number = [0:numsegs-1]){

   translate([0,spar_layout_y_incr * diagonal_rib_number,0]){
   diagonal_rib_n(
     diagonal_rib_number,
     numsegs,
         [
         [root_le_offset + le_spar_x_width,0],
         [tip_le_offset + le_spar_x_width,span ]
      ],
      front_spar_vpl,  
      zpos,
      rib_thickness,
      1 , 2, false);
   }
  }
}


module centre_diagonal_ribs()
{
  for(diagonal_rib_number = [0:numsegs-1]){

   translate([root_chord * 0.3 + 15,spar_layout_y_incr * diagonal_rib_number,0]){
   diagonal_rib_n(
     diagonal_rib_number,
     numsegs,
     front_spar_vpl +
         [
            [-root_front_diag_ribs_overhang,0],
            [-tip_front_diag_ribs_overhang,0]
         ],  // front vertical plane with overhang
         rear_spar_vpl +
         [
           [-hinge_gap/2,0],
           [-hinge_gap/2,0]
         ],   
      zpos,
      rib_thickness,
      1 , 2, true);
   }
  }
}

module ctrl_srfc_diagonal_ribs()
{
  for(diagonal_rib_number = [0:numsegs*2-1]){

   translate([root_chord  ,spar_layout_y_incr/2 * diagonal_rib_number,0]){
   diagonal_rib_n(
     diagonal_rib_number,
     numsegs * 2,
 rear_spar_vpl  + 
         [ [hinge_gap/2,0],
            [hinge_gap/2,0]
      ],
      trailing_edge_vpl - 
         [[te_spar_x_width-1,0],
         [te_spar_x_width-1,0]
      ],  
      zpos,
      rib_thickness,
      1 , 2, true);
   }
  }
}

module locating_spars()
{
   free_spar(
        [[root_le_offset +le_spar_x_width,0],
        [tip_le_offset +le_spar_x_width,span]]
        , 5,[3.2,4]);
   free_spar(
         trailing_edge_vpl - 
         [[te_spar_x_width,0],
         [te_spar_x_width,0]
         ]
        , 6,[0.8,1.6]);
}

module fore_n_aft_diagonal_ribs()
{
   for(diagonal_rib_number = [0:numsegs-1]){

      translate([root_chord *1.35 ,spar_layout_y_incr * diagonal_rib_number,0]){
         for_n_aft_rib_n(
            diagonal_rib_number,
            leading_edge_vpl,
            front_spar_vpl,
            zpos,
            numsegs,
            rib_thickness ,
            root_rib_thickness,
            tip_rib_thickness
         );
      }
   }
}

if (view_mode_enum == enum_show_construction){
   intersection(){
      wing();
      union(){
         rib_blanks();
         web_blanks();
         spar_blanks();
         locating_spars();
         
      }
      
   }

   do_circular_webs(front_spar_vpl,10,numsegs,0.9,   root_rib_thickness,
            tip_rib_thickness);
   joiner();
   joinloc_dowel();

// 103.25 is dist from wing root to outer end of joiner
//    translate([40,103.25,-5]){
//      cube([5,1,1]);
//    }
}else{
   if (view_mode_enum == enum_show_rib_layout){
      le_diagonal_ribs();
      centre_diagonal_ribs();
      ctrl_srfc_diagonal_ribs();
      fore_n_aft_diagonal_ribs();
      // root and tip ribs
      projection(cut = true){
      translate([0,-10,0]){
         rotate([90,0,0]){
            translate([10,- rib_thickness /2,0]){
               root_rib();
            }
            translate([10,- (span -rib_thickness /4),15]){
               tip_rib();
            }
         }
      }
      // root rib ply skin
      translate([0,-45,0]){
         rotate([-90,0,0]){
            translate([0,- rib_thickness /2,0]){
               root_ribA();
            }
         }
      }
      }
   }else{
      if (view_mode_enum == enum_show_plan_view){
         projection(){
            leading_edge_blank();
            bottom_skin_spar(front_spar_vpl,3,0.5);

            do_circular_webs(front_spar_vpl,10,numsegs,0.9,   root_rib_thickness,
            tip_rib_thickness);

            bottom_skin_spar(rear_spar_vpl,10,0.8);

            bottom_skin_spar(
               trailing_edge_vpl - [[te_spar_x_width/2 -0.01,0],[te_spar_x_width/2 -0.01,0]],
               te_spar_x_width + 0.02,
            0.8);
            rib_blanks();
         }
      }else{
       // echo("view_mode_enum out of range");
       // assert( false);

         //do_leading_edge();
//top_skin_spar(front_spar_vpl,3,0.5);
         locating_spars();
         joiner();
         joinloc_dowel();
top_main_spar();
bottom_main_spar();
         %wing();

      }
   }
}
