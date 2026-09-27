credentials += Credentials(Path.userHome / ".sbt" / "central_sonatype_credentials")

organization := "io.github.dotty-cps-async"
organizationName := "dotty-cps-async"
organizationHomepage := Some(uri("https://github.com/dotty-cps-async"))

scmInfo := Some(
       ScmInfo(
          uri("https://github.com/dotty-cps-async/rl-logic"),
          "scm:git@github.com:dotty-cps-async/rl-logic.git"
       )
)

developers := List(
          Developer(
             id    = "rssh",
             name  = "Ruslan Shevchenko",
             email = "ruslan@shevchenko.kiev.ua",
             url   = uri("https://github.com/rssh")
          )
)

description := "monad for reinforcement learning"
licenses := List(License("Apache-2.0", uri("https://www.apache.org/licenses/LICENSE-2.0")))
homepage := Some(uri("https://github.com/dotty-cps-async/rl-logic"))

pomIncludeRepository := { _ => false }
publishMavenStyle := true
