import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set

// type Node(t) {
//   Node(val: t, left: Option(Node(t)), right: Option(Node(t)))
// }
//
// fn node(n: Option(Node(t))) {
//   case n {
//     Some(n) -> todo
//
//     None -> Nil
//   }
// }

///Record every interval between 0 and last
///The values 0 and last are implicitly in the start and the end of the list respectively
///Odd intervals are full and even are empty
fn intervals(nums, last) {
  let assert [first, ..rest] = nums |> set.to_list |> list.sort(int.compare)
  {
    use #(intervals, continuation), val <- list.fold(rest, #([first], first + 1))
    case val == continuation {
      True -> #(intervals, continuation + 1)
      False -> #(intervals |> list.append([val]), val + 1)
    }
  }.0
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
