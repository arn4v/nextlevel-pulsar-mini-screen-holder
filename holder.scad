model_fragment_count = 72;
$fn = model_fragment_count;

collar_color = "Black";
rod_color = "Black";
mount_boss_color = "Black";
thread_preview_color = "DeepSkyBlue";

male_thread_root_diameter = 56.35;
male_thread_crest_diameter = 58.00;
thread_axial_height = 2.70;
thread_axial_gap = 4.20;
threaded_section_height = 24.00;
thread_start_count = 1;
thread_twist_direction = -1;
thread_phase_degrees = 0.00;
radial_fit_clearance = 0.28;
axial_fit_clearance = 0.35;
thread_depth_extra_clearance = 0.15;
support_free_thread_flank_angle_from_horizontal = 45.00;
support_free_thread_groove_outer_flat_axial_width = 0.55;
thread_groove_radial_steps = 6;

holder_collar_height = 10.00;
collar_wall_thickness = 3.20;
inner_lead_in_chamfer_height = 1.45;
inner_lead_in_chamfer_radial_depth = 0.90;
outer_edge_chamfer_height = 0.35;
outer_edge_chamfer_radial_depth = 0.22;

mount_boss_width = 14.00;
mount_boss_depth = 10.50;
mount_boss_height = 9.50;
mount_boss_corner_radius = 2.30;
mount_boss_wall_overlap = 2.80;
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

show_thread_clearance_preview = false;

thread_slices_per_turn = 32;

male_thread_root_radius = male_thread_root_diameter / 2;
male_thread_crest_radius = male_thread_crest_diameter / 2;
female_bore_radius = male_thread_root_radius + radial_fit_clearance;
thread_pitch = thread_axial_height + thread_axial_gap;
thread_groove_radial_depth = (male_thread_crest_radius - male_thread_root_radius) + radial_fit_clearance + thread_depth_extra_clearance;
thread_groove_outer_radius = female_bore_radius + thread_groove_radial_depth;
support_free_thread_opening_axial_height = max(
    thread_axial_height + axial_fit_clearance,
    support_free_thread_groove_outer_flat_axial_width + 2 * thread_groove_radial_depth / tan(support_free_thread_flank_angle_from_horizontal)
);
collar_outer_radius = thread_groove_outer_radius + collar_wall_thickness;
threaded_section_z_offset = (holder_collar_height - threaded_section_height) / 2;
thread_slice_count = ceil(thread_slices_per_turn * threaded_section_height / thread_pitch);

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

if (show_thread_clearance_preview) {
    color(thread_preview_color, 0.35)
    translate([0, 0, threaded_section_z_offset])
    support_free_internal_helical_thread_groove_cutter();
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
    cylinder(h = holder_collar_height + 2.00, r = female_bore_radius);

    translate([0, 0, threaded_section_z_offset])
    support_free_internal_helical_thread_groove_cutter();

    translate([0, 0, -0.02])
    cylinder(
        h = inner_lead_in_chamfer_height + 0.04,
        r1 = female_bore_radius + inner_lead_in_chamfer_radial_depth,
        r2 = female_bore_radius
    );

    translate([0, 0, holder_collar_height - inner_lead_in_chamfer_height - 0.02])
    cylinder(
        h = inner_lead_in_chamfer_height + 0.04,
        r1 = female_bore_radius,
        r2 = female_bore_radius + inner_lead_in_chamfer_radial_depth
    );
}

module support_free_internal_helical_thread_groove_cutter() {
    for (thread_start_index = [0 : thread_start_count - 1]) {
        rotate([0, 0, thread_phase_degrees + 360 * thread_start_index / thread_start_count])
        helical_thread_groove_cutter_polyhedron();
    }
}

