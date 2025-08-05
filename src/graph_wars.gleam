import ffi/main
import lustre
import lustre/attribute
import lustre/element/html

import gleam/javascript/array
import lustre_css as lc

pub fn main() {
  let graph_id = "g"
  let assert Ok(_) =
    html.div(
      [
        attribute.styles([
          lc.display(lc.Grid),
          lc.height(lc.VH(100)),
          lc.place_items(lc.Center),
          // lc.grid_template_columns(lc.Repeat(2, lc.Fr(1))),
        ]),
      ],
      [
        html.div(
          [
            attribute.id(graph_id),
            attribute.styles([
              lc.width(lc.Precent(100)),
              lc.height(lc.Precent(100)),
              // lc.grid_column_start(1),
            ]),
          ],
          [],
        ),
      ],
    )
    |> lustre.element
    |> lustre.start("#app", Nil)
  main.init_graph(
    graph_id,
    ["a", "b", "c", "d", "e"] |> array.from_list,
    [#("a", "c"), #("a", "b"), #("d", "e")]
      |> array.from_list,
  )
}
