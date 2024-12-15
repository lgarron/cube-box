LID_OVEROPENED_FLAT_ANGLE = 1.45;

/********/

DESIGN_VARIANT_TEXT = "ORCHID";
VERSION_TEXT = "v0.2.25";

// Avoid setting to 0 for printing unless you want overly shaved lids
CUBE_EDGE_LENGTH = 57;        // mm
OPENING_ANGLE_EACH_SIDE = 45; // Note: flat bottom is `90 + LID_OVEROPENED_FLAT_ANGLE`, flat inner lid is `90`
INCLUDE_INNER_STAND_ENGRAVING = false;
FILL_INNER_STAND_ENGRAVING = true;
INNER_STAND_ENGRAVING_FILE = "./archived/engraving/engraving.svg";

DEBUG = false;
PRINT_IN_PLACE = DEBUG;
INCLUDE_SOLID_INFILL_SHAPE = !DEBUG;
INCLUDE_SUPPORT_BLOCKER_SHAPE = !DEBUG && PRINT_IN_PLACE;
SET_ON_SIDE_FOR_PRINTING = !DEBUG && PRINT_IN_PLACE;
SEPARATE_INNER_STAND_FOR_PRINTING = !DEBUG && !PRINT_IN_PLACE;
INCLUDE_UNSNAPPERS = true;

FORCE_INCLUDE_STAND_PLUGS = DEBUG;

$fn = DEBUG ? 64 : 90;
LID_UPPER_CURVE_FN = DEBUG ? 64 : 360;
THUMB_DIVOTS_FN = DEBUG ? 64 : 360;

assert(OPENING_ANGLE_EACH_SIDE >= 4);

/********/

include <./node_modules/scad/duplicate.scad>
include <./node_modules/scad/minkowski_shell.scad>
include <./node_modules/scad/round_bevel.scad>
include <./node_modules/scad/small_hinge.scad>

/*

# Bambu Studio config steps

- 0.4mm nozzle, 0.20mm strength
- Global → Support → Support
  - Enable support → yes
  - Type: `tree(auto)`
  - On build plate only → yes
  - Remove small overhangs → no
- Objects
  - Support blocker sub-object:
    - Change type → Support Blocker
  - Solid infill sub-object:
    - Change type → Modifier
    - Sparse infill density: 100% (allow the infill pattern to be changed to rectilinear automatically)

*/

