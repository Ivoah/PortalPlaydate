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

  private var level: Level = Level.EmptyLevel

  private val palette = ComboBox(tileset.map(new ImageIcon(_)))

  private val mainPanel = new Panel {
    extension (p: Point) {
      def -(o: Point): Point = Point(p.x - o.x, p.y - o.y)
    }

    private def itoxy(i: Int) = ((i%Level.Width)*20, i/Level.Width*20)
    private def xytoi(x: Int, y: Int) = y/20*Level.Width + x/20

    private var linkInProgress: Option[Int] = None

    override def paintComponent(g: Graphics2D): Unit = {
      super.paintComponent(g)
//      g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON)

      val mouse = MouseInfo.getPointerInfo.getLocation - this.peer.getLocationOnScreen

      g.setPaint(Color.BLACK)
      for (x <- 0 until Level.Width; y <- 0 until Level.Height) {
        val tile = level.map(y*Level.Width + x)
        if (tile > 0 && !(mouse.x/20 == x && mouse.y/20 == y && tile - 1 != palette.selection.index && linkInProgress.isEmpty)) {
          g.drawImage(tileset(tile - 1), x*20, y*20, null)
        }
      }

      g.setPaint(Color.RED)
      for ((source, target) <- level.links) {
        val (sx, sy) = itoxy(source)
        val (tx, ty) = itoxy(target)
        g.drawLine(sx + 10, sy + 10, tx + 10, ty + 10)
      }

      linkInProgress match {
        case Some(i) =>
          val (sx, sy) = itoxy(i)
          g.drawLine(sx + 10, sy + 10, mouse.x, mouse.y)
        case None =>
          g.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 0.5))
          g.drawImage(tileset(palette.selection.index), mouse.x/20*20, mouse.y/20*20, null)
      }
    }

    mouse.clicks.reactions += {
      case event: MousePressed =>
        linkInProgress match {
          case Some(i) =>
            level.links.append((i, xytoi(event.point.x, event.point.y)))
            linkInProgress = None
          case _ =>
            if (SwingUtilities.isRightMouseButton(event.peer)) {
              // level.map(xytoi(event.point.x, event.point.y)) = 0
              linkInProgress = Some(xytoi(event.point.x, event.point.y))
            } else {
              level.map(xytoi(event.point.x, event.point.y)) = palette.selection.index + 1
            }
        }
        repaint()
    }
    mouse.moves.reactions += {
      case _: MouseMoved => repaint()
      case event: MouseDragged if event.point.x > 0 && event.point.x < size.width && event.point.y > 0 && event.point.y < size.height =>
        if (SwingUtilities.isRightMouseButton(event.peer)) {
          level.map(xytoi(event.point.x, event.point.y)) = 0
        } else {
          level.map(xytoi(event.point.x, event.point.y)) = palette.selection.index + 1
        }
        repaint()
    }
    listenTo(mouse.clicks)
    listenTo(mouse.moves)

    preferredSize = Dimension(Level.Width*20, Level.Height*20)
  }

  private val fileChooser = new FileChooser(projectRoot.resolve("levels").toFile) {
    fileFilter = new FileNameExtensionFilter("JSON files", "json")
  }

  menuBar = new MenuBar {
    contents ++= Seq(
      new MenuItem(Action("New level") {
        if (fileChooser.showSaveDialog(mainFrame) == FileChooser.Result.Approve) {
          level = Level.EmptyLevel
          saveLevel()
        }
      }),
      new MenuItem(Action("Load level") {
        if (fileChooser.showOpenDialog(mainFrame) == FileChooser.Result.Approve) {
          loadLevel(fileChooser.selectedFile)
        }
      }),
      new MenuItem(Action("Save level") {
        saveLevel()
      })
    )
  }

  def loadLevel(newLevel: File): Unit = {
    fileChooser.selectedFile = newLevel
    level = Level.load(os.Path(newLevel))
    mainPanel.repaint()
  }

  private def saveLevel(): Unit = {
    level.write(os.Path(fileChooser.selectedFile))
  }

  contents = new BorderPanel {
    layout(mainPanel) = BorderPanel.Position.Center
    layout(palette) = BorderPanel.Position.South
  }

  title = "Portal Prelude level editor"
  centerOnScreen()
}
