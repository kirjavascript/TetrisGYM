pub fn test() {
    let clean = crate::util::OG_ROM;
    let patch = include_bytes!("../../tetris.bps");

    // check original file hasn't changed
    assert_eq!("ec58574d96bee8c8927884ae6e7a2508", format!("{:x}", md5::compute(clean)));

    // check patch produces the final ROM
    let output = flips::BpsPatch::new(patch).apply(clean)
        .expect("could not apply patch");

    assert_eq!(output.as_bytes(), crate::util::ROM);

    // check NES2.0 files work
    let mut clean2 = Vec::new();
    clean2.extend([0x4e,0x45,0x53,0x1a,0x02,0x02,0x10,0x08,0x50,0x00,0x00,0x07,0x00,0x00,0x00,0x00]);
    clean2.extend(&clean[0x10..]);

    assert_eq!("204c0f64d291737e23c0345b59cf1c05", format!("{:x}", md5::compute(clean2.clone())));

    let result = {
        let slice_p = patch.as_ref();
        let slice_s: &[u8] = clean2.as_ref();
        let mut mem_m = flips_sys::mem::default();
        let mut mem_o = flips_sys::mem::default();

        let _result = unsafe {
            let mem_i = flips_sys::mem::new(slice_s.as_ptr() as *mut _, slice_s.len());
            let mem_p = flips_sys::mem::new(slice_p.as_ptr() as *mut _, slice_p.len());
            flips_sys::bps::bps_apply(mem_p, mem_i, &mut mem_o as *mut _, &mut mem_m as *mut _, true)
        };

        mem_o.to_owned()
    };

    let mut invalid_indices = Vec::new();

    for (i, v) in result.as_ref().iter().enumerate() {
        if v != &crate::util::ROM[i] {
            invalid_indices.push(i);
        }
    }

    assert_eq!(invalid_indices, Vec::new());
}
