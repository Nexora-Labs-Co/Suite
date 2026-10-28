use std::ffi::{CStr, CString};
use std::os::raw::c_char;

/// Compares two version strings ("1.2.3").
/// Returns -1 if a < b, 0 if equal, 1 if a > b.
#[no_mangle]
pub extern "C" fn nexora_compare_versions(a: *const c_char, b: *const c_char) -> i32 {
    if a.is_null() || b.is_null() {
        return 0;
    }
    let a = unsafe { CStr::from_ptr(a).to_string_lossy() };
    let b = unsafe { CStr::from_ptr(b).to_string_lossy() };

    let pa: Vec<u32> = a.split('.').filter_map(|x| x.trim().parse().ok()).collect();
    let pb: Vec<u32> = b.split('.').filter_map(|x| x.trim().parse().ok()).collect();

    let n = pa.len().max(pb.len());
    for i in 0..n {
        let va = pa.get(i).copied().unwrap_or(0);
        let vb = pb.get(i).copied().unwrap_or(0);
        if va < vb {
            return -1;
        }
        if va > vb {
            return 1;
        }
    }
    0
}

/// Returns 1 if the given executable name is found on PATH.
#[no_mangle]
pub extern "C" fn nexora_is_on_path(name: *const c_char) -> i32 {
    if name.is_null() {
        return 0;
    }
    let name = unsafe { CStr::from_ptr(name).to_string_lossy() };
    let path_var = std::env::var("PATH").unwrap_or_default();
    for dir in path_var.split(if cfg!(windows) { ';' } else { ':' }) {
        let candidate = std::path::Path::new(dir).join(name.as_ref());
        if candidate.is_file() {
            return 1;
        }
    }
    0
}

/// Frees a string allocated by Rust (placeholder for future APIs).
#[no_mangle]
pub extern "C" fn nexora_free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe {
            let _ = CString::from_raw(ptr);
        }
    }
}