/*

## v0.2.25

- Lower the unsnapper to 1mm.

## v0.2.24

- Change back from one to two snap connectors on top (and make the unsnapper a bit smaller to accommodate).
- Change side snap connectors to 20° (while keeping the top snap connectors at 30°).

## v0.2.23

- Change `SNAP_CONNECTOR_ANGLE` to 30°.
- Try a simple centered circle unsnapper.
- Give the hinge gears a little extra rotational clearance in the inner stand.
- Give the hinge connector a little extra bottom clearance to compensate for inaccuracy from small tree supports.

## v0.2.22

- Redesign the unsnappers into a flowerier shape.
- Change to a single snpa connector on top.
- Change the lat slant to 22.5° to try to improve meshing.

## v0.2.21

- Give the lats more meshing space near the hinge.
- Move design name and version engravings to the lids.
- Add snap connectors to the top of the lid.

## v0.2.20

- Adjust bottom rounding to avoid a very thin section.
- Adjust plug head snugness.

## v0.2.19

- Move thumb divots slightly apart.
- Change overopened angle to 0° for now.
- Slant the lats where they touch near the hinge.
- Widen the bottom rounding.
- Adjust inner stand plugs.
- Lower the inner stand engraving level depth to one layer.

## v0.2.18

- Add inner stand plugs when printing the inner stand separately.
- Adjust thumb divots to give more leverage for retraction.

## v0.2.17

- Switch to printing the stand separately, with optional filled engraving.

## v0.2.16

- Double `plug_clearance_scale` for materials that print with less accurate tolerances.
- Increase `BASE_LATTICE_OFFSET_MESHING_EXTRA` to 0.5mm.

## v0.2.15

- Extend hinges to support any cube edge length.

## v0.2.14

- Bump `scad`.

## v0.2.13

- Decrease hinge thickness to 6mm.

## v0.2.12

- Increase lat offset to add more tolerance for folding fully open.

## v0.2.11

- Set all symmetry shaving to 0.15mm.
- Increase hinge thickness to 7mm.

## v0.2.10

- Lower the version engravings back into the hinges at the right depth.

## v0.2.8

- Fix hinge tangent shaving for in-place printing.
- Adjust the support blocker the engraving so that it doesn't block the bottom of the inner plate for ≈90° hinge
printing.

## v0.2.7

- Fix calculations about the height taken up by gears.

## v0.2.6

- Allow lids to overextend their rotation so they can lay flat.

## v0.2.5

- Include solid infill shape.

## v0.2.4

- Add design variant engraving.
- Allow the inner stand to be printed separately.
- Adjust `difference(…)` calculations to work at 90 degrees.

## v0.2.3

- Move the inner stand clearance to the inside and increase to 0.25mm.
- Decrease engraving depth.
- Increase lat clearance for lower-friction end motion.
- Add a rounded bottom side to test push-down closing.
- Add thumb divots to the lid tops.

## v0.2.2

- Restore clearance for the inner stand.

## v0.2.1

- Fix 180° rotational symmetry for the hinge gears.

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

HINGE_THICKNESS = 6;

DEFAULT_CLEARANCE = 0.1;
MAIN_CLEARANCE_SCALE = 0.5;
SLIDING_CLEARANCE = 0.2;

INNER_STAND_CLEARANCE = 0.25;

LARGE_VALUE = 200;

INNER_STAND_LIP_THICKNESS = 1.5;
INNER_STAND_LIP_HEIGHT = 8;
INNER_STAND_FLOOR_ELEVATION = INNER_STAND_LIP_THICKNESS;

INNER_STAND_ENGRAVING_LEVEL_DEPTH = 0.2;

LAT_WIDTH = 4;

OUTER_SHELL_THICKNESS = 1.5;

module main_cube()
{
    translate([ 0, 0, CUBE_EDGE_LENGTH / 2 ]) cube(CUBE_EDGE_LENGTH, center = true);
};
module main_cube_on_stand()
{
    translate([ 0, 0, INNER_STAND_FLOOR_ELEVATION ]) main_cube();
};

OUTER_SHELL_INNER_WIDTH = CUBE_EDGE_LENGTH + INNER_STAND_LIP_THICKNESS * 2;
OUTER_SHELL_OUTER_WIDTH = OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS;

GEAR_MAX_RADIAL_DIVERGENCE = HINGE_THICKNESS / 2 * __SMALL_HINGE__MAX_RADIAL_DIVERGENCE_FACTOR;
BASE_HEIGHT = HINGE_THICKNESS + GEAR_MAX_RADIAL_DIVERGENCE;

HINGE_GEAR_OUTER_RADIUS = HINGE_THICKNESS / 2 + GEAR_MAX_RADIAL_DIVERGENCE;

BASE_LATTICE_OFFSET_MESHING_EXTRA = -__SMALL_HINGE__CONNECTOR_OUTSIDE_CLEARANCE + DEFAULT_CLEARANCE;

BASE_LATTICE_OFFSET_INNER = HINGE_THICKNESS + DEFAULT_CLEARANCE + BASE_LATTICE_OFFSET_MESHING_EXTRA;
BASE_LATTICE_OFFSET_OUTER = BASE_LATTICE_OFFSET_INNER + DEFAULT_CLEARANCE * 2;
BASE_LATTICE_COMPLEMENT_OFFSET = HINGE_THICKNESS;

LAT_SLANT = 22.5;

module lat(i, mirror_scale)
{
    scale([ mirror_scale, 1, 1 ]) difference()
    {
        translate([
            -LARGE_VALUE / 2, i * LAT_WIDTH * 2 + LAT_WIDTH / 2 + mirror_scale * LAT_WIDTH / 2 - SLIDING_CLEARANCE,
            -BASE_HEIGHT - _EPSILON -
            LARGE_VALUE
        ])
            cube([
                LARGE_VALUE, LAT_WIDTH + SLIDING_CLEARANCE * 2,
                GEAR_MAX_RADIAL_DIVERGENCE * 2 + _EPSILON + DEFAULT_CLEARANCE +
                LARGE_VALUE
            ]);
        translate([ BASE_LATTICE_OFFSET_INNER, 0, -HINGE_THICKNESS + __SMALL_HINGE__PLUG_VERTICAL_CLEARANCE ])
            rotate([ 0, 90 - LAT_SLANT, 0 ]) translate([ -LARGE_VALUE / 2, 0, 0 ]) cube(LARGE_VALUE, center = true);
    }
}

module rotate_for_lid_right(angle)
{
    translate([ HINGE_THICKNESS / 2, 0, -HINGE_THICKNESS / 2 ]) rotate([ 0, angle, 0 ])
        translate([ -HINGE_THICKNESS / 2, 0, HINGE_THICKNESS / 2 ]) children();
}

module rotate_for_lid_left(angle)
{
    translate([ -HINGE_THICKNESS / 2, 0, -HINGE_THICKNESS / 2 ]) rotate([ 0, -angle, 0 ])
        translate([ HINGE_THICKNESS / 2, 0, HINGE_THICKNESS / 2 ]) children();
}

LATS_EACH_SIDE = 10; // TODO: computer from cube size

module lats_bottom_slant_right()
{

    color("red") translate(
        [ BASE_LATTICE_OFFSET_OUTER - 2 * DEFAULT_CLEARANCE, 0, -HINGE_THICKNESS + __SMALL_HINGE__HINGE_SHAVE ]) union()
    {
        rotate([ 0, LAT_SLANT, 0 ]) translate([ LARGE_VALUE / 2, 0, -LARGE_VALUE / 2 ])
            cube(LARGE_VALUE, center = true);
        rotate([ 0, LAT_SLANT + 45, 0 ]) translate([ LARGE_VALUE / 2, 0, -LARGE_VALUE / 2 ])
            cube(LARGE_VALUE, center = true);
    }
}

module right_lats()
{
    render() union()
    {
        for (i = [-LATS_EACH_SIDE:LATS_EACH_SIDE])
        {
            lat(i, 1);
        }
        lats_bottom_slant_right();
    }
}

module left_lats()
{
    render() union()
    {
        for (i = [-LATS_EACH_SIDE:LATS_EACH_SIDE])
        {
            lat(i, -1);
        }
        mirror([ 1, 0, 0 ]) lats_bottom_slant_right();
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

function get_lid_radius_w(w_h) = w_h[0] - HINGE_THICKNESS / 2;
function get_lid_radius_h(w_h) = w_h[1] + INNER_STAND_FLOOR_ELEVATION + HINGE_THICKNESS / 2;
function get_lid_radius(w_h) = sqrt(pow(get_lid_radius_w(w_h), 2) + pow(get_lid_radius_h(w_h), 2));

module lid_part(w_h, d, pre_angle_to_lie_flat_on_table = false)
{
    w = w_h[0];
    h = w_h[1];

    lid_radius_w = get_lid_radius_w(w_h);
    lid_radius_h = get_lid_radius_h(w_h);
    lid_radius = get_lid_radius(w_h);

    difference()
    {
        rotate_for_lid_right(angle = pre_angle_to_lie_flat_on_table ? -LID_OVEROPENED_FLAT_ANGLE : 0) difference()
        {
            rotate_for_lid_right(angle = pre_angle_to_lie_flat_on_table ? LID_OVEROPENED_FLAT_ANGLE : 0)
                translate([ HINGE_THICKNESS / 2, 0, -HINGE_THICKNESS / 2 ]) rotate([ 90, 0, 0 ])
                    cylinder(h = d, r = lid_radius, center = true, $fn = LID_UPPER_CURVE_FN);
            translate([ LARGE_VALUE / 2 + w, 0, 0 ]) cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
        }
        translate([ -LARGE_VALUE / 2 + HINGE_THICKNESS / 2, 0, 0 ])
            cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
        translate([ 0, 0, -LARGE_VALUE / 2 + INNER_STAND_FLOOR_ELEVATION ])
            cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);
    }

    translate([ 0, -d / 2, INNER_STAND_FLOOR_ELEVATION ])
        cube([ HINGE_THICKNESS / 2, d, lid_radius - lid_radius_h + h ]);
}

VERSION_TEXT_ENGRAVING_DEPTH = 0.25;

module engraving_text(text_string, _epsilon, valign = "center", halign = "center")
{
    translate([ 0, 0, -VERSION_TEXT_ENGRAVING_DEPTH ]) linear_extrude(VERSION_TEXT_ENGRAVING_DEPTH + _epsilon)
        text(text_string, size = 4, font = "Ubuntu:style=bold", valign = valign, halign = halign);
}

BOTTOM_ROUNDING_RADIUS_X = 8;
BOTTOM_ROUNDING_RADIUS_Z = 18;

module bottom_rounding_negative()
{
    render() difference()
    {
        translate([
            LARGE_VALUE / 2 + OUTER_SHELL_INNER_WIDTH / 2 - BOTTOM_ROUNDING_RADIUS_X, 0,
            -LARGE_VALUE / 2 - BASE_HEIGHT +
            BOTTOM_ROUNDING_RADIUS_Z
        ]) cube(LARGE_VALUE, center = true);
        minkowski()
        {
            translate(
                [ OUTER_SHELL_INNER_WIDTH / 2 - BOTTOM_ROUNDING_RADIUS_X, 0, -BASE_HEIGHT + OUTER_SHELL_THICKNESS ])
                rotate([ 90, 0, 0 ]) linear_extrude(OUTER_SHELL_INNER_WIDTH, center = true)
                    import("./bottom_rounding_negative_v0.2.20.svg", dpi = 25.4);
            sphere(OUTER_SHELL_THICKNESS);
        }
    }
}

THUMB_DIVOT_RADIUS = 20;
THUMB_DIVOT_DEPTH = 0.75;
THUMB_DIVOT_X = CUBE_EDGE_LENGTH / 6;
THUMB_DIVOT_Y = INNER_STAND_FLOOR_ELEVATION + CUBE_EDGE_LENGTH * 0.97;

HINGE_CONNECTOR_ALIGNMENT_EXTRA_HEIGHT = 0.2;
HINGE_CONNECTOR_ALIGNMENT_STUB_WIDTH = 5;

HINGE_PLUG_ROUNDING = 1;
INNER_STAND_PLUG_HORIZONTAL_CLEARANCE = 0.1;
INNER_STAND_PLUG_VERTICAL_CLEARANCE = 0.05;
PLUG_STEM_RADIUS = 3;
PLUG_HEAD_RADIUS = 3.125;
PLUG_HEIGHT = HINGE_THICKNESS * 0.55;
PLUG_HEAD_HEIGHT = 1.5;
PLUG_TOP_EXPANSION_HEIGHT = 1;
PLUG_TOP_EXPANSION_EXTRA_RADIUS = 1;

INCLUDE_STAND_PLUGS = SEPARATE_INNER_STAND_FOR_PRINTING || FORCE_INCLUDE_STAND_PLUGS;
module stand_plug(negative = false)
{
    if (INCLUDE_STAND_PLUGS)
    {
        negative_clearance = (INCLUDE_STAND_PLUGS && negative ? INNER_STAND_PLUG_HORIZONTAL_CLEARANCE : 0);
        render() minkowski()
        {
            union()
            {
                translate([ 0, -15, -PLUG_HEIGHT ])
                    cylinder(h = PLUG_HEIGHT + INNER_STAND_CLEARANCE + _EPSILON - PLUG_TOP_EXPANSION_HEIGHT,
                             r = PLUG_STEM_RADIUS);
                h = PLUG_TOP_EXPANSION_HEIGHT + HINGE_CONNECTOR_ALIGNMENT_EXTRA_HEIGHT + INNER_STAND_CLEARANCE +
                    INNER_STAND_PLUG_HORIZONTAL_CLEARANCE + _EPSILON;
                translate([ 0, -15, -PLUG_TOP_EXPANSION_HEIGHT ])
                    cylinder(h = h, r1 = PLUG_STEM_RADIUS,
                             r2 = PLUG_STEM_RADIUS + h // Reuse `h` so that we have an angle of 45°.
                    );
            }
            sphere(negative_clearance);
        }
        render() minkowski()
        {
            translate([ 0, -15, -PLUG_HEIGHT - negative_clearance ])
                cylinder(h = PLUG_HEAD_HEIGHT -
                             HINGE_PLUG_ROUNDING, // Note: the height purposely excludes clearance for a snug top.
                         r = PLUG_HEAD_RADIUS + negative_clearance / 2 -
                             HINGE_PLUG_ROUNDING // We purposely reduce the top clearance for a snug fit.
                );
            sphere(HINGE_PLUG_ROUNDING);
        }
    }
}

module hinge_connectors(negative = false)
{
    difference()
    {
        negative_horizontal_clearance = (INCLUDE_STAND_PLUGS && negative ? INNER_STAND_PLUG_HORIZONTAL_CLEARANCE : 0);
        negative_vertical_clearance = (INCLUDE_STAND_PLUGS && negative ? INNER_STAND_PLUG_VERTICAL_CLEARANCE : 0);
        duplicate_and_mirror([ 0, 1, 0 ]) translate([
            -HINGE_THICKNESS + __SMALL_HINGE__CONNECTOR_OUTSIDE_CLEARANCE - negative_horizontal_clearance,
            10 + __SMALL_HINGE__PLUG_VERTICAL_CLEARANCE - negative_horizontal_clearance, -HINGE_THICKNESS / 2
        ])
            cube([
                HINGE_THICKNESS * 2 - 2 * __SMALL_HINGE__CONNECTOR_OUTSIDE_CLEARANCE +
                    2 * negative_horizontal_clearance,
                10 - 2 * __SMALL_HINGE__PLUG_VERTICAL_CLEARANCE + 2 * negative_horizontal_clearance,
                HINGE_THICKNESS / 2 + INNER_STAND_CLEARANCE + HINGE_CONNECTOR_ALIGNMENT_EXTRA_HEIGHT +
                negative_vertical_clearance
            ]);

        duplicate_and_mirror([ 0, 1, 0 ]) stand_plug(negative = !negative);

        debug_quarter_negative();
    }
}

INNER_STAND_HINGE_GEAR_ARCH_EXTRA_DEGREES = 5;

module inner_stand()
{

    render() difference()
    {
        render() difference()
        {
            minkowski()
            {
                main_cube();
                translate([ 0, 0, INNER_STAND_LIP_THICKNESS ])
                    sphere(INNER_STAND_LIP_THICKNESS - INNER_STAND_CLEARANCE);
            }

            main_cube_on_stand();
            translate([ 0, 0, LARGE_VALUE / 2 + INNER_STAND_FLOOR_ELEVATION + INNER_STAND_LIP_HEIGHT ])
                cube(LARGE_VALUE, center = true);

            if (!PRINT_IN_PLACE)
            {
                hinge_connectors(negative = true);
            }
        }

        duplicate_and_mirror() duplicate_and_mirror([ 0, 1, 0 ])
            duplicate_and_translate([ 0, -OUTER_SHELL_INNER_WIDTH / 2, 0 ])
                translate([ HINGE_THICKNESS / 2, 0, -HINGE_THICKNESS / 2 ]) difference()
        {
            rotate([ -90, 0, 0 ]) cylinder(h = 10 - __SMALL_HINGE__GEAR_OFFSET_HEIGHT, r = HINGE_GEAR_OUTER_RADIUS);
            translate([ HINGE_THICKNESS / 2, 0, -HINGE_THICKNESS / 2 ])
                rotate([ 0, INNER_STAND_HINGE_GEAR_ARCH_EXTRA_DEGREES, 0 ])
                    translate([ -HINGE_THICKNESS / 2, 0, HINGE_THICKNESS / 2 ])
                        translate([ LARGE_VALUE / 2 + DEFAULT_CLEARANCE, 0, 0 ]) cube(LARGE_VALUE, center = true);
        }

        if (INCLUDE_INNER_STAND_ENGRAVING)
        {
            render() union()
            {
                render() translate([ 0, 0, INNER_STAND_FLOOR_ELEVATION + _EPSILON - INNER_STAND_ENGRAVING_LEVEL_DEPTH ])
                    linear_extrude(INNER_STAND_ENGRAVING_LEVEL_DEPTH + _EPSILON)
                        import(INNER_STAND_ENGRAVING_FILE, dpi = 25.4, center = true);
            }
        }

        debug_quarter_negative();
    }
    duplicate_and_mirror([ 0, 1, 0 ]) stand_plug(false);
}

module pre_lats_right()
{
    rotate_for_lid_right(LID_OVEROPENED_FLAT_ANGLE) difference()
    {
        rotate_for_lid_right(LID_OVEROPENED_FLAT_ANGLE) difference()
        {
            children();
            bottom_rounding_negative();
            translate([
                -LARGE_VALUE / 2 + BASE_LATTICE_OFFSET_INNER, 0, -LARGE_VALUE / 2 - BASE_HEIGHT +
                GEAR_MAX_RADIAL_DIVERGENCE
            ]) cube(LARGE_VALUE, center = true);
        }

        translate([ LARGE_VALUE / 2 + OUTER_SHELL_OUTER_WIDTH / 2, 0, 0 ]) cube(LARGE_VALUE, center = true);
    }
}

HINGE_LENGTH_COMPARISON = 57;

module duplicate_and_mirror_with_corresponding_lats_and_bottom_rounding_difference()
{
    rotate_for_lid_right(OPENING_ANGLE_EACH_SIDE - 2 * LID_OVEROPENED_FLAT_ANGLE) difference()
    {
        pre_lats_right() children();
        right_lats();
    }

    rotate_for_lid_left(OPENING_ANGLE_EACH_SIDE - 2 * LID_OVEROPENED_FLAT_ANGLE) difference()
    {
        mirror([ 1, 0, 0 ]) pre_lats_right() children();
        left_lats();
    }
}

module hinge_core_hinge(second = false)
{
    translate([ 0, second ? 30 : 0, 0 ]) difference()
    {
        rotate([ 90, 0, 0 ]) translate([ 0, -HINGE_THICKNESS, 0 ]) difference()
        {
            small_hinge_30mm(main_thickness = HINGE_THICKNESS, rotate_angle_each_side = OPENING_ANGLE_EACH_SIDE,
                             main_clearance_scale = 0.5, plug_clearance_scale = 2, round_far_side = true,
                             common_gear_offset = 0, extra_degrees = LID_OVEROPENED_FLAT_ANGLE,
                             shave_end_tangents = true,
                             extend_block_ends = (CUBE_EDGE_LENGTH - HINGE_LENGTH_COMPARISON) / 2);

            translate([ 0, 0, (LARGE_VALUE / 2 + 30) * (second ? 1 : -1) ]) cube(LARGE_VALUE, center = true);
        }

        stand_plug(true);
    }
}

module hinge_core()
{
    hinge_core_hinge(false);
    hinge_core_hinge(true);
}

HINGE_CONNECTOR_BOTTOM_CLEARANCE = 0.5; // To compensate for inaccuracy from small tree supports.

module hinge()
{

    difference()
    {
        render() union()
        {
            duplicate_and_mirror_with_corresponding_lats_and_bottom_rounding_difference()
            {
                union()
                {
                    translate([ BASE_LATTICE_OFFSET_INNER, -OUTER_SHELL_INNER_WIDTH / 2, -BASE_HEIGHT ]) cube([
                        OUTER_SHELL_INNER_WIDTH / 2 - BASE_LATTICE_OFFSET_INNER, OUTER_SHELL_INNER_WIDTH,
                        BASE_HEIGHT
                    ]);

                    duplicate_and_mirror([ 0, 1, 0 ]) translate([ HINGE_THICKNESS - _EPSILON, 5 + 15, -BASE_HEIGHT ])
                        cube([
                            BASE_LATTICE_OFFSET_INNER - HINGE_THICKNESS + _EPSILON,
                            OUTER_SHELL_INNER_WIDTH / 2 - 5 - 15,
                            BASE_HEIGHT
                        ]);
                    duplicate_and_mirror([ 0, 1, 0 ]) translate([ HINGE_THICKNESS, 0, -BASE_HEIGHT ])
                        cube([ BASE_LATTICE_OFFSET_INNER - HINGE_THICKNESS + _EPSILON, 10, BASE_HEIGHT ]);
                }
            }

            hinge_core();
        };
        duplicate_and_mirror([ 0, 1, 0 ]) translate([
            -HINGE_THICKNESS + _EPSILON, 15 - 5 + __SMALL_HINGE__PLUG_VERTICAL_CLEARANCE, -HINGE_THICKNESS + _EPSILON
        ])
            cube([
                HINGE_THICKNESS * 2 - 2 * _EPSILON, 10 - 2 * __SMALL_HINGE__PLUG_VERTICAL_CLEARANCE,
                HINGE_CONNECTOR_BOTTOM_CLEARANCE -
                _EPSILON
            ]);

        debug_quarter_negative();
    }
}

// TODO: this value is exact, but there's probably a neater way to make this calculation come from arithmetic with
// places.
DEFAULT_CLEARANCE_FACTOR_FOR_LID_SHAVE_TO_MATCH_LATS_AT_90_DEGREES = 3;

ENGRAVING_TEXT_CORNER_OFFSET_X = 2;
ENGRAVING_TEXT_CORNER_OFFSET_Y = 4;

module engraving()
{
    union()
    {
        rotate_for_lid_left(OPENING_ANGLE_EACH_SIDE)
        {
            translate([
                -ENGRAVING_TEXT_CORNER_OFFSET_X, -OUTER_SHELL_OUTER_WIDTH / 2, ENGRAVING_TEXT_CORNER_OFFSET_Y -
                BASE_HEIGHT
            ]) rotate([ 90, 0, 0 ]) resize([ 0, 0, VERSION_TEXT_ENGRAVING_DEPTH ], auto = true)
                engraving_text(DESIGN_VARIANT_TEXT, _EPSILON, valign = "bottom", halign = "right");
        }

        rotate_for_lid_right(OPENING_ANGLE_EACH_SIDE)
        {
            translate([
                ENGRAVING_TEXT_CORNER_OFFSET_X, -OUTER_SHELL_OUTER_WIDTH / 2, ENGRAVING_TEXT_CORNER_OFFSET_Y -
                BASE_HEIGHT
            ]) rotate([ 90, 0, 0 ]) engraving_text(VERSION_TEXT, _EPSILON, valign = "bottom", halign = "left");
        }
    }
}

/********/

