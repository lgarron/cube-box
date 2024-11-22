VERSION_TEXT = "v0.1.6";

MAIN_SCALE = 1;
CUBE_EDGE_LENGTH = 57; // mm
OPENING_ANGLE_EACH_SIDE = 75; // Avoid setting to 0 for printing unless you want overly shaved lids

SET_ON_SIDE_FOR_PRINTING = true;

$fn = 180;

include <./node_modules/scad/duplicate_and_mirror.scad>
include <./node_modules/scad/minkowski_shell.scad>
include <./node_modules/scad/round_bevel.scad>
include <./node_modules/scad/small_hinge.scad>

/*

## v0.1.6

- Make the hinge gears rotationally symmetrical to allow box bottoms to be stacked in either orientation.
- Shave hinge blocks and lids.
- Add version engraving.
- Add `SET_ON_SIDE_FOR_PRINTING` parameter.

## v0.1.5

- Lower the shell for the stand.

## v0.1.4

(Abandoned.)

## v0.1.3

- Scale the cube edge length from 28mm to 56mm
- Scale clearances (including in hinge).
- Add a little extra clearance inside.

## v0.1.2

- Add lids

## v0.1.1

- Adjust clearances for vertical printing.

*/

INTERNAL_MAIN_SCALE = 2 * MAIN_SCALE;
INTERNAL_CUBE_EDGE_LENGTH = CUBE_EDGE_LENGTH/2; // YS3M


DEFAULT_CLEARANCE = 0.2 / INTERNAL_MAIN_SCALE;
MAIN_CLEARANCE_SCALE = 1 / INTERNAL_MAIN_SCALE;

LARGE_VALUE = 200;

INNER_STAND_BASE_THICKNESS = 2;
INNER_STAND_LIP_THICKNESS = 1;
INNER_STAND_LIP_HEIGHT = 3.5;
INNER_STAND_FLOOR_ELEVATION = INNER_STAND_BASE_THICKNESS - INNER_STAND_LIP_THICKNESS;

module main_cube()
{
    translate([ 0, 0, INTERNAL_CUBE_EDGE_LENGTH / 2 ]) cube(INTERNAL_CUBE_EDGE_LENGTH, center = true);
};
module main_cube_on_stand()
{
    translate([ 0, 0, INNER_STAND_FLOOR_ELEVATION ]) main_cube();
};

HINGE_GEAR_OUTER_RADIUS = 6.4 / 2;

OUTER_SHELL_INNER_WIDTH = INTERNAL_CUBE_EDGE_LENGTH + INNER_STAND_LIP_THICKNESS * 2;

// translate([ 0, -INTERNAL_CUBE_EDGE_LENGTH / 2 + 5 - INNER_STAND_LIP_THICKNESS, 0.5 ]) cube([ 10, 10, 1 ], center = true);

// round_bevel_complement(20, 10, center_z = true);

BASE_EXTRA_HEIGHT_FOR_GEARS = 0.5; // This is slightly less than the gears stick out, but the impact is negligible.
BASE_HEIGHT = __SMALL_HINGE__THICKNESS + BASE_EXTRA_HEIGHT_FOR_GEARS;

BASE_LATTICE_OFFSET = __SMALL_HINGE__THICKNESS + DEFAULT_CLEARANCE * 2;
BASE_LATTICE_COMPLEMENT_OFFSET = __SMALL_HINGE__THICKNESS - DEFAULT_CLEARANCE * 2;

OUTER_SHELL_THICKNESS = 1;

module rotate_opening_angle()
{
    translate([ __SMALL_HINGE__THICKNESS / 2, 0, -__SMALL_HINGE__THICKNESS / 2 ])
        rotate([ 0, OPENING_ANGLE_EACH_SIDE, 0 ])
            translate([ -__SMALL_HINGE__THICKNESS / 2, 0, __SMALL_HINGE__THICKNESS / 2 ]) children();
}

