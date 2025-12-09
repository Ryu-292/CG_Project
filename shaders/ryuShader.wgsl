// ============ SCENE UNIFORM (binding 1) ==================
struct Sphere {
    // xyz = position, w = radius
    posRadius : vec4<f32>,
    // rgb = color, a = unused
    color     : vec4<f32>,
};

struct Torus {
    // xyz = position, w = major radius (size.x)
    posRadius : vec4<f32>, 
    // x = thickness (size.y), yzw = unused padding
    params    : vec4<f32>, 
    // rgb = color
    color     : vec4<f32>,
};

struct Scene {
    sphere1 : Sphere,
    torus1 : Torus,
};

@group(0) @binding(1)
var<uniform> scene : Scene;

// Basic Ray Marching with Simple Primitives
@fragment
fn fs_main(@builtin(position) fragCoord: vec4<f32>) -> @location(0) vec4<f32> {
  let uv = (fragCoord.xy - uniforms.resolution * 0.5) / min(uniforms.resolution.x, uniforms.resolution.y);

  // Orbital Controll
  let pitch = clamp((uniforms.mouse.y / uniforms.resolution.y), 0.05, 1.5);
  let yaw = uniforms.time * 0.5; // Auto-orbits around the center

  // Camera Coords
  let cam_dist = 4.0; // Distance from the target
  let cam_target = vec3<f32>(0.0, 0.0, 0.0);

  // 2. Calculate the "offset" (the vector from the target to the camera)
  // We calculate the rotation on a unit sphere, then multiply by distance
  let orbit_offset = vec3<f32>(
      sin(yaw) * cos(pitch), 
      sin(pitch), 
      cos(yaw) * cos(pitch)
  ) * cam_dist;

  // 3. Add the offset to the target to get the final camera position
  let cam_pos = vec3<f32>(0.0,0.0,10.0);
  // Camera Matrix
  let cam_forward = normalize(cam_target - cam_pos);
  let cam_right = normalize(cross(cam_forward, vec3<f32>(0.0, 1.0, 0.0)));
  let cam_up = cross(cam_right, cam_forward); // Re-orthogonalized up

  // Ray Direction
  // 1.5 is the "focal length" or distance to the projection plane
  let focal_length = 1.5;
  let rd = normalize(cam_right * uv.x - cam_up * uv.y + cam_forward * focal_length);

  // Ray march
  let result = ray_march(cam_pos, rd);

  if result.x < MAX_DIST {
    // Hit something - calculate lighting
    let hit_pos = cam_pos + rd * result.x;
    let normal = get_normal(hit_pos);

    // Diffuse Lighting
    let light_pos = vec3<f32>(2.0, 5.0, -1.0);
    let light_dir = normalize(light_pos - hit_pos);
    let diffuse = max(dot(normal, light_dir), 0.0);

    // Shadow Casting
    let shadow_origin = hit_pos + normal * 0.01;
    let shadow_result = ray_march(shadow_origin, light_dir);
    let shadow = select(0.3, 1.0, shadow_result.x > length(light_pos - shadow_origin));

    // Phong Shading
    let ambient = 0.2;
    var albedo = get_material_color(result.y, hit_pos);
    let phong = albedo * (ambient + diffuse * shadow * 0.8);

    // Exponential Fog
    let fog = exp(-result.x * 0.02);
    let color = mix(MAT_SKY_COLOR, phong, fog);

    return vec4<f32>(gamma_correct(color), 1.0);
  }

  // Sky gradient
  let sky = mix(MAT_SKY_COLOR, MAT_SKY_COLOR * 0.9, uv.y * 0.5 + 0.5);
  return vec4<f32>(gamma_correct(sky), 1.0);
}

// Gamma Correction
fn gamma_correct(color: vec3<f32>) -> vec3<f32> {
  return pow(color, vec3<f32>(1.0 / 2.2));
}

// ============ CONSTANTS ==================================
const MAX_DIST: f32 = 100.0;
const SURF_DIST: f32 = 0.001;
const MAX_STEPS: i32 = 256;

// Material Types
const MAT_PLANE: f32 = 0;
const MAT_SPHERE: f32 = 1;
const MAT_BOX: f32 = 2;
const MAT_TORUS: f32 = 3;

// Material Colors
const MAT_SKY_COLOR: vec3<f32> = vec3<f32>(0.7, 0.8, 0.9);
const MAT_PLANE_COLOR: vec3<f32> = vec3<f32>(0.8, 0.8, 0.8);
const MAT_SPHERE_COLOR: vec3<f32> = vec3<f32>(1.0, 0.3, 0.3);
const MAT_BOX_COLOR: vec3<f32> = vec3<f32>(0.3, 1.0, 0.3);
const MAT_TORUS_COLOR: vec3<f32> = vec3<f32>(0.3, 0.3, 1.0);

