# Instructions for Annotators

## Overview

The SCE Annotation System is a web application for annotating medical imaging cases with **Structured Causal Explanations (SCE)**. Each SCE consists of:

- **Finding**: The observed radiological sign (what is seen on the image)
- **Impression**: The diagnostic interpretation (what it means)
- **Certainty**: Whether you are certain about the causal relationship

Your task is to review each case and verify, edit, or add SCE annotations.

## Getting Started

### 1. Sign In

Sign in with your Google account. You will be redirected to the case list after signing in.

![Login page](screenshots/01_login.png)

### 2. Case List

After signing in, you will see a list of all medical cases. The table shows:

- **Case ID**: The case number
- **Images**: Number of images available
- **SCEs**: Number of your SCE annotations for this case
- **Status**: Whether you have marked this case as "Done"
- **Actions**: Click "View" to open a case

The heading shows your overall progress (e.g., "3 / 200 done").

![Case list](screenshots/02_case_list.png)

Click **"View"** on any case to start annotating.

## Annotating a Case

Each case view contains the following sections, from top to bottom:

### 3. Causal Exploration

Read the causal exploration text carefully. This text describes the causal relationships between radiological findings and their clinical interpretations. Your SCE annotations should capture these relationships.

![Causal exploration](screenshots/03_causal_exploration.png)

### 4. SCE Annotations

This is where you do your annotation work. You will see:

- **Add New SCE** form at the top
- **Existing SCEs** table below, pre-populated with initial annotations extracted from the causal exploration text

![SCE section](screenshots/04_sce_section.png)

#### Reviewing Existing SCEs

Initial annotations are automatically provided as a starting point. Review each one:

- Does the **finding** accurately describe the observed sign?
- Does the **impression** correctly state the interpretation?
- Is the **certainty** appropriate?

#### Editing an SCE

Click **"Edit"** next to any SCE to modify its finding, impression, or certainty.

![Edit SCE](screenshots/05_edit_sce.png)

#### Adding a New SCE

If you identify additional causal statements not captured by the initial annotations:

1. Enter the **Finding** (what is observed on the image)
2. Enter the **Impression** (the diagnostic interpretation)
3. Check **Certain** if you are confident in the relationship
4. Click **"Add SCE"**

#### Deleting an SCE

If an SCE is incorrect or redundant, click **"Delete"** and confirm.

### 5. Images

Review the chest X-ray images for the case. Click any image to view it in full size. Press **Escape** or click outside to close.

![Images section](screenshots/06_images.png)

### 6. Radiology Report

The original radiology report is displayed for reference.

![Report section](screenshots/07_report.png)

### 7. ABCDE Checklist

Click to expand the ABCDE systematic checklist. This shows the structured analysis of the chest X-ray using the ABCDE methodology. Items marked with a red **!** indicate abnormal findings.

![ABCDE checklist](screenshots/08_checklist.png)

## Marking a Case as Done

When you have finished reviewing and editing all SCEs for a case, click the **"Mark as Done"** button in the top-right corner. The button turns green to indicate completion.

![Mark as done](screenshots/09_mark_done.png)

You can click it again to toggle back if you need to make further changes.

## Tips

- Read the **Causal Exploration** text first, then compare it with the pre-populated SCEs.
- Use the **Images** and **Radiology Report** to verify findings.
- Check the **ABCDE Checklist** for systematic coverage of abnormalities.
- Each finding should describe **what you see** (e.g., "minimal blunting of the right costophrenic angle").
- Each impression should describe **what it means** (e.g., "small pleural effusion").
- Mark certainty only when you are confident the finding supports the impression.
- Remember to click **"Mark as Done"** when you finish each case.

## Adding Screenshots

To add screenshots to this document, save them as PNG files in the `docs/screenshots/` folder with the filenames referenced above (e.g., `01_login.png`, `02_case_list.png`, etc.).
