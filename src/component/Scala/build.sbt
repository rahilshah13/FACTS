val scala3Version = "3.8.3"
import org.scalajs.linker.interface.ModuleSplitStyle

lazy val root = project
  .in(file("."))
  .enablePlugins(ScalaJSPlugin)
  .settings(
    name := "ScalaJS",
    version := "0.1.0-SNAPSHOT",
    scalaVersion := scala3Version,
    scalaJSUseMainModuleInitializer := true,
    scalaJSLinkerConfig ~= {_.withModuleKind(ModuleKind.ESModule).withExperimentalUseWebAssembly(true)},
    libraryDependencies += "org.scala-js" %%% "scalajs-dom" % "2.8.1",
    libraryDependencies += "com.phasmidsoftware" %% "gryphon" % "1.0.0"
  )

  