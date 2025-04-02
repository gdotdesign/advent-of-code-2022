/*
--- Part Two ---

It seems like there is still quite a bit of duplicate work planned. Instead,
the Elves would like to know the number of pairs that overlap at all.

In the above example, the first two pairs (2-4,6-8 and 2-3,4-5) don't overlap,
while the remaining four pairs (5-7,7-9, 2-8,3-7, 6-6,4-6, and 2-6,4-8) do
overlap:

  5-7,7-9 overlaps in a single section, 7.
  2-8,3-7 overlaps all of the sections 3 through 7.
  6-6,4-6 overlaps in a single section, 6.
  2-6,4-8 overlaps in sections 4, 5, and 6.

So, in this example, the number of overlapping assignment pairs is 4.

In how many assignment pairs do the ranges overlap?
*/
component Day4Part2 {
  const INPUT = @inline(../inputs/04)

  get result : Number {
    INPUT
    |> String.split("\n")
    |> Array.map(
      (item : String) {
        case String.split(",", item) {
          [elf1, elf2] =>
            {
              let range1 =
                range(elf1)

              let range2 =
                range(elf2)

              let intersection =
                if Array.size(range1) < Array.size(range2) {
                  for item of range1 {
                    item
                  } when {
                    Array.contains(range2, item)
                  }
                } else {
                  for item of range2 {
                    item
                  } when {
                    Array.contains(range1, item)
                  }
                }

              if Array.isEmpty(intersection) {
                Maybe.Nothing
              } else {
                Maybe.Just("")
              }
            }

          => Maybe.Nothing
        }
      })
    |> Array.compact
    |> Array.size
  }

  fun range (raw : String) : Array(Number) {
    case String.split("-", raw) {
      [start, end] =>
        Array.range(Number.fromString(start) or 0, Number.fromString(end) or 0)

      => []
    }
  }

  fun render : String {
    Number.toString(result)
  }
}