LID_UPPER_CURVE_W_H = [ OUTER_SHELL_INNER_WIDTH / 2, CUBE_EDGE_LENGTH ];
LID_LOWER_CURVE_W_H = [ OUTER_SHELL_INNER_WIDTH / 2, INNER_STAND_LIP_HEIGHT ];

/********/

SNAP_CONNECTOR_RADIUS = 2.5;
SNAP_CONNECTOR_TOP_ANGLE = 30;
SNAP_CONNECTOR_SIDE_ANGLE = 20;

assert(SNAP_CONNECTOR_TOP_ANGLE <=
       45); // The code below assumes this, in order to avoid creating shapes unbounded in size.
assert(SNAP_CONNECTOR_SIDE_ANGLE <=
       45); // The code below assumes this, in order to avoid creating shapes unbounded in size.
;

LID_TOP_INNER_ELEVATION = get_lid_radius(LID_UPPER_CURVE_W_H) - HINGE_THICKNESS / 2;
SIDE_SNAP_CONNECTOR_ELEVATION = LID_TOP_INNER_ELEVATION - 15;

SNAP_CONNECTOR_NEGATIVE_CURVE_COMPENSATION_THICKNESS = 5; // Way too much, but gets the job done.

module snap_connector(angle)
{
    ROUNDING_Y = 1 / cos(angle) *
                 (-SNAP_CONNECTOR_RADIUS - 2 * SNAP_CONNECTOR_RADIUS * pow(cos(angle), 2) +
                  SNAP_CONNECTOR_RADIUS * sin(angle) - 2 * SNAP_CONNECTOR_RADIUS * pow(sin(angle), 2));

