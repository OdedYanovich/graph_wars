import gleam/javascript/array
import gleam/list
import gleam/set
import prng/random as rng

pub fn create(
  variable_graph_nodes,
  variable_graph_edges,
  value_graph_nodes,
  value_graph_edges,
  seed,
) {
  let edges_gen = fn(first, last, count) {
    let edge_gen = {
      rng.fixed_size_set(rng.int(first, last), 2)
      |> rng.map(fn(set) {
        let assert [first, last] = set |> set.to_list |> list.shuffle
        #(first, last)
      })
    }
    rng.fixed_size_set(edge_gen, count)
  }
  let #(variable_edges, seed) =
    edges_gen(1, variable_graph_nodes, variable_graph_edges) |> rng.step(seed)
  let #(value_edges, seed) =
    edges_gen(
      variable_graph_nodes + 1,
      variable_graph_nodes + value_graph_nodes,
      value_graph_edges,
    )
    |> rng.step(seed)
  init_graph(
    list.range(1, variable_graph_nodes + value_graph_nodes) |> array.from_list,
    variable_edges
      |> set.union(value_edges)
      |> set.to_list
      |> array.from_list,
  )
  seed
}

@external(javascript, "./make_graph.mjs", "initGraph")
fn init_graph(nodes: array.Array(Int), edges: array.Array(#(Int, Int))) -> Nil

@external(javascript, "./make_graph.mjs", "remove")
pub fn remove() -> Nil
