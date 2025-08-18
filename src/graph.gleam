import gleam/bool
import gleam/dict
import gleam/javascript/array
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
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
      variable_graph: sh.Graph(variable_graph_nodes, variable_graph_edges),
      value_graph: sh.Graph(value_graph_nodes, value_graph_edges),
    ),
    effect.after_paint(fn(_, _) {
      init_graph(
        list.range(0, variable_graph_nodes + value_graph_nodes - 1)
        |> list.map(fn(id) { new_node(id) })
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
              #(id - 1, new_edge(id, source_target.0, source_target.1))
            },
          ).1,
        )
        |> array.from_list,
      )
    }),
  )
}

fn encode_edge(id, node_count, offset) {
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

pub fn update(model) {
  let edges_gen = fn(first, last, count, seed) {
    rng.int(first, last * { last - 1 })
    |> rng.step(seed)
  }
  // let #(adding_target,seed)=
  //    rng.int(first, last * { last - 1 })
  //    |> rng.step(seed)
  sh.Model(..model)
}

fn change_edges(edges, adding_target, removing_target, max) {
  let assert Error(added_removed_ids) = {
    use #(added_id, passed_edge_count, removed_id), edge <- list.try_fold(
      edges |> list.append([max]),
      #(Error([]), 0, None),
    )
    let check_addtion = fn(available) {
      case adding_target > edge - passed_edge_count {
        False ->
          available
          |> list.try_fold(0, fn(index, hole) {
            case index == adding_target {
              False -> Ok(index + 1)
              True -> Error(hole)
            }
          })
          |> result.unwrap_error(0)
          |> Ok
        True ->
          Error(
            list.range(
              edge,
              { available |> list.first |> result.unwrap(0 - 1) } + 1,
            )
            |> list.append(available),
          )
      }
    }
    let check_removal = fn() {
      case removing_target - 1 == passed_edge_count {
        False -> option.None
        True -> option.Some(edge)
      }
    }
    let next = fn(add, remove) { Ok(#(add, passed_edge_count + 1, remove)) }
    case added_id, removed_id {
      Ok(added), Some(removed) -> Error(#(added, removed))
      Error(available), Some(removed) ->
        next(check_addtion(available), Some(removed))
      Ok(added), None -> next(Ok(added), check_removal())
      Error(available), None -> next(check_addtion(available), check_removal())
    }
  }
  added_removed_ids
}

// potential_edges=range(0,edges)
// current_edges:List(Int)
// selected_added=rand(potential_edges)
// selected_removed=rand(potential_edges)

// given:
// 1) edges list 2) max edge
// 3) addition target 4) removal target
// return:
// 5) added id 6) removed id
// constraints:
// 7) 1-2] edges are between 0 and max (exclusive)
// 8) 1-4] list's length >= addition target - 1
// 9) 1-2-5] max edges - list's length >= removal target - 1
// 10) all values are natural (including 0)
// 11) 1-3-5] every potential value off target addition is mapped to a single value of 
// 12) 2-4-6]

// 1 [2]
// 2 [2]
// 3 [2]
// 4 [2,5,6]
// 5 [2,5,6]
// 5 [2,5,7]
// 5 [2,4,5,7]
// 5 [2,4,5,9]
@external(javascript, "./make_graph.mjs", "initGraph")
fn init_graph(elements: array.Array(json.Json)) -> Nil

pub fn remove(id: Int) -> Nil {
  remove_element(id)
}

pub fn add_edge(id: Int, source: Int, target: Int) -> Nil {
  add_element(new_edge(id, source, target))
}

fn new_edge(id, source, target) {
  json.object([
    #(
      "data",
      json.object([
        #("id", json.int(id)),
        #("source", json.int(source)),
        #("target", json.int(target)),
      ]),
    ),
  ])
}

fn new_node(id) {
  json.object([#("data", json.object([#("id", json.int(id))]))])
}

// /// Node's id >= 0
// type Node =
//   Int
//
// /// Edge's id < 0
// type Edge =
//   Int
//
// fn new_node(id) -> Node {
//   assert id >= 0
//   id
// }

@external(javascript, "./make_graph.mjs", "removeElement")
fn remove_element(id: Int) -> Nil

@external(javascript, "./make_graph.mjs", "addElement")
fn add_element(element: json) -> Nil
