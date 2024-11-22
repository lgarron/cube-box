VERSION_TEXT = "v0.2.0";

MAIN_SCALE = 1;
CUBE_EDGE_LENGTH = 57;        // mm
OPENING_ANGLE_EACH_SIDE = 75; // Avoid setting to 0 for printing unless you want overly shaved lids

INCLUDE_INNER_STAND_ENGRAVING = false;
INNER_STAND_ENGRAVING_FILE = "./archived/engraving/engraving.svg";

DEBUG = false;
SET_ON_SIDE_FOR_PRINTING = !DEBUG;

$fn = DEBUG ? 64 : 90;
LID_TOP_FN = DEBUG ? 64 : 360;

include <./node_modules/scad/duplicate_and_mirror.scad>
include <./node_modules/scad/minkowski_shell.scad>
include <./node_modules/scad/round_bevel.scad>
include <./node_modules/scad/small_hinge.scad>

/*

## v0.2.0

- Slim the gears to 5mm scale to decrease the box height.

## v0.1.6

- Make the hinge gears rotationally symmetrical to allow box bottoms to be stacked in either orientation.
- Shave hinge blocks and lids.
- Add version engraving.
- Add `SET_ON_SIDE_FOR_PRINTING` parameter.
- Add an optional inner stand engraving.

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

INTERNAL_MAIN_SCALE = MAIN_SCALE;
INTERNAL_CUBE_EDGE_LENGTH = CUBE_EDGE_LENGTH; // YS3M

DEFAULT_CLEARANCE = 0.1;
MAIN_CLEARANCE_SCALE = 0.5;

LARGE_VALUE = 200;

INNER_STAND_BASE_THICKNESS = 2.5;
INNER_STAND_LIP_THICKNESS = 1.55;
INNER_STAND_LIP_HEIGHT = 8;
INNER_STAND_FLOOR_ELEVATION = INNER_STAND_BASE_THICKNESS;

ENGRAVING_LEVEL_DEPTH = 0.2;

LAT_WIDTH = 4;

OUTER_SHELL_THICKNESS = 1.5;

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

BASE_EXTRA_HEIGHT_FOR_GEARS = 0.5; // This is slightly less than the gears stick out, but the impact is negligible.
BASE_HEIGHT = __SMALL_HINGE__THICKNESS + BASE_EXTRA_HEIGHT_FOR_GEARS;

BASE_LATTICE_OFFSET = __SMALL_HINGE__THICKNESS + DEFAULT_CLEARANCE * 2;
BASE_LATTICE_COMPLEMENT_OFFSET = __SMALL_HINGE__THICKNESS - DEFAULT_CLEARANCE;

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
        BASE_LATTICE_COMPLEMENT_OFFSET - _EPSILON,
        i * LAT_WIDTH * 2 + LAT_WIDTH / 2 + mirror_scale * LAT_WIDTH / 2 - DEFAULT_CLEARANCE, -BASE_HEIGHT -
        _EPSILON
    ])
        cube([
            OUTER_SHELL_INNER_WIDTH / 2 + OUTER_SHELL_THICKNESS + _EPSILON - BASE_LATTICE_COMPLEMENT_OFFSET +
                2 * _EPSILON,
            LAT_WIDTH + DEFAULT_CLEARANCE * 2, BASE_EXTRA_HEIGHT_FOR_GEARS * 2 + _EPSILON +
            DEFAULT_CLEARANCE
        ]);
}

module lats()
{
    render() union()
    {
        for (i = [-5:5])
        {
            rotate_opening_angle() lat(i, 1);
            rotate_opening_angle_left() lat(i, -1);
        }
    }
}

module debug_quarter_negative()
{
    if (DEBUG)
    {

        translate([ -LARGE_VALUE / 2, 0, 0 ]) cube(LARGE_VALUE, center = true); // TODO
        translate([ 0, -LARGE_VALUE / 2, 0 ]) cube(LARGE_VALUE, center = true); // TODO
    }
}

module lid_part(w, d, h)
{

    lid_radius_w = w - __SMALL_HINGE__THICKNESS / 2;
    lid_radius_h = h + INNER_STAND_FLOOR_ELEVATION + __SMALL_HINGE__THICKNESS / 2;
    lid_radius = sqrt(pow(lid_radius_w, 2) + pow(lid_radius_h, 2));

    difference()
    {
        translate([ __SMALL_HINGE__THICKNESS / 2, 0, -__SMALL_HINGE__THICKNESS / 2 ]) rotate([ 90, 0, 0 ])
            cylinder(h = d, r = lid_radius, center = true, $fn = LID_TOP_FN);

        translate([ LARGE_VALUE / 2 + w, 0, 0 ]) cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
        translate([ -LARGE_VALUE / 2 + __SMALL_HINGE__THICKNESS / 2, 0, 0 ])
            cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
        translate([ 0, 0, -LARGE_VALUE / 2 + INNER_STAND_FLOOR_ELEVATION ])
            cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
    }

    translate([ 0, -d / 2, INNER_STAND_FLOOR_ELEVATION ])
        cube([ __SMALL_HINGE__THICKNESS / 2, d, lid_radius - lid_radius_h + h ]);
}

VERSTION_TEXT_ENGRAVING_DEPTH = 0.25;

module engraving_text(text_string, _epsilon, halign = "center")
{
    translate([ 0, 0, -VERSTION_TEXT_ENGRAVING_DEPTH ]) linear_extrude(VERSTION_TEXT_ENGRAVING_DEPTH + _epsilon)
        text(text_string, size = 2, font = "Ubuntu:style=bold", valign = "center", halign = halign);
}

rotate([ SET_ON_SIDE_FOR_PRINTING ? -90 : 0, 0, 0 ]) scale(INTERNAL_MAIN_SCALE) union()
{
    if (DEBUG)
    {
#main_cube_on_stand();
    }

    render() difference()
    {
        render() union()
        {
            // TODO: `INNER_STAND_LIP_THICKNESS` is wrong here?
            difference()
            {
                minkowski()
                {
                    main_cube();
                    translate([ 0, 0, INNER_STAND_LIP_THICKNESS ])
                        sphere(INNER_STAND_LIP_THICKNESS - DEFAULT_CLEARANCE);
                }

                main_cube_on_stand();
                translate([ 0, 0, LARGE_VALUE / 2 + INNER_STAND_FLOOR_ELEVATION + INNER_STAND_LIP_HEIGHT ])
                    cube(LARGE_VALUE, center = true);
            }

            duplicate_and_mirror([ 0, 1, 0 ]) translate([
                -__SMALL_HINGE__THICKNESS, -__SMALL_HINGE__THICKNESS + __SMALL_HINGE__PLUG_VERTICAL_CLEARANCE + 15,
                -__SMALL_HINGE__THICKNESS / 2
            ])
                cube([
                    __SMALL_HINGE__THICKNESS * 2,
                    __SMALL_HINGE__THICKNESS * 2 - __SMALL_HINGE__PLUG_VERTICAL_CLEARANCE * 2,
                    __SMALL_HINGE__THICKNESS / 2 +
                    INNER_STAND_FLOOR_ELEVATION
                ]);
        }

        duplicate_and_mirror() duplicate_and_mirror([ 0, 1, 0 ])
            translate([ __SMALL_HINGE__THICKNESS / 2, -OUTER_SHELL_INNER_WIDTH / 2, -__SMALL_HINGE__THICKNESS / 2 ])
                rotate([ -90, 0, 0 ]) cylinder(h = 10 - __SMALL_HINGE__GEAR_OFFSET_HEIGHT, r = HINGE_GEAR_OUTER_RADIUS);

        if (INCLUDE_INNER_STAND_ENGRAVING)
        {
            render() union()
            {
                render() translate([ 0, 0, INNER_STAND_FLOOR_ELEVATION + _EPSILON - ENGRAVING_LEVEL_DEPTH ])
                    linear_extrude(ENGRAVING_LEVEL_DEPTH + _EPSILON) scale(MAIN_SCALE / INTERNAL_MAIN_SCALE)
                        import(INNER_STAND_ENGRAVING_FILE, dpi = 25.4, center = true, layer = "level1");
                render() translate([ 0, 0, INNER_STAND_FLOOR_ELEVATION + _EPSILON - ENGRAVING_LEVEL_DEPTH * 2 ])
                    linear_extrude(ENGRAVING_LEVEL_DEPTH * 2 + _EPSILON) scale(MAIN_SCALE / INTERNAL_MAIN_SCALE)
                        import(INNER_STAND_ENGRAVING_FILE, dpi = 25.4, center = true, layer = "level2");
            }
        }

        debug_quarter_negative();
    }

    difference()
    {
        render() union()
        {
            duplicate_and_mirror() rotate_opening_angle() union()
            {
                translate([ BASE_LATTICE_OFFSET, -OUTER_SHELL_INNER_WIDTH / 2, -BASE_HEIGHT ])
                    cube([ OUTER_SHELL_INNER_WIDTH / 2 - BASE_LATTICE_OFFSET, OUTER_SHELL_INNER_WIDTH, BASE_HEIGHT ]);

                duplicate_and_mirror([ 0, 1, 0 ]) translate([ __SMALL_HINGE__THICKNESS, 5 + 15, -BASE_HEIGHT ]) cube([
                    OUTER_SHELL_INNER_WIDTH / 2 - __SMALL_HINGE__THICKNESS, OUTER_SHELL_INNER_WIDTH / 2 - 5 - 15,
                    BASE_HEIGHT
                ]);
                duplicate_and_mirror([ 0, 1, 0 ]) translate([ __SMALL_HINGE__THICKNESS, 0, -BASE_HEIGHT ])
                    cube([ OUTER_SHELL_INNER_WIDTH / 2 - __SMALL_HINGE__THICKNESS, 10, BASE_HEIGHT ]);
                // duplicate_and_mirror([ 0, 1, 0 ]) translate([ __SMALL_HINGE__THICKNESS, 5 - 15, -BASE_HEIGHT ])
                // cube([
                //     OUTER_SHELL_INNER_WIDTH / 2 - __SMALL_HINGE__THICKNESS, OUTER_SHELL_INNER_WIDTH / 2 - 5,
                //     BASE_HEIGHT
                // ]);
            }

            rotate([ 90, 0, 0 ]) translate([ 0, -__SMALL_HINGE__THICKNESS, 0 ])
                small_hinge_30mm(rotate_angle_each_side = OPENING_ANGLE_EACH_SIDE, main_clearance_scale = 0.5,
                                 plug_clearance_scale = 1, round_far_side = true);

            rotate([ 90, 0, 0 ]) translate([ 0, -__SMALL_HINGE__THICKNESS, -30 ])
                small_hinge_30mm(rotate_angle_each_side = OPENING_ANGLE_EACH_SIDE, main_clearance_scale = 0.5,
                                 plug_clearance_scale = 1, round_far_side = true, common_gear_offset = 22.5);
        };
        translate([ 0, 15, -__SMALL_HINGE__THICKNESS - _EPSILON ]) rotate([ 180, 0, 0 ]) rotate([ 0, 0, 90 ])
            engraving_text(VERSION_TEXT, 0);

        lats();
        debug_quarter_negative();
    }

    difference()
    {

        render() duplicate_and_mirror() rotate_opening_angle() difference()
        {
            render() minkowski_shell()
            {
                union()
                {
                    lid_part(INTERNAL_CUBE_EDGE_LENGTH / 2, INTERNAL_CUBE_EDGE_LENGTH, INTERNAL_CUBE_EDGE_LENGTH);
                    lid_part(INTERNAL_CUBE_EDGE_LENGTH / 2 + INNER_STAND_LIP_THICKNESS,
                             INTERNAL_CUBE_EDGE_LENGTH + INNER_STAND_LIP_THICKNESS * 2, INNER_STAND_LIP_HEIGHT);

                    translate([ 0, -OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_THICKNESS - BASE_HEIGHT ]) cube([
                        OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_INNER_WIDTH, BASE_HEIGHT + INNER_STAND_FLOOR_ELEVATION
                    ]);
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
        debug_quarter_negative();
    }
}