    render() mirror([ 1, 0, 0 ]) difference()
    {
        union()
        {
            translate([ 0, -DEFAULT_CLEARANCE / 2 / cos(angle), 0 ]) union()
            {
                rotate([ 0, 0, angle - 90 ])
                {
                    translate([ SNAP_CONNECTOR_RADIUS, 0, 0 ])
                        cylinder(h = OUTER_SHELL_THICKNESS, r = SNAP_CONNECTOR_RADIUS);
                    mirror([ 0, 1, 0 ])
                        cube([ SNAP_CONNECTOR_RADIUS * 2, SNAP_CONNECTOR_RADIUS * 2, OUTER_SHELL_THICKNESS ]);
                }

                difference()
                {
                    translate([ SNAP_CONNECTOR_RADIUS, ROUNDING_Y, 0 ]) rotate([ 0, 0, 90 + angle ])
                        cube([ SNAP_CONNECTOR_RADIUS, SNAP_CONNECTOR_RADIUS, OUTER_SHELL_THICKNESS ]);
                    translate([ SNAP_CONNECTOR_RADIUS, ROUNDING_Y, -_EPSILON ])
                        cylinder(h = OUTER_SHELL_THICKNESS + 2 * _EPSILON, r = SNAP_CONNECTOR_RADIUS);
                    translate([ SNAP_CONNECTOR_RADIUS, ROUNDING_Y, -_EPSILON ]) rotate([ 0, 0, 90 ]) mirror([ 1, 0, 0 ])
                        cube([
                            2 * SNAP_CONNECTOR_RADIUS, 2 * SNAP_CONNECTOR_RADIUS, OUTER_SHELL_THICKNESS + 2 * _EPSILON
                        ]);
                }
            }
        }
        translate([ -LARGE_VALUE / 2 - DEFAULT_CLEARANCE / 2 - _EPSILON, 0, 0 ]) cube(LARGE_VALUE, center = true);
    }
}

