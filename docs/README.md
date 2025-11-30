# Documentation Index

This folder contains all project documentation, organized by type.  
Markdown (`.md`) files are the editable sources. PDF files are exported deliverables for submission or presentation.

---

## 📐 Design

- [Architecture Design (Markdown)](design/architecture_design.md) – Source document for system architecture design
- [Architecture Design (PDF)](design/architecture_design.pdf) – Exported PDF (slides) version

## 📖 Manuals

- [User Manual (Markdown)](manuals/user_manual.md) – Source document for the user manual
- [User Manual (PDF)](manuals/user_manual.pdf) – Exported PDF (slides) version

## 📊 Progress Reports

Team progress reports organized by sprint and week:

- [Sprint 1](Progress%20Reports/Sprint%201/) – Sprint 1 templates and team presentation (Markdown + PDF)
- [Sprint 2](Progress%20Reports/Sprint%202/) – Sprint 2 template
- [Final Report](Progress%20Reports/Final%20Report/) – Final team presentation (Markdown + PDF)
- Weekly team reports (Markdown + PDF):
  - [Week 1](Progress%20Reports/Week%201/) – Week 1 report
  - [Week 2](Progress%20Reports/Week%202/) – Week 2 report
  - [Week 3](Progress%20Reports/Week%203/) – Week 3 report
  - [Week 4](Progress%20Reports/Week%204/) – Week 4 report
  - [Week 6](Progress%20Reports/Week%206/) – Week 6 report
  - [Week 7](Progress%20Reports/Week%207/) – Week 7 report
  - [Week 8](Progress%20Reports/Week%208/) – Week 8 report
  - [Week 9](Progress%20Reports/Week%209/) – Week 9 report
  - [Week 10](Progress%20Reports/Week%2010/) – Week 10 report

Located in `docs/Progress Reports/`

## 📝 Jeff's Weekly Reports

- [Jeff’s Reports](jeff_weekly_reports/) – Individual weekly progress reports and sprint plans authored by Jeff Perdue
- Files ending in `.marp.md` are Marp slide decks

Located in `docs/jeff_weekly_reports/`

## 🗂 File Structure

- [file-structure.txt](file-structure.txt) – Auto‑generated ASCII tree of the repository (kept up to date by `scripts/update_file_tree.py`)

---

## Conventions

- **Markdown first**: Always edit `.md` files. PDFs are generated exports.
- **Marp reports**: Use marp to create slides for docs and reports.
- **Naming**: Use lowercase with hyphens for new files (e.g., `week-11.md`).
- **Assets**: Place screenshots or images in a dedicated `assets/` or `screenshots` folder if needed.
- **Updates**: Run `scripts/update_file_tree.py` to refresh `file-structure.txt`.

  - Run:

    ```bash
    python scripts/update_file_tree.py
    ```

---

## Purpose

This organization ensures:

- Clear separation between design docs, manuals, team progress, and individual reports
- Easy navigation for contributors and reviewers
- Consistent pairing of source and deliverable formats
