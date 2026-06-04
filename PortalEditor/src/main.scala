package net.ivoah.portaleditor

import java.io.File
import java.nio.file.Paths

@main
def main: Unit = {
  val editor = Editor(Paths.get("../Source"))
  editor.open()

  editor.loadLevel(File("../Source/levels/level1.json").getAbsoluteFile)
}
