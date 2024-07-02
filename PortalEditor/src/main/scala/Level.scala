package net.ivoah.portaleditor

case class Level(map: collection.mutable.Seq[Int], links: collection.mutable.Buffer[(Int, Int)], hasElevator: Boolean, message: String) derives upickle.default.ReadWriter {
  // def write(path: os.Path): Unit = os.write.over(path, upickle.default.write(this, indent = 4))
  def write(path: os.Path): Unit = {
    os.write.over(path, s"""{
    |  "map": [
    |${map.grouped(18).map(_.map(d => f"$d%2d").mkString(", ")).map("    " + _).mkString(",\n")}
    |  ],
    |  "links": [
    |${links.map(l => s"[${l._1}, ${l._2}]").map("    " + _).mkString(",\n")}
    |  ],
    |  "hasElevator": ${upickle.default.write(hasElevator)},
    |  "message": ${upickle.default.write(message)}
    |}
    |""".stripMargin)
  }
}

object Level {
  val Width = 18
  val Height = 12
  def load(path: os.Path): Level = upickle.default.read(os.read(path))
  
  val EmptyLevel: Level = Level(
    collection.mutable.Seq(
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ),
    scala.collection.mutable.Buffer[(Int, Int)](),
    true,
    ""
  )
}
