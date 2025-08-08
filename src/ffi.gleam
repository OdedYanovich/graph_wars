import gleam/javascript/array

@external(javascript, "./ffi/ffi.mjs", "initGraph")
pub fn init_graph(
  nodes: array.Array(Int),
  edges: array.Array(#(Int, Int)),
) -> Nil

// @external(javascript, "./../../node_modules/cytoscape/dist/cytoscape.esm.min.mjs", "temp")
// pub fn timer(callback: fn() -> Nil, delay: Int) -> Nil
@external(javascript, "./ffi/ffi.mjs", "geTime")
pub fn get_time() -> Int

@external(javascript, "./ffi/ffi.mjs", "graphID")
pub fn graph_id() -> String
