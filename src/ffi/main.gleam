import gleam/javascript/array

@external(javascript, "./js/main.mjs", "initGraph")
pub fn init_graph(graph_id: String, nodes: array.Array(String),edges: array.Array(#(String,String))) -> Nil
// @external(javascript, "./../../node_modules/cytoscape/dist/cytoscape.esm.min.mjs", "temp")
// pub fn timer(callback: fn() -> Nil, delay: Int) -> Nil
