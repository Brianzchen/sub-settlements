const gravity = 9.8;

pub fn defineSpeed(durationMs: f32) f32 {
    return gravity * durationMs;
}
