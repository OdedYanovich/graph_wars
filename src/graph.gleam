import gleam/dict
import gleam/int
import gleam/javascript/array
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set
import lustre/effect
import prng/random as rng
import prng/seed
import sheared.{type Edge, type Id, type Node, Id} as sh
import utils

pub fn init(_flag) {
  let variable_graph_node_count = 5
  let variable_graph_edge_count = 3
  let value_graph_node_count = 3
  let value_graph_edge_count = 1
  let edges_gen = fn(first, last, count, seed) {
    rng.int(first, last * { last - 1 })
    |> rng.map(Id)
    |> rng.fixed_size_set(count)
    |> rng.step(seed)
  }
  let #(variable_graph_edges_ids, seed) =
    edges_gen(
      0,
      variable_graph_node_count - 1,
      variable_graph_edge_count,
      seed.new(utils.get_time()),
    )
  let #(value_graph_edges_ids, seed) =
    edges_gen(0, value_graph_node_count - 1, value_graph_edge_count, seed)
  #(
    sh.Model(
      seed,
      dict.new(),
      variable_graph: sh.Graph(
        variable_graph_node_count,
        variable_graph_edge_count,
        variable_graph_edges_ids,
      ),
      value_graph: sh.Graph(
        value_graph_node_count,
        value_graph_edge_count,
        value_graph_edges_ids,
      ),
    ),
    effect.after_paint(fn(_, _) {
      init_graph(
        list.range(0, variable_graph_node_count + value_graph_node_count - 1)
        |> list.map(new_node)
        |> list.append(
          list.map_fold(
            set.union(
              variable_graph_edges_ids
                |> set.map(edge_id_to_blueprint(_, variable_graph_node_count, 0)),
              value_graph_edges_ids
                |> set.map(edge_id_to_blueprint(
                  _,
                  value_graph_node_count,
                  variable_graph_node_count,
                )),
            )
              |> set.to_list,
            -1,
            fn(id, edge_blueprint) { #(id - 1, new_edge(edge_blueprint)) },
          ).1,
        )
        |> array.from_list,
      )
    }),
  )
}

type EdgeBlueprint {
  EdgeBlueprint(id: Id(Edge), source: Id(Node), target: Id(Node))
  // EdgeBlueprint(id: Int, source: Int, target: Int)
}

fn edge_id_to_blueprint(id, node_count, offset) {
  let Id(id_temp) = id
  let source = id_temp / node_count
  let target = id_temp % node_count
  EdgeBlueprint(
    id,
    source
    + offset
    + case source < target {
      True -> 0
      False -> 1
    }
      |> Id,
    target + offset |> Id,
  )
}

type EdgeConstructor {
  EdgeConstructor(Int)
}

pub fn update(model: sh.Model) {
  let #(new_variable_edge_constructor, seed) = {
    rng.int(
      0,
      model.variable_graph.node_count
        * { model.variable_graph.node_count - 1 }
        - model.value_graph.edge_count,
    )
    |> rng.map(EdgeConstructor)
    |> rng.step(model.seed)
  }
  let #(removed_variable_edge_constructor, seed) = {
    rng.int(0, model.variable_graph.edge_count)
    |> rng.map(EdgeConstructor)
    |> rng.step(seed)
  }
  let #(added_edge_id, removed_edge_id) =
    change_edges(
      model.variable_graph.edges
        |> set.to_list
        |> list.map(fn(id) {
          let Id(id) = id
          id
        })
        |> list.sort(int.compare)
        |> list.map(Id),
      new_variable_edge_constructor,
      removed_variable_edge_constructor,
      model.variable_graph.edge_count,
    )
  // let added_edge =
  add_edge(edge_id_to_blueprint(
    added_edge_id,
    model.variable_graph.node_count,
    0,
  ))
  remove(removed_edge_id)
  sh.Model(
    ..model,
    seed:,
    variable_graph: sh.Graph(
      ..model.variable_graph,
      edges: model.variable_graph.edges
        |> set.insert(added_edge_id)
        |> set.delete(removed_edge_id),
    ),
  )
}

fn change_edges(
  edges: List(Id(Edge)),
  adding_target,
  removing_target,
  max_edge_id,
) {
  echo #(adding_target, removing_target, max_edge_id)
  let assert Error(added_removed_ids) = {
    use #(added_id, passed_edge_count, removed_id), Id(edge) <- list.try_fold(
      edges |> list.append([Id(max_edge_id)]),
      #(Error([]), 0, None),
    )
    echo #(added_id, passed_edge_count, removed_id)
    let EdgeConstructor(removing_target) = removing_target
    let check_addtion = fn(available) {
      let EdgeConstructor(adding_target) = adding_target
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
    let next_iteration = fn(add, remove) {
      Ok(#(add, passed_edge_count + 1, remove))
    }
    case added_id, removed_id {
      Ok(added), Some(removed) -> Error(#(Id(added), Id(-removed)))
      Error(available), Some(removed) ->
        next_iteration(check_addtion(available), Some(removed))
      Ok(added), None -> next_iteration(Ok(added), check_removal())
      Error(available), None ->
        next_iteration(check_addtion(available), check_removal())
    }
  }
  echo added_removed_ids
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

fn remove(id: Id(any)) -> Nil {
  let Id(id) = id
  remove_element(id)
}

fn add_edge(blueprint) {
  add_element(new_edge(blueprint))
}

fn new_edge(blueprint) {
  let EdgeBlueprint(Id(id), Id(source), Id(target)) = blueprint

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

@external(javascript, "./make_graph.mjs", "removeElement")
fn remove_element(id: Int) -> Nil

@external(javascript, "./make_graph.mjs", "addElement")
fn add_element(element: json) -> Nil
