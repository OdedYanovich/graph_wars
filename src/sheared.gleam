import gleam/dict
import gleam/set
import prng/seed

pub type Model {
  Model(
    seed: seed.Seed,
    buttons: dict.Dict(String, Bool),
    variable_graph: Graph,
    value_graph: Graph,
  )
}

pub type Graph {
  Graph(node_count: Int, edges: set.Set(Int))
}
