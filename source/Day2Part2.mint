/*
--- Part Two ---

The Elf finishes helping with the tent and sneaks back over to you. "Anyway,
the second column says how the round needs to end: X means you need to lose,
Y means you need to end the round in a draw, and Z means you need to win.
Good luck!"

The total score is still calculated in the same way, but now you need to figure
out what shape to choose so the round ends as indicated. The example above now
goes like this:

  In the first round, your opponent will choose Rock (A), and you need the
  round to end in a draw (Y), so you also choose Rock. This gives you a score
  of 1 + 3 = 4.

  In the second round, your opponent will choose Paper (B), and you choose Rock
  so you lose (X) with a score of 1 + 0 = 1.

  In the third round, you will defeat your opponent's Scissors with Rock for a
  score of 1 + 6 = 7.

Now that you're correctly decrypting the ultra top secret strategy guide, you
would get a total score of 12.

Following the Elf's instructions for the second column, what would your total
score be if everything goes exactly according to your strategy guide?
*/
component Day2Part2 {
  const INPUT = @inline(../inputs/02)

  get result : Number {
    INPUT
    |> String.split("\n")
    |> Array.map(
      (item : String) {
        case (item) {
          // Rock / Lose -> Scissors (3 + 0)
          "A X" => 3

          // Rock / Draw -> Rock (1 + 3)
          "A Y" => 4

          // Rock / Win -> Paper (2 + 6)
          "A Z" => 8

          // Paper / Lose -> Rock (1 + 0)
          "B X" => 1

          // Paper / Draw -> Paper (2 + 3)
          "B Y" => 5

          // Paper / Win -> Scissors (3 + 6)
          "B Z" => 9

          // Scissors / Lose -> Paper (2 + 0)
          "C X" => 2

          // Scissors / Draw -> Scissors (3 + 3)
          "C Y" => 6

          // Scissors / Win -> Rock (1 + 6)
          "C Z" => 7

          // Should not happen
          => 0
        }
      })
    |> Array.sum
  }

  fun render : String {
    Number.toString(result)
  }
}
