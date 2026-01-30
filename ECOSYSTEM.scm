;; SPDX-License-Identifier: PMPL-1.0-or-later
;; ECOSYSTEM.scm - Project ecosystem positioning

(ecosystem
  (version "1.0.0")
  (name "asdf-cobol-plugin")
  (type "asdf-plugin")
  (purpose "Version management for GnuCOBOL compiler")

  (position-in-ecosystem
    (category "developer-tools")
    (subcategory "version-management")
    (layer "user-facing"))

  (related-projects
    (sibling-standard
      (name "asdf")
      (relationship "plugin-host")
      (url "https://asdf-vm.com"))
    (sibling-standard
      (name "cobol")
      (relationship "managed-tool")
      (url "https://gnucobol.sourceforge.io/")))

  (what-this-is
    "An asdf plugin for managing GnuCOBOL compiler versions")

  (what-this-is-not
    "Not a standalone version manager"
    "Not a replacement for the tool itself"))