fn get_material_color(mat_id: f32, p: vec3<f32>) -> vec3<f32> {
  if mat_id == MAT_PLANE {
    let checker = floor(p.x) + floor(p.z);
    let col1 = vec3<f32>(0.9, 0.9, 0.9);
    let col2 = vec3<f32>(0.2, 0.2, 0.2);
    return select(col2, col1, i32(checker) % 2 == 0);
  } else if mat_id == MAT_SPHERE {
    return scene.sphere1.color.rgb;
  } else if mat_id == MAT_BOX {
    return MAT_BOX_COLOR;
  } else if mat_id == MAT_TORUS {
    return scene.torus1.color.rgb;
  }
  return vec3<f32>(0.5, 0.5, 0.5);
}

// ============ SDF primitive / SCENE ================================
fn sd_sphere(p: vec3<f32>, r: f32) -> f32 {
  return length(p) - r;
}

fn sd_box(p: vec3<f32>, b: vec3<f32>) -> f32 {
  let q = abs(p) - b;
  return length(max(q, vec3<f32>(0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);
}

fn sd_torus(p: vec3<f32>, t: vec2<f32>) -> f32 {
  let q = vec2<f32>(length(p.xz) - t.x, p.y);
  return length(q) - t.y;
}

fn sd_plane(p: vec3<f32>, n: vec3<f32>, h: f32) -> f32 {
  return dot(p, n) + h;
}

// SDF Operations
fn op_union(d1: f32, d2: f32) -> f32 {
  return min(d1, d2);
}

fn op_subtract(d1: f32, d2: f32) -> f32 {
  return max(-d1, d2);
}

fn op_intersect(d1: f32, d2: f32) -> f32 {
  return max(d1, d2);
}

fn op_smooth_union(d1: f32, d2: f32, k: f32) -> f32 {
  let h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
  return mix(d2, d1, h) - k * h * (1.0 - h);
}

// Scene description - returns (distance, material_id)
fn get_dist(p: vec3<f32>) -> vec2<f32> {

    // 1. SPHERE
    let sphere_pos    = scene.sphere1.posRadius.xyz;
    let sphere_radius = scene.sphere1.posRadius.w;
    let d_sphere      = sd_sphere(p - sphere_pos, sphere_radius);

    // 2. TORUS
    let torus_pos     = scene.torus1.posRadius.xyz;
    let torus_r_major = scene.torus1.posRadius.w;
    let torus_r_minor = scene.torus1.params.x;
    let d_torus       = sd_torus(p - torus_pos, vec2<f32>(torus_r_major, torus_r_minor));

    // 3. SMOOTH UNION (Geometry)
    // This blends the shapes together physically
    let smooth_blend = 0.4; 
    let d_object = op_smooth_union(d_sphere, d_torus, smooth_blend);

    var d = d_object;
    
    // Default to Sphere, but if we are closer to the Torus, switch to Torus material.
    // Note: Since we are smooth blending the shape, the color switch will still be 
    // a sharp line right in the middle of the blend.
    var mat = MAT_SPHERE;
    if (d_torus < d_sphere) {
        mat = MAT_TORUS;
    }
    // -------------------------------

    // 4. GROUND PLANE
    let d_plane = sd_plane(p, vec3<f32>(0.0, 1.0, 0.0), 1.0);
    
    // If the plane is closer than the object, use the plane
    if (d_plane < d) {
        d = d_plane;
        mat = MAT_PLANE;
    }

    return vec2<f32>(d, mat);
}

// Ray marching function - returns (distance, material_id)
fn ray_march(ro: vec3<f32>, rd: vec3<f32>) -> vec2<f32> {
  var d = 0.0;
  var mat_id = -1.0;

  for (var i = 0; i < MAX_STEPS; i++) {
    let p = ro + rd * d;
    let dist_mat = get_dist(p);
    d += dist_mat.x;
    mat_id = dist_mat.y;

    if dist_mat.x < SURF_DIST || d > MAX_DIST {
      break;
    }
  }

  return vec2<f32>(d, mat_id);
}

// Calculate normal using gradient
fn get_normal(p: vec3<f32>) -> vec3<f32> {
  let e = vec2<f32>(0.001, 0.0);
  let n = vec3<f32>(
    get_dist(p + e.xyy).x - get_dist(p - e.xyy).x,
    get_dist(p + e.yxy).x - get_dist(p - e.yxy).x,
    get_dist(p + e.yyx).x - get_dist(p - e.yyx).x
  );
  return normalize(n);
}
