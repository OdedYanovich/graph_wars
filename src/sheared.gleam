import gleam/dict
import prng/seed

pub type Model {
  Model(seed: seed.Seed, buttons: dict.Dict(String, Bool))
}
