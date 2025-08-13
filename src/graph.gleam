import gleam/dict
import gleam/javascript/array
import gleam/json
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
  let edges_gen = fn(first, last, count, seed) {
    rng.int(first, last * { last - 1 })
    |> rng.fixed_size_set(count)
    |> rng.step(seed)
  }
  let #(variable_graph_edges, seed) =
    edges_gen(
      0,
      variable_graph_nodes - 1,
      variable_graph_edges,
      seed.new(utils.get_time()),
    )
  let #(value_graph_edges, seed) =
    edges_gen(0, value_graph_nodes - 1, value_graph_edges, seed)
  #(
    sh.Model(
      seed,
      dict.new(),
      variable_graph: sh.Graph2(variable_graph_nodes, variable_graph_edges),
      value_graph: sh.Graph2(value_graph_nodes, value_graph_edges),
    ),
    effect.after_paint(fn(_, _) {
      let encode_edge = fn(id, node_count, offset) {
        let source = id / node_count
        let target = id % node_count
        #(
          source
            + offset
            + case source < target {
            True -> 0
            False -> 1
          },
          target + offset,
        )
      }
      init_graph(
        list.range(0, variable_graph_nodes + value_graph_nodes - 1)
        |> list.map(fn(id) {
          json.object([#("data", json.object([#("id", json.int(id))]))])
        })
        |> list.append(
          list.map_fold(
            set.union(
              variable_graph_edges
                |> set.map(encode_edge(_, variable_graph_nodes, 0)),
              value_graph_edges
                |> set.map(encode_edge(
                  _,
                  value_graph_nodes,
                  variable_graph_nodes,
                )),
            )
              |> set.to_list,
            -1,
            fn(id, source_target) {
              #(
                id - 1,
                json.object([
                  #(
                    "data",
                    json.object([
                      #("id", json.int(id)),
                      #("source", json.int(source_target.0)),
                      #("target", json.int(source_target.1)),
                    ]),
                  ),
                ]),
              )
            },
          ).1,
        )
        |> array.from_list,
      )
    }),
  )
}

@external(javascript, "./make_graph.mjs", "initGraph")
fn init_graph(elements: array.Array(json.Json)) -> Nil

@external(javascript, "./make_graph.mjs", "remove")
pub fn remove() -> Nil