module helical_thread_groove_cutter_polyhedron() {
    polyhedron(
        points = [
            for (slice_index = [0 : thread_slice_count])
            for (radial_index = [0 : thread_groove_radial_steps])
            for (side_index = [0 : 1])
            helical_thread_groove_point(slice_index, radial_index, side_index)
        ],
        faces = concat(
            [
                for (slice_index = [0 : thread_slice_count - 1])
                for (radial_index = [0 : thread_groove_radial_steps - 1])
                [
                    helical_thread_groove_point_index(slice_index, radial_index, 0),
                    helical_thread_groove_point_index(slice_index + 1, radial_index, 0),
                    helical_thread_groove_point_index(slice_index + 1, radial_index + 1, 0),
                    helical_thread_groove_point_index(slice_index, radial_index + 1, 0)
                ]
            ],
            [
                for (slice_index = [0 : thread_slice_count - 1])
                for (radial_index = [0 : thread_groove_radial_steps - 1])
                [
                    helical_thread_groove_point_index(slice_index, radial_index, 1),
                    helical_thread_groove_point_index(slice_index, radial_index + 1, 1),
                    helical_thread_groove_point_index(slice_index + 1, radial_index + 1, 1),
                    helical_thread_groove_point_index(slice_index + 1, radial_index, 1)
                ]
            ],
            [
                for (slice_index = [0 : thread_slice_count - 1])
                [
                    helical_thread_groove_point_index(slice_index, 0, 0),
                    helical_thread_groove_point_index(slice_index, 0, 1),
                    helical_thread_groove_point_index(slice_index + 1, 0, 1),
                    helical_thread_groove_point_index(slice_index + 1, 0, 0)
                ]
            ],
            [
                for (slice_index = [0 : thread_slice_count - 1])
                [
                    helical_thread_groove_point_index(slice_index, thread_groove_radial_steps, 0),
                    helical_thread_groove_point_index(slice_index + 1, thread_groove_radial_steps, 0),
                    helical_thread_groove_point_index(slice_index + 1, thread_groove_radial_steps, 1),
                    helical_thread_groove_point_index(slice_index, thread_groove_radial_steps, 1)
                ]
            ],
            [
                for (radial_index = [0 : thread_groove_radial_steps - 1])
                [
                    helical_thread_groove_point_index(0, radial_index, 0),
                    helical_thread_groove_point_index(0, radial_index + 1, 0),
                    helical_thread_groove_point_index(0, radial_index + 1, 1),
                    helical_thread_groove_point_index(0, radial_index, 1)
                ]
            ],
            [
                for (radial_index = [0 : thread_groove_radial_steps - 1])
                [
                    helical_thread_groove_point_index(thread_slice_count, radial_index, 0),
                    helical_thread_groove_point_index(thread_slice_count, radial_index, 1),
                    helical_thread_groove_point_index(thread_slice_count, radial_index + 1, 1),
                    helical_thread_groove_point_index(thread_slice_count, radial_index + 1, 0)
                ]
            ]
        ),
        convexity = 10
    );
}

function helical_thread_groove_point(slice_index, radial_index, side_index) =
    let(
        axial_fraction = slice_index / thread_slice_count,
        radial_fraction = radial_index / thread_groove_radial_steps,
        radius = female_bore_radius + thread_groove_radial_depth * radial_fraction + (radial_index == 0 ? -0.02 : radial_index == thread_groove_radial_steps ? 0.02 : 0),
        axial_width = support_free_thread_groove_outer_flat_axial_width + (support_free_thread_opening_axial_height - support_free_thread_groove_outer_flat_axial_width) * (1 - radial_fraction),
        half_sector_angle = 180 * axial_width / thread_pitch,
        center_angle = thread_twist_direction * 360 * threaded_section_height * axial_fraction / thread_pitch,
        angle = center_angle + (side_index == 0 ? -half_sector_angle : half_sector_angle)
    )
    [
        radius * cos(angle),
        radius * sin(angle),
        threaded_section_height * axial_fraction
    ];

function helical_thread_groove_point_index(slice_index, radial_index, side_index) =
    ((slice_index * (thread_groove_radial_steps + 1) + radial_index) * 2) + side_index;

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
