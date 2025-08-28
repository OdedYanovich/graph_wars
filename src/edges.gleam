import gleam/json
import gleam/set
import prng/random as rng

pub fn gen_graph(node_count, edge_count, seed) {
  let #(edges_ids, seed) =
    rng.int(0, node_count * node_count - 1)
    |> rng.map(Id)
    |> rng.fixed_size_set(edge_count)
    |> rng.step(seed)
  #(Graph(node_count, edge_count, edges_ids), seed)
}

pub fn edge_id_to_blueprint(id, node_count, node_offset) {
  let Id(id) = id
  let source = id / node_count
  let target = id % node_count
  EdgeBlueprint(
    Id(-id - node_offset * node_offset - 1),
    source + node_offset
      |> Id,
    target + node_offset
      |> Id,
  )
}

pub fn new_edge(blueprint) {
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

pub fn add_edge(blueprint) {
  add_element(new_edge(blueprint))
}

pub fn add_node(blueprint) {
  add_element(new_node(blueprint))
}

pub fn new_node(id) {
  json.object([#("data", json.object([#("id", json.int(id))]))])
}

pub fn remove(id) {
  let Id(id) = id
  remove_element(id)
}

@external(javascript, "./make_graph.mjs", "removeElement")
fn remove_element(id: Int) -> Nil

@external(javascript, "./make_graph.mjs", "addElement")
fn add_element(element: json) -> Nil

// opaque 
pub type Id(t) {
  Id(Int)
}

pub type Node

pub type Edge

pub type EdgeBlueprint {
  EdgeBlueprint(id: Id(Edge), source: Id(Node), target: Id(Node))
}

pub type Graph {
  Graph(node_count: Int, edge_count: Int, edges: set.Set(Id(Edge)))
}