module snap_connector_negative(angle)
{
    render() translate([ -DEFAULT_CLEARANCE, 0, 0 ]) difference()
    {
        minkowski()
        {
            rotate([ 0, 0, 180 ]) snap_connector(angle);
            cylinder(h = SNAP_CONNECTOR_NEGATIVE_CURVE_COMPENSATION_THICKNESS * 2, r = DEFAULT_CLEARANCE / 2,
                     center = true);
        }
        translate([ -LARGE_VALUE / 2 - _EPSILON, 0, 0 ]) cube(LARGE_VALUE, center = true);
    }
}

/********/

module lids()
{

    union()
    {
        difference()
        {

            union()
            {
                render() duplicate_and_mirror_with_corresponding_lats_and_bottom_rounding_difference() difference()
                {
                    union()
                    {
                        render() minkowski_shell()
                        {
                            union()
                            {
                                // lid_part(CUBE_EDGE_LENGTH / 2, CUBE_EDGE_LENGTH,
                                // CUBE_EDGE_LENGTH);
                                lid_part_upper();
                                lid_part(LID_LOWER_CURVE_W_H, CUBE_EDGE_LENGTH + INNER_STAND_LIP_THICKNESS * 2);

                                translate([ 0, -OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_THICKNESS - BASE_HEIGHT ])
                                    cube([
                                        OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_INNER_WIDTH, BASE_HEIGHT +
                                        INNER_STAND_FLOOR_ELEVATION
                                    ]);
                            }

                            sphere(OUTER_SHELL_THICKNESS);
                        }

                        translate([ OUTER_SHELL_INNER_WIDTH / 2, OUTER_SHELL_INNER_WIDTH / 2, 0 ])
                            rotate([ 90, -90, 0 ])
                                round_bevel_complement(OUTER_SHELL_INNER_WIDTH, INNER_STAND_LIP_THICKNESS);
                    }

                    translate([ -LARGE_VALUE / 2, 0, 0 ])
                        cube([ LARGE_VALUE, LARGE_VALUE, LARGE_VALUE ], center = true);

                    translate([
                        -BASE_LATTICE_OFFSET_OUTER, -(OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS) / 2,
                        -BASE_HEIGHT -
                        _EPSILON
                    ])
                        cube([
                            BASE_LATTICE_OFFSET_OUTER * 2, OUTER_SHELL_OUTER_WIDTH, GEAR_MAX_RADIAL_DIVERGENCE +
                            _EPSILON
                        ]);
                    translate([ -BASE_LATTICE_OFFSET_OUTER, -(OUTER_SHELL_INNER_WIDTH) / 2, -BASE_HEIGHT - _EPSILON ])
                        cube([ BASE_LATTICE_OFFSET_OUTER * 2, OUTER_SHELL_INNER_WIDTH, BASE_HEIGHT + _EPSILON ]);

                    translate([ 0, 0, -HINGE_THICKNESS ]) rotate([ 90, 0, 0 ]) round_bevel_complement(
                        height = OUTER_SHELL_INNER_WIDTH + 2 * OUTER_SHELL_THICKNESS + 2 * _EPSILON,
                        radius = HINGE_THICKNESS / 2, center_z = true);

                    duplicate_and_mirror([ 0, 1, 0 ]) translate([
                        THUMB_DIVOT_X,
                        -CUBE_EDGE_LENGTH / 2 - OUTER_SHELL_THICKNESS - THUMB_DIVOT_RADIUS + THUMB_DIVOT_DEPTH,
                        THUMB_DIVOT_Y
                    ]) sphere(THUMB_DIVOT_RADIUS, $fn = THUMB_DIVOTS_FN);
                }
            }

            render() union()
            {
                rotate_for_lid_right(OPENING_ANGLE_EACH_SIDE) duplicate_and_mirror([ 0, 1, 0 ])
                    translate([ 0, 15, LID_TOP_INNER_ELEVATION ]) snap_connector_negative(SNAP_CONNECTOR_TOP_ANGLE);
                rotate_for_lid_left(OPENING_ANGLE_EACH_SIDE) duplicate_and_mirror([ 0, 1, 0 ])
                    translate([ 0, 15, LID_TOP_INNER_ELEVATION ]) rotate([ 0, 0, 180 ])
                        snap_connector_negative(SNAP_CONNECTOR_TOP_ANGLE);

                duplicate_and_rotate([ 0, 0, 180 ]) rotate_for_lid_right(OPENING_ANGLE_EACH_SIDE)
                    translate([ 0, -OUTER_SHELL_INNER_WIDTH / 2, SIDE_SNAP_CONNECTOR_ELEVATION ]) rotate([ -90, 0, 0 ])
                        snap_connector_negative(SNAP_CONNECTOR_SIDE_ANGLE);
                duplicate_and_rotate([ 0, 0, 180 ]) rotate_for_lid_left(OPENING_ANGLE_EACH_SIDE)
                    translate([ 0, -OUTER_SHELL_INNER_WIDTH / 2, SIDE_SNAP_CONNECTOR_ELEVATION ]) rotate([ -90, 0, 0 ])
                        rotate([ 0, 0, 180 ]) snap_connector_negative(SNAP_CONNECTOR_SIDE_ANGLE);

                if (INCLUDE_UNSNAPPERS)
                {
                    duplicate_and_rotate([ 0, 0, 180 ]) rotate_for_lid_right(OPENING_ANGLE_EACH_SIDE)
                        unsnapper_finger_indentations_right();
                }
            }

            translate([
                0, 0,
                LARGE_VALUE / 2 - BASE_LATTICE_COMPLEMENT_OFFSET -
                    DEFAULT_CLEARANCE_FACTOR_FOR_LID_SHAVE_TO_MATCH_LATS_AT_90_DEGREES *
                DEFAULT_CLEARANCE
            ]) cube([ 2 * DEFAULT_CLEARANCE, LARGE_VALUE, LARGE_VALUE ], center = true);

            engraving();
            rotate([ 0, 0, 180 ]) engraving();

            debug_quarter_negative();
        }

