import gleam/dict
import gleam/javascript/array
import gleam/list
import gleam/set
import lustre/effect
import prng/random as rng
import prng/seed
import sheared as sh
import utils

pub fn init(_flag) {
  let variable_graph_nodes = 5
  let variable_graph_edges = 3
  let value_graph_nodes = 3
  let value_graph_edges = 1
  let seed = seed.new(utils.get_time())
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
  let model =
    sh.Model(
      seed,
      dict.new(),
      variable_graph: sh.Graph(variable_graph_nodes, variable_edges),
      value_graph: sh.Graph(value_graph_nodes, value_edges),
    )
  #(model, effect.after_paint(fn(_, _root_element) { animate_graph(model) }))
}

fn animate_graph(model: sh.Model) {
  init_graph(
    list.range(
      1,
      model.variable_graph.node_count + model.value_graph.node_count,
    )
      |> array.from_list,
    model.variable_graph.edges
      |> set.union(model.value_graph.edges)
      |> set.to_list
      |> array.from_list,
  )
}

@external(javascript, "./make_graph.mjs", "initGraph")
fn init_graph(nodes: array.Array(Int), edges: array.Array(#(Int, Int))) -> Nil

@external(javascript, "./make_graph.mjs", "remove")
pub fn remove() -> Nil
