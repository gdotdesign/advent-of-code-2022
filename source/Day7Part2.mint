/*
--- Part Two ---

Now, you're ready to choose a directory to delete.

The total disk space available to the filesystem is 70000000. To run the
update, you need unused space of at least 30000000. You need to find a
directory you can delete that will free up enough space to run the update.

In the example above, the total size of the outermost directory (and thus the
total amount of used space) is 48381165; this means that the size of the unused
space must currently be 21618835, which isn't quite the 30000000 required by
the update. Therefore, the update still requires a directory with total size
of at least 8381165 to be deleted before it can run.

To achieve this, you have the following options:

    Delete directory e, which would increase unused space by 584.
    Delete directory a, which would increase unused space by 94853.
    Delete directory d, which would increase unused space by 24933642.
    Delete directory /, which would increase unused space by 48381165.

Directories e and a are both too small; deleting them would not free up enough
space. However, directories d and / are both big enough! Between these, choose
the smallest: d, increasing unused space by 24933642.

Find the smallest directory that, if deleted, would free up enough space on
the filesystem to run the update. What is the total size of that directory?
*/
component Day7Part2 {
  const INPUT = @inline(../inputs/07)

  fun addDirectory (dir : String, node : Node, cwd : Array(String)) {
    case node {
      Node.Directory(name, files) =>
        case cwd[0] {
          Maybe.Nothing =>
            Node.Directory(
              files: Array.push(files, Node.Directory(name: dir, files: [])),
              name: name)

          Maybe.Just(item) =>
            Node.Directory(
              name: name,
              files:
                Array.map(files,
                  (node2 : Node) {
                    case node2 {
                      Node.Directory(name, files) =>
                        if name == item {
                          addDirectory(dir, node2, Array.dropStart(cwd, 1))
                        } else {
                          node2
                        }

                      Node.File => node2
                    }
                  }))
        }

      Node.File => node
    }
  }

  fun addFile (file : String, size : Number, node : Node, cwd : Array(String)) {
    case node {
      Node.Directory(name, files) =>
        case cwd[0] {
          Maybe.Nothing =>
            Node.Directory(
              files: Array.push(files, Node.File(name: file, size: size)),
              name: name)

          Maybe.Just(item) =>
            Node.Directory(
              name: name,
              files:
                Array.map(files,
                  (node2 : Node) {
                    case node2 {
                      Node.Directory(name, files) =>
                        if name == item {
                          addFile(file, size, node2, Array.dropStart(cwd, 1))
                        } else {
                          node2
                        }

                      Node.File => node2
                    }
                  }))
        }

      Node.File => node
    }
  }

  get root : Node {
    {
      INPUT
      |> String.split("\n")
      |> Array.reduce({Node.Directory(name: "", files: []), [] of String},
        (memo : Tuple(Node, Array(String)), line : String) {
          let {root, cwd} =
            memo

          case `#{line}[0]` as String {
            "$" =>
              case `#{line}.slice(2, 4)` as String {
                "cd" =>
                  {
                    let dir =
                      `#{line}.slice(5)` as String

                    case dir {
                      ".." => {root, Array.dropEnd(cwd, 1)}

                      "/" => {root, []}

                      => {root, Array.push(cwd, dir)}
                    }
                  }

                => memo
              }

            =>
              {
                let {head, name} =
                  `#{line}.split(" ")` as Tuple(String, String)

                case head {
                  "dir" => {addDirectory(name, root, cwd), cwd}

                  =>
                    {
                      addFile(name, Number.fromString(head) or 0, root, cwd),
                      cwd
                    }
                }
              }
          }
        })
    }[0]
  }

  fun sum (
    memo : Tuple(Number, Array(Tuple(String, Number))),
    node : Node
  ) : Tuple(Number, Array(Tuple(String, Number))) {
    case node {
      Node.File(_, size) => {memo[0] + size, memo[1]}

      Node.Directory(name, files) =>
        {
          let item =
            Array.reduce(files, {0, []}, sum)

          let subs =
            for x of item[1] {
              ({"#{name}/#{x[0]}", x[1]})
            }

          {memo[0] + item[0], Array.concat([[{name, item[0]}], memo[1], subs])}
        }
    }
  }

  fun renderNode (node : Node) : Html {
    case node {
      Node.Directory(name, files) =>
        <details>
          <summary><>name</></summary>

          <div style="padding-left: 20px">
            for item of files {
              renderNode(item)
            }
          </div>
        </details>

      Node.File(name, size) => <div><>"#{name}: #{size}"</></div>
    }
  }

  fun render : Html {
    <div>
      <>renderNode(root)</>

      {
        let x =
          sum({0, []}, root)

        (x[1]
        |> Array.select(
          (item : Tuple(String, Number)) {
            (70000000 - x[0] + item[1]) >= 30000000
          })
        |> Array.map((item : Tuple(String, Number)) { item[1] })
        |> Array.min
        |> Maybe.map(Number.toString)) or ""
      }
    </div>
  }
}