        render() union()
        {
            // TODO: round snap connector plug with the lid?
            rotate_for_lid_right(OPENING_ANGLE_EACH_SIDE) duplicate_and_mirror([ 0, 1, 0 ])
                translate([ 0, 15, LID_TOP_INNER_ELEVATION ]) snap_connector(SNAP_CONNECTOR_TOP_ANGLE);
            rotate_for_lid_left(OPENING_ANGLE_EACH_SIDE) duplicate_and_mirror([ 0, 1, 0 ])
                translate([ 0, 15, LID_TOP_INNER_ELEVATION ]) rotate([ 0, 0, 180 ])
                    snap_connector(SNAP_CONNECTOR_TOP_ANGLE);

            duplicate_and_rotate([ 0, 0, 180 ]) rotate_for_lid_right(OPENING_ANGLE_EACH_SIDE)
                translate([ 0, -OUTER_SHELL_INNER_WIDTH / 2, SIDE_SNAP_CONNECTOR_ELEVATION ]) rotate([ -90, 0, 0 ])
                    snap_connector(SNAP_CONNECTOR_SIDE_ANGLE);
            duplicate_and_rotate([ 0, 0, 180 ]) rotate_for_lid_left(OPENING_ANGLE_EACH_SIDE)
                translate([ 0, -OUTER_SHELL_INNER_WIDTH / 2, SIDE_SNAP_CONNECTOR_ELEVATION ]) rotate([ -90, 0, 0 ])
                    rotate([ 0, 0, 180 ]) snap_connector(SNAP_CONNECTOR_SIDE_ANGLE);

            if (INCLUDE_UNSNAPPERS)
            {
                duplicate_and_rotate([ 0, 0, 180 ]) rotate_for_lid_right(OPENING_ANGLE_EACH_SIDE) unsnapper_right();
            }
        }
    }
}

