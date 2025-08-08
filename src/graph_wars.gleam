import ffi
import gleam/bool
import gleam/dict
import gleam/dynamic/decode
import graph
import lustre
import lustre/attribute
import lustre/element/html
import lustre_css as lc
import prng/seed

pub fn main() {
  let assert Ok(update) =
    fn(_model) {
      html.div(
        [
          attribute.styles([
            lc.height(lc.VH(100)),
            lc.display(lc.Grid),
            lc.place_items(lc.Center),
            lc.grid_template_columns(lc.Unique([lc.Fr(1), lc.Fr(4)])),
          ]),
        ],
        [
          html.div(
            [
              attribute.styles([]),
            ],
            [html.text("(c)hange edges")],
          ),
          html.div(
            [
              attribute.id(ffi.graph_id()),
              attribute.styles([
                lc.width(lc.Precent(100)),
                lc.height(lc.Precent(100)),
              ]),
            ],
            [],
          ),
        ],
      )
    }
    |> lustre.simple(
      fn(_) { Model(seed.new(ffi.get_time()), dict.new()) },
      fn(model, msg) {
        use <- bool.guard(model.buttons |> dict.has_key(msg), model)
        Model(..model, buttons: model.buttons |> dict.insert(msg, True))
      },
    )
    |> lustre.start("#app", Nil)
  graph.create(5, 3, 3, 1, seed.new(ffi.get_time()))
  init_keydown_event(
    fn(key) { update |> lustre.send(lustre.dispatch(KeyDown(key))) },
    fn(key) { update |> lustre.send(lustre.dispatch(KeyUp(key))) },
  )
}

type Model {
  Model(seed: seed.Seed, buttons: dict.Dict(String, Bool))
}

type Msg {
  KeyDown(String)
  KeyUp(String)
}

@external(javascript, "./ffi/ffi.mjs", "initKeydownEvent")
fn init_keydown_event(
  key_down: fn(String) -> Nil,
  key_up: fn(String) -> Nil,
) -> Nil
