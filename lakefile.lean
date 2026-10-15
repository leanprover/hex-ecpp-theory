import Lake
open System Lake DSL

package «hex-ecpp-theory» where
  leanOptions := #[⟨`doc.verso, true⟩, ⟨`doc.verso.suggestions, false⟩]

require HexArith from git
  "https://github.com/leanprover/hex-arith.git" @ "v0.10.0"
require HexPrimality from git
  "https://github.com/leanprover/hex-primality.git" @ "v0.10.0"
require HexECPP from git
  "https://github.com/leanprover/hex-ecpp.git" @ "v0.10.0"
require HexPrimalityTheory from git
  "https://github.com/leanprover/hex-primality-theory.git" @ "v0.10.0"
require TauCeti from git
  "https://github.com/TauCetiProject/TauCeti.git" @ "1c497c347f615b3087cb605f8cf743e591376105"
require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "6b7abb3c7686292736be2955bd3eb9ebf63b456a"

target hexecpppariio pkg : FilePath := do
  let oFile := pkg.dir / defaultBuildDir / "HexECPPTheory" / "ffi" / "pari_pipe.o"
  let srcTarget ← inputTextFile <| pkg.dir / "HexECPPTheory" / "ffi" / "pari_pipe.c"
  let oTarget ← buildFileAfterDep oFile srcTarget fun srcFile => do
    createParentDirs oFile
    proc {
      cmd := "cc"
      args := #["-c", "-o", oFile.toString, srcFile.toString,
        "-I", (← getLeanIncludeDir).toString, "-fPIC", "-O2", "-std=c11"]
      env := #[("TMPDIR", some (← IO.FS.realPath (oFile.parent.getD ".")).toString)]
    }
  buildStaticLib (pkg.staticLibDir / nameToStaticLib "hexecpppariio") #[oTarget]

@[default_target]
lean_lib HexECPPTheory where
  roots := #[`HexECPPTheory, `HexECPPTheory.Native, `HexECPPTheory.Pari]

lean_lib HexECPPTheoryPariIO where
  roots := #[`HexECPPTheory.Pari.IO]
  globs := #[.one `HexECPPTheory.Pari.IO]
  precompileModules := true
  moreLinkObjs := #[hexecpppariio]

@[default_target]
lean_lib HexECPPTheoryModules where
  globs := #[`HexECPPTheory.Native, `HexECPPTheory.Pari]

lean_lib HexECPPTheoryTests where
  globs := #[`HexECPPTheory.Tests]