PETAL_EXTRA_HEIGHT = 1;
PETAL_INNER_OFFSET = 0;

module lid_part_upper()
{
    lid_part(LID_UPPER_CURVE_W_H, CUBE_EDGE_LENGTH, pre_angle_to_lie_flat_on_table = true);
}

module petal_inner()
{

    translate([ PETAL_INNER_OFFSET, 0, LID_TOP_INNER_ELEVATION - UNSNAPPER_DESCENDER_COMPENSATION_Z ])
        scale([ 1, 1, 1 ])
            cylinder(h = OUTER_SHELL_THICKNESS + UNSNAPPER_DESCENDER_COMPENSATION_Z + PETAL_EXTRA_HEIGHT, r = 6);
}

module unsnapper_finger_indentations_right()
{
    // intersection()
    // {
    //     petal_inner();
    //     translate([ 5.82 + PETAL_INNER_OFFSET, 0, 0 ]) rotate([ 0, 20, 0 ])
    //         translate([ 0, 0, LARGE_VALUE / 2 + LID_TOP_INNER_ELEVATION ]) cube(LARGE_VALUE, center = true);
    // }
}

UNSNAPPER_DESCENDER_COMPENSATION_Z = 10;

module petal()
{
    difference()
    {
        translate([ PETAL_INNER_OFFSET, 0, LID_TOP_INNER_ELEVATION - UNSNAPPER_DESCENDER_COMPENSATION_Z ])
            cylinder(h = OUTER_SHELL_THICKNESS + UNSNAPPER_DESCENDER_COMPENSATION_Z + PETAL_EXTRA_HEIGHT, r = 8);

        petal_inner();
    }
}

