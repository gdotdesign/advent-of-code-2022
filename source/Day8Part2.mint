/*
--- Part Two ---

Content with the amount of tree cover available, the Elves just need to know
the best spot to build their tree house: they would like to be able to see a
lot of trees.

To measure the viewing distance from a given tree, look up, down, left, and
right from that tree; stop if you reach an edge or at the first tree that is
the same height or taller than the tree under consideration. (If a tree is
right on the edge, at least one of its viewing distances will be zero.)

The Elves don't care about distant trees taller than those found by the rules
above; the proposed tree house has large leaves to keep it dry, so they w
ouldn't be able to see higher than the tree house anyway.

In the example above, consider the middle 5 in the second row:

30373
25512
65332
33549
35390

  Looking up, its view is not blocked; it can see 1 tree (of height 3).

  Looking left, its view is blocked immediately; it can see only 1 tree
  (of height 5, right next to it).

  Looking right, its view is not blocked; it can see 2 trees.

  Looking down, its view is blocked eventually; it can see 2 trees (one of
  height 3, then the tree of height 5 that blocks its view).

A tree's scenic score is found by multiplying together its viewing distance
in each of the four directions. For this tree, this is 4 (found by multiplying
1 * 1 * 2 * 2).

However, you can do even better: consider the tree of height 5 in the middle of the fourth row:

30373
25512
65332
33549
35390

  Looking up, its view is blocked at 2 trees (by another tree with a height of 5).
  Looking left, its view is not blocked; it can see 2 trees.
  Looking down, its view is also not blocked; it can see 1 tree.
  Looking right, its view is blocked at 2 trees (by a massive tree of height 9).

This tree's scenic score is 8 (2 * 2 * 1 * 2); this is the ideal spot for the
tree house.

Consider each tree on your map. What is the highest scenic score possible for
any tree?
*/
component Day8Part2 {
  const INPUT = @inline(../inputs/08)

  get data : Tuple(Array(Array(Number)), Array(Array(Number))) {
    let grid =
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

    let center =
      Math.ceil(Array.size(grid) / 2)

    let solution =
      for row, rowIndex of grid {
        for item, columnIndex of row {
          let toLeft =
            row
            |> Array.slice(0, columnIndex)
            |> Array.reverse
            |> Array.selectUntil((cell : Number) { cell >= item })
            |> Array.size

          let toRight =
            row
            |> Array.slice(columnIndex + 1, Array.size(row))
            |> Array.selectUntil((cell : Number) { cell >= item })
            |> Array.size

          let toTop =
            grid
            |> Array.slice(0, rowIndex)
            |> Array.map((items : Array(Number)) { items[columnIndex] })
            |> Array.compact
            |> Array.reverse
            |> Debug.log
            |> Array.selectUntil((cell : Number) { cell >= item })
            |> Debug.log
            |> Array.size

          let toBottom =
            grid
            |> Array.slice(rowIndex + 1, Array.size(grid))
            |> Array.map((items : Array(Number)) { items[columnIndex] })
            |> Array.compact
            |> Array.selectUntil((cell : Number) { cell >= item })
            |> Array.size

          Debug.log(
            {{rowIndex, columnIndex, item}, toTop, toLeft, toBottom, toRight})

          toTop * toLeft * toBottom * toRight
        }
      }

    {grid, solution}
  }

  fun render : Html {
    <div>
      Number.toString(
        (data[1]
        |> Array.concat
        |> Array.max) or 0)
    </div>
  }
}

module Array {
  /* Selects elements until (and including) the one that matches the function. */
  fun selectUntil (array : Array(a), method : Function(a, Bool)) : Array(a) {
    `
    (() => {
      const result = []
      for (let item of #{array}) {
        if (#{method}(item)) {
          result.push(item)
          break
        } else {
          result.push(item)
        }
      }

      return result
    })()
    `
  }
}
