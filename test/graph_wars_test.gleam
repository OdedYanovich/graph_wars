import gleam/int
import gleam/list
import gleam/set
import interval

type ConstructorTest {
  ConstructorTest(
    points: List(Int),
    renge_max: Int,
    expected_intervals: List(Int),
  )
}

type MutationTest {
  MutationTest(
    given_integrals: List(Int),
    expected_integrals: List(Int),
    added_target: Int,
    removed_target: Int,
  )
}

const interval_constructor_tests = [
  ConstructorTest([3, 5, 7], 9, [3, 1, 1, 1, 1, 1, 2]),
  ConstructorTest([4, 5, 6, 7], 9, [4, 4, 2]),
  ConstructorTest([0, 5, 9], 9, [0, 1, 4, 1, 3, 1]),
  ConstructorTest([0, 4, 5, 6, 9], 12, [0, 1, 3, 3, 2, 1, 3]),
  ConstructorTest([2, 4, 5, 9, 10, 11], 12, [2, 1, 1, 2, 3, 3, 1]),
]

pub fn main() {
  use ConstructorTest(points, max_range, expected_intervals) <- list.each(
    interval_constructor_tests,
  )
  let msg = fn(points) {
    points
    |> list.fold("[ ", fn(points, x) { points <> x |> int.to_string <> ", " })
    <> "]\n"
  }
  let result = interval.from_points(points |> set.from_list, max_range)
  assert result == expected_intervals
    as {
      "given points: "
      <> msg(points)
      <> "from 0 to "
      <> max_range |> int.to_string
      <> "\nexpected interval: "
      <> msg(expected_intervals)
      <> "received intervals: "
      <> msg(result)
    }
}
