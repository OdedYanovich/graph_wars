import gleam/dict

pub fn level(lv) {
  [#(0, #(5, 3, 3, 1))] |> dict.from_list |> dict.get(lv)
}
