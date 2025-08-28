import edges as ed
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set

///Record every interval between 0 and last
///The values 0 and last are implicitly in the start and the end of the list respectively
///Odd intervals are full and even are empty
pub fn from_points(edge_ids, max) {
  let assert [first, second, ..rest] =
    edge_ids |> set.to_list |> list.sort(int.compare)
  let #(intervals, last_point) = {
    // let #(init, list) = case first + 1 == second {
    //   False -> #(#([first], first), [second, ..rest])
    //   True -> #(#([0, first], first - 1), [first, second, ..rest])
    // }
    let #(init, list) = case first {
      0 -> #(#([first, 0], first - 1), [first, second, ..rest])
      x if x != second - 1 -> #(#([first], first), [second, ..rest])
      _ -> #(#([0, first], first - 1), [first, second, ..rest])
    }
    use #(resulted_intervals, previous_point), current_point <- list.fold(
      list,
      init,
    )
    case current_point - previous_point {
      1 -> {
        let assert [first, ..rest] = resulted_intervals
        #([first + 1, ..rest], current_point)
      }
      distance -> #([1, distance - 1, ..resulted_intervals], current_point)
    }
  }
  echo intervals
  case max - last_point, first + 1 == second {
    0, _ -> intervals
    n, False -> [n, 1, ..intervals]
    n, True -> [n, ..intervals]
  }
  |> list.reverse
}

//Turn targets to edge_ids
//sum=current_adding+current_removing
//target=current+interval-sum
pub fn find_available_positions(intervals, adding_target, removing_target) {
  use #(current_adding, current_removing), interval, index <- list.index_fold(
    intervals,
    #(0, 0),
  )
  // let t=fn(x){
  // 	case 
  // }
  case index % 2 == 0 {
    True -> #(
      case current_adding + interval > adding_target {
        True -> todo
        False -> current_adding + interval
      },
      current_removing,
    )
    False -> #(
      current_adding,
      case current_removing + interval > removing_target {
        True -> todo
        False -> current_removing + interval
      },
    )
  }
}
// type EdgeConstructor {
//   EdgeConstructor(Int)
// }

// pub fn update(model: sh.Model) {
//   let #(new_variable_edge_constructor, seed) = {
//     rng.int(
//       0,
//       model.variable_graph.node_count
//         * { model.variable_graph.node_count - 1 }
//         - model.value_graph.edge_count,
//     )
//     |> rng.map(EdgeConstructor)
//     |> rng.step(model.seed)
//   }
//   let #(removed_variable_edge_constructor, seed) = {
//     rng.int(0, model.variable_graph.edge_count)
//     |> rng.map(EdgeConstructor)
//     |> rng.step(seed)
//   }
//   let #(added_edge_id, removed_edge_id) =
//     change_edges(
//       model.variable_graph.edges
//         |> set.to_list
//         |> list.map(fn(id) {
//           let ed.Id(id) = id
//           id
//         })
//         |> list.sort(int.compare)
//         |> list.map(ed.Id),
//       new_variable_edge_constructor,
//       removed_variable_edge_constructor,
//       model.variable_graph.edge_count,
//     )
//   ed.add_edge(ed.edge_id_to_blueprint(
//     added_edge_id,
//     model.variable_graph.node_count,
//     0,
//   ))
//   ed.remove(removed_edge_id)
//   sh.Model(
//     ..model,
//     seed:,
//     variable_graph: ed.Graph(
//       ..model.variable_graph,
//       edges: model.variable_graph.edges
//         |> set.insert(added_edge_id)
//         |> set.delete(removed_edge_id),
//     ),
//   )
// }

// fn change_edges(
//   edges: List(ed.Id(ed.Edge)),
//   adding_target,
//   removing_target,
//   max_edge_id,
// ) {
//   echo #(adding_target, removing_target, max_edge_id)
//   let assert Error(added_removed_ids) = {
//     use #(added_id, passed_edge_count, removed_id), ed.Id(edge) <- list.try_fold(
//       edges |> list.append([ed.Id(max_edge_id)]),
//       #(Error([]), 0, None),
//     )
//     echo #(added_id, passed_edge_count, removed_id)
//     let EdgeConstructor(removing_target) = removing_target
//     let check_addtion = fn(available) {
//       let EdgeConstructor(adding_target) = adding_target
//       case adding_target > edge - passed_edge_count {
//         False ->
//           available
//           |> list.try_fold(0, fn(index, hole) {
//             case index == adding_target {
//               False -> Ok(index + 1)
//               True -> Error(hole)
//             }
//           })
//           |> result.unwrap_error(0)
//           |> Ok
//         True ->
//           Error(
//             list.range(
//               edge,
//               { available |> list.first |> result.unwrap(0 - 1) } + 1,
//             )
//             |> list.append(available),
//           )
//       }
//     }
//     let check_removal = fn() {
//       case removing_target - 1 == passed_edge_count {
//         False -> option.None
//         True -> option.Some(edge)
//       }
//     }
//     let next_iteration = fn(add, remove) {
//       Ok(#(add, passed_edge_count + 1, remove))
//     }
//     case added_id, removed_id {
//       Ok(added), Some(removed) -> Error(#(ed.Id(added), ed.Id(-removed)))
//       Error(available), Some(removed) ->
//         next_iteration(check_addtion(available), Some(removed))
//       Ok(added), None -> next_iteration(Ok(added), check_removal())
//       Error(available), None ->
//         next_iteration(check_addtion(available), check_removal())
//     }
//   }
//   echo added_removed_ids
// }
