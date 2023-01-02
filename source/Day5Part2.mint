/*
--- Part Two ---

As you watch the crane operator expertly rearrange the crates, you notice the
process isn't following your prediction.

Some mud was covering the writing on the side of the crane, and you quickly
wipe it away. The crane isn't a CrateMover 9000 - it's a CrateMover 9001.

The CrateMover 9001 is notable for many new and exciting features: air
conditioning, leather seats, an extra cup holder, and the ability to pick up
and move multiple crates at once.

Again considering the example above, the crates begin in the same configuration:

    [D]
[N] [C]
[Z] [M] [P]
 1   2   3

Moving a single crate from stack 2 to stack 1 behaves the same as before:

[D]
[N] [C]
[Z] [M] [P]
 1   2   3

However, the action of moving three crates from stack 1 to stack 3 means that
those three moved crates stay in the same order, resulting in this new
configuration:

        [D]
        [N]
    [C] [Z]
    [M] [P]
 1   2   3

Next, as both crates are moved from stack 2 to stack 1, they retain their order
as well:

        [D]
        [N]
[C]     [Z]
[M]     [P]
 1   2   3

Finally, a single crate is still moved from stack 1 to stack 2, but now it's
crate C that gets moved:

        [D]
        [N]
        [Z]
[M] [C] [P]
 1   2   3

In this example, the CrateMover 9001 has put the crates in a totally different
order: MCD.

Before the rearrangement process finishes, update your simulation so that the
Elves know where they should stand to be ready to unload the final supplies.
After the rearrangement procedure completes, what crate ends up on top of each
stack?
*/
component Day5Part2 {
  const INPUT = @inline(../inputs/05)

  const STACKS =
    [
      ["V", "C", "D", "R", "Z", "G", "B", "W"],
      ["G", "W", "F", "C", "B", "S", "T", "V"],
      ["C", "B", "S", "N", "W"],
      ["Q", "G", "M", "N", "J", "V", "C", "P"],
      ["T", "S", "L", "F", "D", "H", "B"],
      ["J", "V", "T", "W", "M", "N"],
      ["P", "F", "L", "C", "S", "T", "G"],
      ["B", "D", "Z"],
      ["M", "N", "Z", "W"]
    ]

  get result : String {
    INPUT
    |> String.split("\n")
    |> Array.reduce(
      STACKS,
      (memo : Array(Array(String)), item : String) {
        case (Regexp.matches(item, /\d+/g)) {
          => memo

          [a, b, c] =>
            try {
              quantity =
                Number.fromString(a.match) or -1

              from =
                Number.fromString(b.match) or -1

              to =
                Number.fromString(c.match) or -1

              fromStack =
                memo[from - 1] or []

              crates =
                Array.takeEnd(quantity, fromStack)

              newFromStack =
                Array.slice(0, Array.size(fromStack) - quantity, fromStack)

              toStack =
                memo[to - 1] or []

              newToStack =
                Array.concat([toStack, crates])

              memo
              |> Array.setAt(from - 1, newFromStack)
              |> Array.setAt(to - 1, newToStack)
            }
        }
      })
    |> Array.map(
      (stack : Array(String)) {
        Array.last(stack) or ""
      })
    |> String.join("")
  }

  fun render : String {
    result
  }
}
