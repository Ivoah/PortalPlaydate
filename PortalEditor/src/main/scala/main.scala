package net.ivoah.portaleditor

import java.io.File
import javax.imageio.ImageIO
import java.awt.image.BufferedImage

@main
def main(tilesetPath: String): Unit = {
  val tilesetImage = ImageIO.read(File(tilesetPath))
  val tileset = (0 until tilesetImage.getHeight by 20).flatMap { y =>
    (0 until tilesetImage.getWidth by 20).map { x =>
      tilesetImage.getSubimage(x, y, 20, 20)
    }
  }

  val editor = Editor(tileset)
  editor.open()

  editor.loadLevel(File("../Source/levels/level6.json").getAbsoluteFile)
}
