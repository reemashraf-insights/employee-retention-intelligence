# Employee Retention and HR Decision Intelligence

A DiGiLiANS capstone by **Insight Squad** that combines workforce analytics, an explainable attrition model, and a Power BI dashboard. The project connects data preparation, SQL modeling, risk scoring, and a prototype workflow for HR review.

## What the project covers

- **Data preparation.** The cleaning notebook validates employee and application identifiers, removes duplicates and constant columns, and checks workforce business rules. The supplied cleaned CSV contains **23,422 records**.
- **Modeling.** The modeling notebook prepares employee-level features, trains a logistic regression classifier, generates risk scores, and uses SHAP to explain model predictions.
- **Reporting.** The Power BI dashboard presents workforce and retention indicators alongside model outputs for exploratory analysis.
- **Workflow prototype.** The team designed an n8n workflow to read risk records, draft recommendations for review, and route outputs to Google Sheets and Gmail.

## Project files

| Component | Files |
| --- | --- |
| Power BI | [HR Retention Dashboard](HR-Retention-Dashboard.pbix) |
| Data | [Cleaned CSV](IBM_HR_CLEANED.csv), [Final CSV](IBM_HR_FINAL.csv) |
| Notebooks | [Cleaning](IBM_HR_Analysis_Professional_Cleaning.ipynb), [Modeling](HR_Attrition_Final_ML_Drive_Save.ipynb) |
| SQL data model | [SQL script](hr-data-model.sql) |
| Documentation | [Presentation](AI-Powered-Employee-Retention-and-HR-Decision-Intelligence.pdf), [Poster](DiGiLiANS_Capstone_Poster__%20Insight_Squad.pdf), [Report](Insight_Squad_Final_Capstone_Book_Word_Compatible.pdf) |

Run the cleaning notebook first. Review file paths in the modeling notebook before running it. If Power BI refresh asks for missing model exports, regenerate the required CSVs from the modeling notebook and update the report's data source paths.

The classifier's risk scores are intended for analytical review and discussion. Individual employment decisions require human review and appropriate evidence.