module rotate_opening_angle_left()
{
    translate([ -__SMALL_HINGE__THICKNESS / 2, 0, -__SMALL_HINGE__THICKNESS / 2 ])
        rotate([ 0, -OPENING_ANGLE_EACH_SIDE, 0 ])
            translate([ __SMALL_HINGE__THICKNESS / 2, 0, __SMALL_HINGE__THICKNESS / 2 ]) children();
}

module lat(i, mirror_scale)
{
    scale([ mirror_scale, 1, 1 ]) translate([
        BASE_LATTICE_COMPLEMENT_OFFSET - _EPSILON, i * 4 + 1 + mirror_scale - DEFAULT_CLEARANCE, -BASE_HEIGHT - _EPSILON
    ])
        cube([
            OUTER_SHELL_INNER_WIDTH / 2 + OUTER_SHELL_THICKNESS + _EPSILON - BASE_LATTICE_COMPLEMENT_OFFSET +
                2 * _EPSILON,
            2 + DEFAULT_CLEARANCE * 2, BASE_EXTRA_HEIGHT_FOR_GEARS * 2 + _EPSILON +
            DEFAULT_CLEARANCE
        ]);
}

module lats()
{

    for (i = [-5:5])
    {
        rotate_opening_angle() lat(i, 1);
        rotate_opening_angle_left() lat(i, -1);
    }
}

// % minkowski()
// {
// % union()
// {
//     translate([ 0, -OUTER_SHELL_INNER_WIDTH / 2, -BASE_HEIGHT ])
//         cube([ OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_INNER_WIDTH, OUTER_SHELL_INNER_WIDTH + BASE_HEIGHT ]);
// }
//     sphere(INNER_STAND_LIP_THICKNESS);
// }

HALF_LID_EXTRA_HEIGHT = 1;

module lid_part(w, d, h)
{

    lid_radius_w = w - __SMALL_HINGE__THICKNESS / 2;
    lid_radius_h = h + INNER_STAND_FLOOR_ELEVATION + __SMALL_HINGE__THICKNESS / 2;
    lid_radius = sqrt(pow(lid_radius_w, 2) + pow(lid_radius_h, 2));

    difference()
    {
        translate([ __SMALL_HINGE__THICKNESS / 2, 0, -__SMALL_HINGE__THICKNESS / 2 ]) rotate([ 90, 0, 0 ])
            cylinder(h = d, r = lid_radius, center = true);

        translate([ LARGE_VALUE / 2 + w, 0, 0 ]) cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
        translate([ -LARGE_VALUE / 2 + __SMALL_HINGE__THICKNESS / 2, 0, 0 ])
            cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
        translate([ 0, 0, -LARGE_VALUE / 2 + INNER_STAND_FLOOR_ELEVATION ])
            cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
    }

    translate([ 0, -d / 2, INNER_STAND_FLOOR_ELEVATION ])
        cube([ __SMALL_HINGE__THICKNESS / 2, d, lid_radius - lid_radius_h + h ]);
}

engraving_depth = 0.25;

module engraving_text(text_string, _epsilon, halign = "center")
{
    translate([ 0, 0, -engraving_depth ]) linear_extrude(engraving_depth + _epsilon)
        text(text_string, size = 2, font = "Ubuntu:style=bold", valign = "center", halign = halign);
}

