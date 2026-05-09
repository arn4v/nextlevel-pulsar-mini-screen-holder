model_fragment_count = 72;
$fn = model_fragment_count;

collar_color = "Black";
rod_color = "Black";
mount_boss_color = "Black";

screen_outer_diameter = 61.73;
screen_step_diameter = 55.76;
screen_outer_height = 16.00;
screen_total_height = 20.00;
radial_fit_clearance = 0.28;
axial_fit_clearance = 0.35;
support_tab_thickness = 1.20;

holder_collar_height = screen_outer_height + axial_fit_clearance + support_tab_thickness;
collar_wall_thickness = 2.00;
inner_lead_in_chamfer_height = 1.45;
inner_lead_in_chamfer_radial_depth = 0.90;
outer_edge_chamfer_height = 0.35;
outer_edge_chamfer_radial_depth = 0.22;

mount_boss_width = 14.00;
mount_boss_depth = 10.50;
mount_boss_height = holder_collar_height - 0.50;
mount_boss_corner_radius = 2.30;
mount_boss_wall_overlap = 1.20;
mount_boss_bottom_z = 0.00;

rod_length = 82.00;
rod_radius = 6;
rod_elevation_angle = 71.00;
rod_lean_angle_from_side_degrees = 0.00;
rod_base_embed_depth = 3.00;
rod_tip_rounding_radius = 6;

grip_wave_lobe_count = 7;
grip_wave_start_distance = 12.00;
grip_wave_spacing = 9.50;
grip_wave_along_rod_radius = 10.75;
grip_wave_wrap_radius = 9.25;
grip_wave_depth_radius = 9.5;
grip_wave_depth = 2.65;

screen_outer_radius = screen_outer_diameter / 2;
screen_step_radius = screen_step_diameter / 2;
outer_socket_radius = screen_outer_radius + radial_fit_clearance;
step_socket_radius = screen_step_radius + radial_fit_clearance;
screen_shoulder_z = support_tab_thickness;
collar_outer_radius = outer_socket_radius + collar_wall_thickness;
support_tab_count = 6;
support_tab_arc_degrees = 18;
support_tab_gap_arc_degrees = 360 / support_tab_count - support_tab_arc_degrees;
support_tab_gap_segments = 8;

mount_boss_center_x = -collar_outer_radius - mount_boss_depth / 2 + mount_boss_wall_overlap;
mount_boss_center_y = 0.00;

rod_base_point = [
    mount_boss_center_x,
    mount_boss_center_y,
    mount_boss_bottom_z + mount_boss_height - rod_base_embed_depth
];

rod_direction_vector = [
    -cos(rod_elevation_angle) * cos(rod_lean_angle_from_side_degrees),
    sin(rod_lean_angle_from_side_degrees),
    sin(rod_elevation_angle)
];

rod_tip_point = [
    rod_base_point[0] + rod_length * rod_direction_vector[0],
    rod_base_point[1] + rod_length * rod_direction_vector[1],
    rod_base_point[2] + rod_length * rod_direction_vector[2]
];

difference() {
    union() {
        color(collar_color)
        collar_outer_body();

        color(mount_boss_color)
        side_mount_boss();

        color(rod_color)
        rod_handle();
    }

    internal_holder_clearance();
}

module collar_outer_body() {
    cylinder(h = holder_collar_height, r = collar_outer_radius);

    translate([0, 0, outer_edge_chamfer_height])
    cylinder(
        h = holder_collar_height - 2 * outer_edge_chamfer_height,
        r = collar_outer_radius + outer_edge_chamfer_radial_depth
    );
}

module side_mount_boss() {
    translate([mount_boss_center_x, mount_boss_center_y, mount_boss_bottom_z])
    rounded_rectangular_prism(
        mount_boss_depth,
        mount_boss_width,
        mount_boss_height,
        mount_boss_corner_radius
    );
}

module rod_handle() {
    difference() {
        union() {
            oriented_cylinder_between(rod_base_point, rod_tip_point, rod_radius);

            translate(rod_tip_point)
            sphere(r = rod_tip_rounding_radius);
        }

        wave_grip_cutters();
    }
}

module wave_grip_cutters() {
    for (wave_lobe_index = [0 : grip_wave_lobe_count - 1]) {
        wave_distance = grip_wave_start_distance + wave_lobe_index * grip_wave_spacing;
        wave_side_sign = (wave_lobe_index % 2 == 0) ? 1 : -1;

        if (wave_distance < rod_length - grip_wave_spacing * 0.35) {
            wave_lobe_cutter(wave_distance, wave_side_sign);
        }
    }

