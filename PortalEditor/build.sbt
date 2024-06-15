ThisBuild / version := "0.1.0-SNAPSHOT"

ThisBuild / scalaVersion := "3.3.1"

lazy val root = (project in file("."))
  .settings(
    name := "PortalEditor",
    idePackagePrefix := Some("net.ivoah.portaleditor"),
    libraryDependencies ++= Seq(
      "org.scala-lang.modules" %% "scala-swing" % "3.0.0",
      "org.scala-lang" %% "toolkit" % "0.1.7"
    )
  )