rotate([SET_ON_SIDE_FOR_PRINTING ? -90 : 0, 0, 0])
scale(INTERNAL_MAIN_SCALE) union()
{
    difference()
    {
        translate([ 0, 0, INNER_STAND_LIP_THICKNESS ]) difference()
        {
            minkowski()
            {
                main_cube();
                sphere(INNER_STAND_LIP_THICKNESS - DEFAULT_CLEARANCE);
            }

            main_cube_on_stand();
            translate([ 0, 0, LARGE_VALUE / 2 + INNER_STAND_LIP_HEIGHT ]) cube(LARGE_VALUE, center = true);
        }

        duplicate_and_mirror() duplicate_and_mirror([ 0, 1, 0 ])
            translate([ __SMALL_HINGE__THICKNESS / 2, -OUTER_SHELL_INNER_WIDTH / 2, -__SMALL_HINGE__THICKNESS / 2 ])
                rotate([ -90, 0, 0 ]) cylinder(h = 10 - __SMALL_HINGE__GEAR_OFFSET_HEIGHT, r = HINGE_GEAR_OUTER_RADIUS);
    }

    translate([ 0, 0, 0.5 ]) cube([ 8, 8, 1 ], center = true);

    difference()
    {
        render() union()
        {
            duplicate_and_mirror() rotate_opening_angle() union()
            {
                translate([ BASE_LATTICE_OFFSET, -OUTER_SHELL_INNER_WIDTH / 2, -BASE_HEIGHT ])
                    cube([ OUTER_SHELL_INNER_WIDTH / 2 - BASE_LATTICE_OFFSET, OUTER_SHELL_INNER_WIDTH, BASE_HEIGHT ]);

                duplicate_and_mirror([ 0, 1, 0 ]) translate([ __SMALL_HINGE__THICKNESS, 5, -BASE_HEIGHT ]) cube([
                    OUTER_SHELL_INNER_WIDTH / 2 - __SMALL_HINGE__THICKNESS, OUTER_SHELL_INNER_WIDTH / 2 - 5,
                    BASE_HEIGHT
                ]);
            }

            rotate([ 90, 0, 0 ]) translate([ 0, -__SMALL_HINGE__THICKNESS, -15 ])
                small_hinge_30mm(rotate_angle_each_side = OPENING_ANGLE_EACH_SIDE, main_clearance_scale = 0.5,
                                 plug_clearance_scale = 1, round_far_side = true);
        };

        translate([ 0, 0, -__SMALL_HINGE__THICKNESS - _EPSILON ]) rotate([ 180, 0, 0 ]) rotate([ 0, 0, 90 ])
            engraving_text(VERSION_TEXT, 0);

        lats();
    }

    difference()
    {

        render() duplicate_and_mirror() rotate_opening_angle() difference()
        {
            render() minkowski_shell()
            {
                union()
                {
                    lid_part(INTERNAL_CUBE_EDGE_LENGTH / 2, INTERNAL_CUBE_EDGE_LENGTH, HALF_LID_EXTRA_HEIGHT + INTERNAL_CUBE_EDGE_LENGTH);
                    lid_part(INTERNAL_CUBE_EDGE_LENGTH / 2 + INNER_STAND_LIP_THICKNESS,
                             INTERNAL_CUBE_EDGE_LENGTH + INNER_STAND_LIP_THICKNESS * 2, INNER_STAND_LIP_HEIGHT);

                    translate([ 0, -OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_THICKNESS - BASE_HEIGHT ])
                        cube([ OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_INNER_WIDTH, BASE_HEIGHT ]);
                }

                sphere(OUTER_SHELL_THICKNESS);
            }

            translate([ -LARGE_VALUE / 2, 0, 0 ]) cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);

            translate([
                -BASE_LATTICE_OFFSET, -(OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS) / 2, -BASE_HEIGHT -
                _EPSILON
            ])
                cube([
                    BASE_LATTICE_OFFSET * 2, OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS,
                    BASE_EXTRA_HEIGHT_FOR_GEARS +
                    _EPSILON
                ]);
            translate([ -BASE_LATTICE_OFFSET, -(OUTER_SHELL_INNER_WIDTH) / 2, -BASE_HEIGHT - _EPSILON ])
                cube([ BASE_LATTICE_OFFSET * 2, OUTER_SHELL_INNER_WIDTH, BASE_HEIGHT + _EPSILON ]);

            translate([ 0, 0, -__SMALL_HINGE__THICKNESS ]) rotate([ 90, 0, 0 ])
                round_bevel_complement(height = OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS + 2 * _EPSILON,
                                       radius = __SMALL_HINGE__THICKNESS / 2, center_z = true);
        }

        cube([ 2 * DEFAULT_CLEARANCE, LARGE_VALUE, LARGE_VALUE ], center = true);

        lats();
    }
}
