import gleam/bool
import gleam/dict
import graph
import lustre
import lustre/attribute
import lustre/effect
import lustre/element/html
import lustre_css as lc
import sheared as sh

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
          html.ol([], [html.text("(a)dd edges"), html.text("(r)emove edges")]),
          html.div(
            [
              attribute.id(graph_id()),
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
    |> lustre.application(
      graph.init,
      fn(model, msg: Msg) {
        let model = {
          use <- bool.guard(model.buttons |> dict.has_key(msg.key), model)
          sh.Model(
            ..model,
            buttons: model.buttons |> dict.insert(msg.key, True),
          )
        }
        case msg {
          KeyDown(key) -> {
            case key {
              "c" -> graph.remove(-3)
              "d" -> graph.add_edge(-3, 2, 5)
              _ -> Nil
              // "u" -> graph.update(model)
            }
          }
          _ -> Nil
        }
        #(model, effect.none())
      },
      _,
    )
    |> lustre.start("#app", Nil)
  init_keydown_event(
    fn(key) { update |> lustre.send(lustre.dispatch(KeyDown(key))) },
    fn(key) { update |> lustre.send(lustre.dispatch(KeyUp(key))) },
  )
}

type Msg {
  KeyDown(key: String)
  KeyUp(key: String)
}

@external(javascript, "./input.mjs", "initKeydownEvent")
fn init_keydown_event(
  key_down: fn(String) -> Nil,
  key_up: fn(String) -> Nil,
) -> Nil

@external(javascript, "./make_graph.mjs", "graphID")
fn graph_id() -> String
