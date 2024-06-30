package net.ivoah.portaleditor

import java.awt.{AlphaComposite, Dimension, Image, MouseInfo, RenderingHints, Point, Color}
import scala.swing.*
import java.io.File
import java.nio.file.Path
import javax.swing.filechooser.FileNameExtensionFilter
import javax.swing.ImageIcon
import javax.imageio.ImageIO
import java.awt.image.BufferedImage
import scala.swing.event.Key.Modifier
import javax.swing.SwingUtilities
import scala.swing.event.{MouseDragged, MouseMoved, MousePressed}

class Editor(projectRoot: Path) extends MainFrame {
  private val mainFrame = this

  val tileset = {
    val tilesetImage = ImageIO.read(projectRoot.resolve("images/tiles-table-20-20.png").toFile)
    (0 until tilesetImage.getHeight by 20).flatMap { y =>
      (0 until tilesetImage.getWidth by 20).map { x =>
        tilesetImage.getSubimage(x, y, 20, 20)
      }
    }
  }

  private var level: Level = Level(
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
    Seq(),
    true,
    ""
  )

  private val palette = ComboBox(tileset.map(new ImageIcon(_)))

  private val mainPanel = new Panel {
    extension (p: Point) {
      def -(o: Point): Point = Point(p.x - o.x, p.y - o.y)
    }

    private def itoxy(i: Int) = ((i%Level.Width)*20, i/Level.Width*20)

    override def paintComponent(g: Graphics2D): Unit = {
      super.paintComponent(g)
//      g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON)

      val mouse = MouseInfo.getPointerInfo.getLocation - this.peer.getLocationOnScreen

      g.setPaint(Color.BLACK)
      for (x <- 0 until Level.Width; y <- 0 until Level.Height) {
        val tile = level.map(y*Level.Width + x)
        if (tile > 0 && !(mouse.x/20 == x && mouse.y/20 == y && tile - 1 != palette.selection.index)) {
          g.drawImage(tileset(tile - 1), x*20, y*20, null)
        }
      }

      g.setPaint(Color.RED)
      for ((source, target) <- level.links) {
        val (sx, sy) = itoxy(source)
        val (tx, ty) = itoxy(target)
        g.drawLine(sx + 10, sy + 10, tx + 10, ty + 10)
      }

      g.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 0.5))

      g.drawImage(tileset(palette.selection.index), mouse.x/20*20, mouse.y/20*20, null)
    }

    mouse.clicks.reactions += {
      case event: MousePressed =>
        if (SwingUtilities.isRightMouseButton(event.peer)) {
          level.map(event.point.y / 20 * Level.Width + event.point.x / 20) = 0
        } else {
          level.map(event.point.y/20*Level.Width + event.point.x/20) = palette.selection.index + 1
        }
        repaint()
    }
    mouse.moves.reactions += {
      case _: MouseMoved => repaint()
      case event: MouseDragged if event.point.x > 0 && event.point.x < size.width && event.point.y > 0 && event.point.y < size.height =>
        if (SwingUtilities.isRightMouseButton(event.peer)) {
          level.map(event.point.y / 20 * Level.Width + event.point.x / 20) = 0
        } else {
          level.map(event.point.y / 20 * Level.Width + event.point.x / 20) = palette.selection.index + 1
        }
        repaint()
    }
    listenTo(mouse.clicks)
    listenTo(mouse.moves)

    preferredSize = Dimension(Level.Width*20, Level.Height*20)
  }


  menuBar = new MenuBar {
    contents ++= Seq(
      new Menu("File") {
        contents ++= Seq(
          new MenuItem(Action("Load level") {
            val chooser = new FileChooser(projectRoot.resolve("levels").toFile) {
              fileFilter = new FileNameExtensionFilter("JSON files", "json")
            }
            if (chooser.showOpenDialog(mainFrame) == FileChooser.Result.Approve) {
              loadLevel(chooser.selectedFile)
            }
          }),
          new MenuItem(Action("Save level") {
            val chooser = new FileChooser(projectRoot.resolve("levels").toFile) {
              fileFilter = new FileNameExtensionFilter("JSON files", "json")
            }
            if (chooser.showSaveDialog(mainFrame) == FileChooser.Result.Approve) {
              saveLevel(chooser.selectedFile)
            }
          })
        )
      }
    )
  }

  def loadLevel(newLevel: File): Unit = {
    level = Level.load(os.Path(newLevel))
    mainPanel.repaint()
  }

  def saveLevel(destination: File): Unit = {
    level.write(os.Path(destination))
  }

  contents = new BorderPanel {
    layout(mainPanel) = BorderPanel.Position.Center
    layout(palette) = BorderPanel.Position.South
  }

  title = "Portal Prelude level editor"
  centerOnScreen()
}
