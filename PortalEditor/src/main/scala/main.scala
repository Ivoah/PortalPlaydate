package net.ivoah.portaleditor

import java.io.File
import java.nio.file.Paths

@main
def main(projectRoot: String): Unit = {
  val editor = Editor(Paths.get(projectRoot))
  editor.open()

  editor.loadLevel(File("../Source/levels/level6.json").getAbsoluteFile)
}
