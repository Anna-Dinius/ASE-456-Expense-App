# Documentation Index

This folder contains all project documentation, organized by type.  
Markdown (`.md`) files are the editable sources. PDF files are exported deliverables for submission or presentation.

---

## 📐 Design

- `design/architecture_design.md` – Source document for system architecture design
- `design/architecture_design.pdf` – Exported PDF (slides) version

## 📖 Manuals

- `manuals/user_manual.md` – Source document for the user manual
- `manuals/user_manual.pdf` – Exported PDF (slides) version

## 📊 Progress Reports

Team progress reports organized by sprint and week:

- `Progress Reports/Sprint 1/` – Sprint 1 templates and team presentation (Markdown + PDF)
- `Progress Reports/Sprint 2/` – Sprint 2 template
- `Progress Reports/Week N/` – Weekly reports (Markdown + PDF)
- `Progress Reports/Final Report/` – Final team presentation (Markdown + PDF)

## 📝 Weekly Reports

- `jeff_weekly_reports/` – Individual weekly progress reports and sprint plans authored by Jeff Perdue

## 🗂 File Structure

- `file-structure.txt` – Auto‑generated ASCII tree of the repository (kept up to date by `scripts/update_file_tree.py`)

---

## Conventions

- **Markdown first**: Always edit `.md` files. PDFs are generated exports.
- **Marp reports**: Use marp to create slides for docs and reports.
- **Naming**: Use lowercase with hyphens for new files (e.g., `week-11.md`).
- **Assets**: Place screenshots or images in a dedicated `assets/` or `screenshots` folder if needed.
- **Updates**: Run `scripts/update_file_tree.py` to refresh `file-structure.txt`.

---

## Purpose

This organization ensures:

- Clear separation between design docs, manuals, team progress, and individual reports
- Easy navigation for contributors and reviewers
- Consistent pairing of source and deliverable formats
