import edges as ed
import gleam/javascript/array
import gleam/json
import gleam/list

import gleam/set
import lustre/effect

// import prng/random as rng
import prng/seed
import sheared as sh
import utils

pub fn init(_flag) {
  let #(variable_graph, seed) = ed.gen_graph(5, 3, seed.new(utils.get_time()))
  let #(value_graph, seed) = ed.gen_graph(3, 1, seed)
  #(
    sh.Model(seed, variable_graph:, value_graph:),
    fn(_, _) {
      init_graph(
        [
          get_node_ids(variable_graph.node_count, value_graph.node_count)
            |> list.map(ed.new_node),
          set.union(
            variable_graph.edges
              |> set.map(ed.edge_id_to_blueprint(
                _,
                variable_graph.node_count,
                0,
              )),
            value_graph.edges
              |> set.map(ed.edge_id_to_blueprint(
                _,
                value_graph.node_count,
                variable_graph.node_count,
              )),
          )
            |> set.to_list
            |> list.map(ed.new_edge),
        ]
        |> list.flatten
        |> array.from_list,
      )
    }
      |> effect.after_paint,
  )
}

pub fn update(
  model: sh.Model,
  variable_node_count,
  variable_edge_count,
  value_node_count,
  value_edge_count,
) {
  clear_graph()
  let #(variable_graph, seed) =
    ed.gen_graph(variable_node_count, variable_edge_count, model.seed)
  let #(value_graph, seed) =
    ed.gen_graph(value_node_count, value_edge_count, seed)
  get_node_ids(variable_graph.node_count, value_graph.node_count)
  |> list.each(ed.add_node)
  set.union(
    variable_graph.edges
      |> set.map(ed.edge_id_to_blueprint(_, variable_graph.node_count, 0)),
    value_graph.edges
      |> set.map(ed.edge_id_to_blueprint(
        _,
        value_graph.node_count,
        variable_graph.node_count,
      )),
  )
  |> set.map(ed.add_edge)
  organize_graph()
  sh.Model(..model, seed:)
}

@external(javascript, "./make_graph.mjs", "initGraph")
fn init_graph(elements: array.Array(json.Json)) -> Nil

@external(javascript, "./make_graph.mjs", "clearGraph")
fn clear_graph() -> Nil

@external(javascript, "./make_graph.mjs", "organize")
fn organize_graph() -> Nil

fn get_node_ids(variable_node_count, value_node_count) {
  list.range(0, variable_node_count + value_node_count - 1)
}
