// @external(javascript, "./../../node_modules/cytoscape/dist/cytoscape.esm.min.mjs", "temp")
// pub fn timer(callback: fn() -> Nil, delay: Int) -> Nil
@external(javascript, "./ffi/ffi.mjs", "geTime")
pub fn get_time() -> Int