    for (wave_lobe_index = [0 : grip_wave_lobe_count - 2]) {
        opposing_wave_distance = grip_wave_start_distance + grip_wave_spacing / 2 + wave_lobe_index * grip_wave_spacing;
        opposing_wave_side_sign = (wave_lobe_index % 2 == 0) ? -1 : 1;

        if (opposing_wave_distance < rod_length - grip_wave_spacing * 0.35) {
            wave_lobe_cutter(opposing_wave_distance, opposing_wave_side_sign);
        }
    }
}

module wave_lobe_cutter(distance_from_base, side_sign) {
    lobe_center_point = point_along_rod(distance_from_base);

    translate([
        lobe_center_point[0],
        lobe_center_point[1] + side_sign * (rod_radius + grip_wave_depth_radius - grip_wave_depth),
        lobe_center_point[2]
    ])
    oriented_scaled_sphere_along_rod(
        grip_wave_along_rod_radius,
        grip_wave_depth_radius,
        grip_wave_wrap_radius
    );
}

module oriented_scaled_sphere_along_rod(scale_along_rod, scale_side_to_side, scale_around_rod) {
    rotate(
        a = acos(rod_direction_vector[0]),
        v = [0, -rod_direction_vector[2], rod_direction_vector[1]]
    )
    scale([scale_along_rod, scale_side_to_side, scale_around_rod])
    sphere(r = 1);
}

module internal_holder_clearance() {
    translate([0, 0, -1.00])
    cylinder(h = screen_shoulder_z + 1.00, r = step_socket_radius);

    support_tab_gap_cutters();

    translate([0, 0, screen_shoulder_z])
    cylinder(h = holder_collar_height - screen_shoulder_z + 1.00, r = outer_socket_radius);

    translate([0, 0, holder_collar_height - inner_lead_in_chamfer_height - 0.02])
    cylinder(
        h = inner_lead_in_chamfer_height + 0.04,
        r1 = outer_socket_radius,
        r2 = outer_socket_radius + inner_lead_in_chamfer_radial_depth
    );
}

module support_tab_gap_cutters() {
    for (tab_index = [0 : support_tab_count - 1]) {
        rotate([0, 0, (tab_index + 0.5) * 360 / support_tab_count])
        linear_extrude(height = screen_shoulder_z + 1.00)
        annular_sector_2d(
            step_socket_radius - 0.02,
            outer_socket_radius + 0.02,
            support_tab_gap_arc_degrees,
            support_tab_gap_segments
        );
    }
}

module annular_sector_2d(inner_radius, outer_radius, arc_degrees, segment_count) {
    half_arc = arc_degrees / 2;

    polygon(concat(
        [
            for (segment_index = [0 : segment_count])
            let(angle = -half_arc + arc_degrees * segment_index / segment_count)
            [outer_radius * cos(angle), outer_radius * sin(angle)]
        ],
        [
            for (segment_index = [segment_count : -1 : 0])
            let(angle = -half_arc + arc_degrees * segment_index / segment_count)
            [inner_radius * cos(angle), inner_radius * sin(angle)]
        ]
    ));
}

function point_along_rod(distance_from_base) = [
    rod_base_point[0] + distance_from_base * rod_direction_vector[0],
    rod_base_point[1] + distance_from_base * rod_direction_vector[1],
    rod_base_point[2] + distance_from_base * rod_direction_vector[2]
];

module rounded_rectangular_prism(size_x, size_y, size_z, corner_radius) {
    hull() {
        for (x_sign = [-1, 1]) {
            for (y_sign = [-1, 1]) {
                translate([
                    x_sign * (size_x / 2 - corner_radius),
                    y_sign * (size_y / 2 - corner_radius),
                    0
                ])
                cylinder(h = size_z, r = corner_radius);
            }
        }
    }
}

module oriented_cylinder_between(start_point, end_point, cylinder_radius) {
    connection_vector = [
        end_point[0] - start_point[0],
        end_point[1] - start_point[1],
        end_point[2] - start_point[2]
    ];

    connection_length = norm(connection_vector);
    rotation_axis = [-connection_vector[1], connection_vector[0], 0];

    translate(start_point)
    rotate(a = acos(connection_vector[2] / connection_length), v = rotation_axis)
    cylinder(h = connection_length, r = cylinder_radius);
}
