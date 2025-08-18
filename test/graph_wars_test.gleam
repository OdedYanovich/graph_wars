import gleam/list
import tree
import utils

type Test {
  Test(
    points: List(Int),
    max: Int,
    added_target: Int,
    removed_target: Int,
    added_result: Int,
    removed_result: Int,
  )
}

pub fn main() {
  {
    use a_test <- list.each([[1, 2, 3], [1, -2, 3]])
    a_test
    |> utils.try_index_map(fn(x, index) {
      case x == index + 1 {
        True -> Ok(2 * x)
        False -> Error(x)
      }
    })
    |> echo
  }
  // [#([1, 4], 7), #([2, 3, 4, 9, 10, 11, 13], 15)]
  // tree.find_available_positions()
}
