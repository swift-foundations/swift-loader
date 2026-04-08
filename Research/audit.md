# Audit: swift-loader

## Legacy — Consolidated 2026-04-08

### From: swift-institute/Research/platform-compliance-audit.md (2026-03-19)

**Skill**: platform — [PLAT-ARCH-001-010], [PATTERN-001], [PATTERN-004a], [PATTERN-005]

| # | Severity | Rule | Location | Finding | Status |
|---|----------|------|----------|---------|--------|
| H-37 | HIGH | [PLAT-ARCH-008] | exports.swift:14-16 | Platform-conditional imports of Darwin_Kernel / Linux_Kernel. Fix: Use `import Kernel`. | OPEN |
| H-38 | HIGH | [PLAT-ARCH-008] | Loader.Section.swift:14-49 | `#if canImport(Darwin)` / `#if os(Linux)` for Mach-O vs ELF section enumeration. Fix: Use `import Kernel`; unify through Kernel or dedicated loader abstraction. | OPEN — Missing unified `Kernel.Loader` API |
| H-39 | HIGH | [PLAT-ARCH-008] | Loader.Symbol.swift:14-46 | `#if canImport(Darwin)` / `#if os(Linux)` / `#if os(Windows)` for symbol lookup. Fix: Unify through Kernel. | OPEN |

---

### From: swift-institute/Research/modularization-audit-foundations-batch-B.md (2026-03-20)

**Modularization audit — MOD-001 through MOD-014**

1 product: Loader. 2 targets: Loader + CTypeMetadata (C shim).

| Rule | Status | Notes |
|------|--------|-------|
| MOD-001 | N/A | Main + C shim pattern |
| MOD-002 | N/A | Single Swift target |
| MOD-003 | N/A | CTypeMetadata is a C build dependency, not a variant |
| MOD-004 | N/A | No ~Copyable concerns |
| MOD-005 | N/A | Single product |
| MOD-006 | REVIEW | Package declares `swift-darwin-primitives` as a package dep but no target uses it. Similarly `swift-windows` is listed but commented out. Unused package-level deps. |
| MOD-007 | PASS | Depth 1 (Loader → CTypeMetadata) |
| MOD-008 | PASS | Loader: 4 files, CTypeMetadata: C only |
| MOD-009 | N/A | No inline variants |
| MOD-010 | N/A | No stdlib extensions |
| MOD-011 | **FAIL** | No Test Support product |
| MOD-012 | PASS | `Loader`, `CTypeMetadata` — CTypeMetadata is a C shim, naming is conventional |
| MOD-013 | N/A | 2 targets, threshold is 5 |
| MOD-014 | N/A | No cross-package optional integration |

**Findings**: 1 FAIL (MOD-011). 1 REVIEW (MOD-006): Package-level `dependencies:` lists `swift-darwin-primitives` but no target references any product from it. Similarly `swift-windows` is declared but the only reference is commented out. These are dead package-level dependencies.
