import edges as ed
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
          list.range(0, variable_graph.node_count + value_graph.node_count - 1)
            |> list.map(ed.new_node),
          list.map(
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
              |> set.to_list,
            ed.new_edge,
          ),
        ]
        |> list.flatten
        |> array.from_list,
      )
    }
      |> effect.after_paint,
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
          let ed.Id(id) = id
          id
        })
        |> list.sort(int.compare)
        |> list.map(ed.Id),
      new_variable_edge_constructor,
      removed_variable_edge_constructor,
      model.variable_graph.edge_count,
    )
  ed.add_edge(ed.edge_id_to_blueprint(
    added_edge_id,
    model.variable_graph.node_count,
    0,
  ))
  ed.remove(removed_edge_id)
  sh.Model(
    ..model,
    seed:,
    variable_graph: ed.Graph(
      ..model.variable_graph,
      edges: model.variable_graph.edges
        |> set.insert(added_edge_id)
        |> set.delete(removed_edge_id),
    ),
  )
}

@external(javascript, "./make_graph.mjs", "initGraph")
fn init_graph(elements: array.Array(json.Json)) -> Nil

fn change_edges(
  edges: List(ed.Id(ed.Edge)),
  adding_target,
  removing_target,
  max_edge_id,
) {
  echo #(adding_target, removing_target, max_edge_id)
  let assert Error(added_removed_ids) = {
    use #(added_id, passed_edge_count, removed_id), ed.Id(edge) <- list.try_fold(
      edges |> list.append([ed.Id(max_edge_id)]),
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
      Ok(added), Some(removed) -> Error(#(ed.Id(added), ed.Id(-removed)))
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
