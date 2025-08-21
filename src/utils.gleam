import gleam/list.{reverse}

// @external(javascript, "./../../node_modules/cytoscape/dist/cytoscape.esm.min.mjs", "temp")
// pub fn timer(callback: fn() -> Nil, delay: Int) -> Nil
@external(javascript, "./ffi/ffi.mjs", "geTime")
pub fn get_time() -> Int

/// gleam/list.{index_map} with the ability to end early
/// #Example
/// ```gleam
/// use x, index <- utils.try_index_map([1, 2, 3])
///   case x == index + 1 {
///     True -> Ok(2 * x)
///     False -> Error(x)
///   }
///```
pub fn try_index_map(
  list: List(a),
  with fun: fn(a, Int) -> Result(b, e),
) -> Result(List(b), e) {
  {
    use index_map, #(list, fun, index, acc) <- recursive
    case list {
      [first, ..rest] ->
        case fun(first, index) {
          Ok(result) -> index_map(#(rest, fun, index + 1, [result, ..acc]))
          Error(err) -> Error(err)
        }
      [] -> acc |> reverse |> Ok
    }
  }(#(list, fun, 0, []))
}

// pub fn index_map(list: List(a), with fun: fn(a, Int) -> b) -> List(b) {
//   {
//     use index_map, #(list, fun, index, acc) <- recursive
//     case list {
//       [] -> acc |> reverse
//       [first, ..rest] ->
//         index_map(#(rest, fun, index + 1, [fun(first, index), ..acc]))
//     }
//   }(#(list, fun, 0, []))
// }
pub fn recursive(f) {
  fn(x) { f(recursive(f), x) }
}
