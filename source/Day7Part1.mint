/*
--- Day 7: No Space Left On Device ---

You can hear birds chirping and raindrops hitting leaves as the expedition
proceeds. Occasionally, you can even hear much louder sounds in the distance;
how big do the animals get out here, anyway?

The device the Elves gave you has problems with more than just its
communication system. You try to run a system update:

$ system-update --please --pretty-please-with-sugar-on-top
Error: No space left on device

Perhaps you can delete some files to make space for the update?

You browse around the filesystem to assess the situation and save the resulting
terminal output (your puzzle input). For example:

$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k

The filesystem consists of a tree of files (plain data) and directories (which
can contain other directories or files). The outermost directory is called /.
You can navigate around the filesystem, moving into or out of directories and
listing the contents of the directory you're currently in.

Within the terminal output, lines that begin with $ are commands you executed,
very much like some modern computers:

  cd means change directory. This changes which directory is the current
  directory, but the specific result depends on the argument:
    cd x moves in one level: it looks in the current directory for the
    directory named x and makes it the current directory.

    cd .. moves out one level: it finds the directory that contains the current
    directory, then makes that directory the current directory.

    cd / switches the current directory to the outermost directory, /.

  ls means list. It prints out all of the files and directories immediately
  contained by the current directory:
    123 abc means that the current directory contains a file named abc with
    size 123.

    dir xyz means that the current directory contains a directory named xyz.

Given the commands and output in the example above, you can determine that the
filesystem looks visually like this:

- / (dir)
  - a (dir)
    - e (dir)
      - i (file, size=584)
    - f (file, size=29116)
    - g (file, size=2557)
    - h.lst (file, size=62596)
  - b.txt (file, size=14848514)
  - c.dat (file, size=8504156)
  - d (dir)
    - j (file, size=4060174)
    - d.log (file, size=8033020)
    - d.ext (file, size=5626152)
    - k (file, size=7214296)

Here, there are four directories: / (the outermost directory), a and d (which
are in /), and e (which is in a). These directories also contain files of
various sizes.

Since the disk is full, your first step should probably be to find directories
that are good candidates for deletion. To do this, you need to determine the
total size of each directory. The total size of a directory is the sum of the
sizes of the files it contains, directly or indirectly. (Directories themselves
do not count as having any intrinsic size.)

The total sizes of the directories above can be found as follows:

  The total size of directory e is 584 because it contains a single file i of
  size 584 and no other directories.

  The directory a has total size 94853 because it contains files f (size 29116),
  g (size 2557), and h.lst (size 62596), plus file i indirectly (a contains e
  which contains i).

  Directory d has total size 24933642.

  As the outermost directory, / contains every file. Its total size is 48381165,
  the sum of the size of every file.

To begin, find all of the directories with a total size of at most 100000, then
calculate the sum of their total sizes. In the example above, these directories
are a and e; the sum of their total sizes is 95437 (94853 + 584). (As in this
example, this process can count files more than once!)

Find all of the directories with a total size of at most 100000. What is the
sum of the total sizes of those directories?
*/
type Node {
  Directory(name : String, files : Array(Node))
  File(name : String, size : Number)
}

component Day7Part1 {
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
          {
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
      renderNode(root)

      sum({0, []}, root)[1]
      |> Array.select((item : Tuple(String, Number)) { item[1] <= 100000 })
      |> Array.map((item : Tuple(String, Number)) { item[1] })
      |> Array.sum
      |> Number.toString
    </div>
  }
}