module unsnapper_right()
{
    difference()
    {
        union()
        {
            petal();
        }
        translate([ -LARGE_VALUE / 2, 0, 0 ]) cube(LARGE_VALUE, center = true);

        lid_part_upper();
    }
}

rotate([ SET_ON_SIDE_FOR_PRINTING ? -90 : 0, 0, 0 ]) union()
{
    if (DEBUG)
    {
        % main_cube_on_stand();
    }
    if (!SEPARATE_INNER_STAND_FOR_PRINTING)
    {

        inner_stand();
    }
    color("#ff2200") hinge_connectors();
    color("#ff8844") hinge();
    color("#5588ff") lids();
}

GEAR_SUPPORT_BLOCKER_EXTRA = 0.5;

if (INCLUDE_SOLID_INFILL_SHAPE && !DEBUG)
{
    rotate([ SET_ON_SIDE_FOR_PRINTING ? -90 : 0, 0, 0 ]) color("blue") union()
    {
        hinge_core();
        translate([ 0, 10, CUBE_EDGE_LENGTH * 1.25 ]) rotate([ 90, 0, 0 ]) linear_extrude(1)
            text("SOLID INFILL", size = 5, font = "Ubuntu:style=bold", valign = "center", halign = "center");
        hinge_connectors();
    }
}

if (INCLUDE_SUPPORT_BLOCKER_SHAPE && !DEBUG)
{
    rotate([ SET_ON_SIDE_FOR_PRINTING ? -90 : 0, 0, 0 ]) color("red") union()
    {
        // Gears
        translate([ 0, 0, -HINGE_THICKNESS / 2 - GEAR_SUPPORT_BLOCKER_EXTRA ]) cube(
            [
                HINGE_THICKNESS * 2 + 2 * GEAR_SUPPORT_BLOCKER_EXTRA, OUTER_SHELL_OUTER_WIDTH - _EPSILON * 2,
                HINGE_THICKNESS + 2 *
                GEAR_SUPPORT_BLOCKER_EXTRA
            ],
            center = true);
        // Engraving
        translate([ 0, 0, INNER_STAND_FLOOR_ELEVATION - INNER_STAND_CLEARANCE + _EPSILON ]) cube(
            [ OUTER_SHELL_INNER_WIDTH, OUTER_SHELL_INNER_WIDTH, INNER_STAND_FLOOR_ELEVATION - INNER_STAND_CLEARANCE ],
            center = true);

        translate([ 0, 0, CUBE_EDGE_LENGTH * 1.25 ]) rotate([ 90, 0, 0 ]) linear_extrude(1)
            text("SUPPORT BLOCKER", size = 5, font = "Ubuntu:style=bold", valign = "center", halign = "center");
    }
}

if (SEPARATE_INNER_STAND_FOR_PRINTING)
{
    rotate([ SET_ON_SIDE_FOR_PRINTING ? -90 : 0, 0, 0 ]) union()
    {
        translate([ 0, PRINT_IN_PLACE ? 0 : (OUTER_SHELL_OUTER_WIDTH + 10), 0 ]) inner_stand();
    }
}

if (INCLUDE_INNER_STAND_ENGRAVING && FILL_INNER_STAND_ENGRAVING)
{
    color("white") translate([ 0, PRINT_IN_PLACE ? 0 : (OUTER_SHELL_OUTER_WIDTH + 10), 0 ])
        rotate([ SET_ON_SIDE_FOR_PRINTING ? -90 : 0, 0, 0 ]) render() union()
    {
        render() translate([ 0, 0, INNER_STAND_FLOOR_ELEVATION - INNER_STAND_ENGRAVING_LEVEL_DEPTH * 2 ])
            linear_extrude(INNER_STAND_ENGRAVING_LEVEL_DEPTH * 2)
                import(INNER_STAND_ENGRAVING_FILE, dpi = 25.4, center = true);
    }
}
