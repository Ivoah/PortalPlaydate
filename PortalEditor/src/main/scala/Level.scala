package net.ivoah.portaleditor

case class Level(map: collection.mutable.Seq[Int], links: Seq[(Int, Int)], hasElevator: Boolean, message: String) derives upickle.default.ReadWriter {
  def write(path: os.Path): Unit = os.write.over(path, upickle.default.write(this, indent = 4))
}

object Level {
  val Width = 18
  val Height = 12
  def load(path: os.Path): Level = upickle.default.read(os.read(path))
}
