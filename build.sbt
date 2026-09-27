
version := "0.2.0"
versionScheme := Some("semver-spec")
scalaVersion := "3.9.0"
publishTo := localStaging.value

val dottyCpsAsyncVersion = "1.4.0"

val djlVersion = "0.38.0"

lazy val root = project.in(file("."))
  .aggregate(rlLogic.jvm, rlLogic.js, rlLogic.native)
  .settings(
    publishArtifact := false,
    publish / skip := true,
  )

lazy val rlLogic = crossProject(JSPlatform, JVMPlatform, NativePlatform)
  .crossType(CrossType.Full)
  .in(file("."))
  .settings(
    name := "rl-logic",
    libraryDependencies += "io.github.dotty-cps-async" %% "dotty-cps-async" % dottyCpsAsyncVersion,
    libraryDependencies += "io.github.dotty-cps-async" %% "dotty-cps-async-logic" % dottyCpsAsyncVersion,
    libraryDependencies += "org.scalameta" %% "munit" % "1.3.6" % Test,
  )
  .jvmSettings(
    libraryDependencies += "ai.djl" % "api" % djlVersion,
    libraryDependencies += "ai.djl" % "bom" % djlVersion,
    libraryDependencies += "ai.djl" % "model-zoo" % djlVersion,
    libraryDependencies += "ai.djl.pytorch" % "pytorch-engine" % djlVersion,

    libraryDependencies += "ai.djl.pytorch" % "pytorch-jni" % "2.7.1-0.38.0" % Runtime,


    libraryDependencies += "org.slf4j" % "slf4j-api" % "2.0.7",
    libraryDependencies += "ch.qos.logback" % "logback-classic" % "1.5.18",
  )
  .jsSettings(
    scalaJSUseMainModuleInitializer := true,
  ).nativeSettings(
  )
