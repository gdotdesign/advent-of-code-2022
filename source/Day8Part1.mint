/*
The expedition comes across a peculiar patch of tall trees all planted
carefully in a grid. The Elves explain that a previous expedition planted these
trees as a reforestation effort. Now, they're curious if this would be a good
location for a tree house.

First, determine whether there is enough tree cover here to keep a tree house
hidden. To do this, you need to count the number of trees that are visible from
outside the grid when looking directly along a row or column.

The Elves have already launched a quadcopter to generate a map with the height
of each tree (your puzzle input). For example:

30373
25512
65332
33549
35390

Each tree is represented as a single digit whose value is its height, where 0
is the shortest and 9 is the tallest.

A tree is visible if all of the other trees between it and an edge of the grid
are shorter than it. Only consider trees in the same row or column; that is,
only look up, down, left, or right from any given tree.

All of the trees around the edge of the grid are visible - since they are
already on the edge, there are no trees to block the view. In this example,
that only leaves the interior nine trees to consider:

    The top-left 5 is visible from the left and top. (It isn't visible from the
    right or bottom since other trees of height 5 are in the way.)

    The top-middle 5 is visible from the top and right.

    The top-right 1 is not visible from any direction; for it to be visible,
    there would need to only be trees of height 0 between it and an edge.

    The left-middle 5 is visible, but only from the right.

    The center 3 is not visible from any direction; for it to be visible, there
    would need to be only trees of at most height 2 between it and an edge.

    The right-middle 3 is visible from the right.

    In the bottom row, the middle 5 is visible, but the 3 and 4 are not.

With 16 trees visible on the edge and another 5 visible in the interior, a
total of 21 trees are visible in this arrangement.

Consider your map; how many trees are visible from outside the grid?
*/
component Day8Part1 {
  const INPUT = @inline(../inputs/08)

  get data : Tuple(Array(Array(Number)), Array(Array(Bool))) {
    try {
      grid =
        INPUT
        |> String.split("\n")
        |> Array.reject(String.isBlank)
        |> Array.map(
          (row : String) {
            row
            |> String.split("")
            |> Array.map(
              (item : String) {
                item
                |> Number.fromString
                |> Maybe.withDefault(-1)
              })
          })

      center =
        Math.ceil(Array.size(grid) / 2)

      solution =
        for (row, rowIndex of grid) {
          for (item, columnIndex of row) {
            try {
              visibleFromLeft =
                Maybe.withDefault(-1, Array.max(Array.slice(0, columnIndex, row))) < item

              visibleFromRight =
                Maybe.withDefault(-1, Array.max(Array.slice(columnIndex + 1, Array.size(row), row))) < item

              visibleFromTop =
                (grid
                |> Array.slice(0, rowIndex)
                |> Array.map((items : Array(Number)) { items[columnIndex] })
                |> Array.compact
                |> Array.max
                |> Maybe.withDefault(-1)) < item

              visibleFromBottom =
                (grid
                |> Array.slice(rowIndex + 1, Array.size(grid))
                |> Array.map((items : Array(Number)) { items[columnIndex] })
                |> Array.compact
                |> Array.max
                |> Maybe.withDefault(-1)) < item

              visibleFromLeft || visibleFromRight || visibleFromTop || visibleFromBottom
            }
          }
        }

      ({grid, solution})
    }
  }

  fun render : Html {
    try {
      x =
        data

      <div>
        <{
          Number.toString(
            x[1]
            |> Array.concat
            |> Array.select((item : Bool) { item })
            |> Array.size)
        }>

        <details open="true">
          <summary>"Table"</summary>

          <table>
            for (row, rowIndex of x[0]) {
              <tr>
                for (item, columnIndex of row) {
                  try {
                    styles =
                      if (((x[1][rowIndex] or [])[columnIndex]) or false) {
                        "color: green"
                      } else {
                        "color: red"
                      }

                    <td style={styles}>
                      <{ "#{item}" }>
                    </td>
                  }
                }
              </tr>
            }
          </table>
        </details>
      </div>
    }
  }
}
