import edges as ed
import prng/seed

pub type Model {
  Model(
    seed: seed.Seed,
    // buttons: dict.Dict(String, Bool),
    variable_graph: ed.Graph,
    value_graph: ed.Graph,
  )
}
// let model = {
//   use <- bool.guard(model.buttons |> dict.has_key(msg.key), model)
//   sh.Model(
//     ..model,
//     buttons: model.buttons |> dict.insert(msg.key, True),
//   )
// }
