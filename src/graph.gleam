import ffi
import gleam/javascript/array
import gleam/list
import prng/random

pub fn create(graph_id, nodes, edges) {
  ffi.init_graph(graph_id, array.from_list(nodes), array.from_list(edges))
}

pub fn create2(
  graph_id,
  variable_graph_nodes,
  variable_graph_edges,
  value_graph_nodes,
  value_graph_edges,
) {
  let variable_graph_generator = random.int(0, value_graph_nodes)
  let value_graph_generator =
    random.int(value_graph_nodes, value_graph_nodes + 1 + value_graph_nodes)
  ffi.init_graph(
    graph_id,
    array.from_list(list.range(0, variable_graph_nodes + value_graph_nodes)),
    array.from_list(edges),
  )
}

pub type Graph {
  Graph(nodes: random.Generator(Int), edges: random.Generator(Int))
}
// pub type Graph {
//   Graph(nodes: Int, edges: Int)
// }
