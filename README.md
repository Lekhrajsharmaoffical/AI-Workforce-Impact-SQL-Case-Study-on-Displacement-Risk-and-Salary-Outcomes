# 🤖 AI & The Future of Work — SQL Workforce Case Study

> *A comprehensive SQL-driven analysis of how Artificial Intelligence is reshaping jobs, salaries, and career prospects across the global workforce.*

---

## 📌 Project Overview

This case study analyses **15,000 employment records** spanning **10 job roles**, **9 countries**, **8 industries**, and **7 years (2020–2026)** to quantify the real financial impact of AI on workers worldwide.

Using **26 structured SQL queries** — including CTEs, window functions, running totals, LAG/LEAD functions, and conditional aggregations — the project moves from raw data through engineered features to 12 synthesised findings that tell a single, connected story about AI's effect on the global workforce.

---

## 📁 Repository Files

| File | Description |
|---|---|
| `AI.csv` | Raw dataset — 15,000 records, 15 columns covering job roles, countries, salaries, automation risk, AI adoption, and skill metrics (2020–2026) |
| `AI___THE_FUTURE_OF_WORK.sql` | Complete SQL file — data modelling (4 engineered columns) + 26 analytical queries with inline commentary and business context |
| `AI_Workforce_Impact_Analysis_Report.pdf` | Final analysis report — 12 unified findings written in plain language, synthesised from all query outputs |
| `AI_SQL_Question_Sheet.docx` | Question sheet — the structured set of analytical questions that guided the entire case study, organised in 3 difficulty phases |

---

## 🗂️ Dataset — Column Reference

| Column | Type | Description |
|---|---|---|
| `job_id` | Integer | Unique row identifier |
| `job_role` | String | Occupation (10 roles: Software Engineer, Data Analyst, Truck Driver, etc.) |
| `industry` | String | Sector (8 industries: Technology, Finance, Healthcare, etc.) |
| `country` | String | Country (9: USA, UK, Germany, India, Brazil, Canada, Australia, Singapore, Japan) |
| `year` | Integer | Observation year (2020–2026) |
| `automation_risk_percent` | Float | Probability (%) that job tasks can be automated |
| `ai_replacement_score` | Float | Composite index measuring AI's likelihood of replacing the worker |
| `skill_gap_index` | Float | Gap between current worker skills and AI-era skill requirements (0–100) |
| `salary_before_usd` | Float | Annual salary before AI disruption (USD) |
| `salary_after_usd` | Float | Annual salary after AI-driven market changes (USD) |
| `salary_change_percent` | Float | Percentage change in salary after AI impact |
| `skill_demand_growth_percent` | Float | Year-over-year growth in employer demand for role-specific skills |
| `remote_feasibility_score` | Float | How feasible it is to perform this job remotely (0–100) |
| `ai_adoption_level` | Float | Current AI tool penetration in this role (0–100) |
| `education_requirement_level` | Integer | Minimum education: 1=High School → 5=PhD |

---

## 🔧 Data Modelling — Engineered Columns

Before analysis, 4 derived columns were added to enrich the dataset:

```sql
-- 1. salary_gap_usd: absolute dollar salary change
salary_gap_usd = ROUND((salary_after_usd - salary_before_usd), 2)

-- 2. net_salary_outcome: binary financial verdict
net_salary_outcome = CASE
    WHEN salary_after_usd > salary_before_usd THEN 'Gainer'
    ELSE 'Loser'
END

-- 3. replacement_risk_band: 4-tier risk classification
replacement_risk_band = CASE
    WHEN ai_replacement_score < 25            THEN 'Low'
    WHEN ai_replacement_score BETWEEN 25 AND 50 THEN 'Moderate'
    WHEN ai_replacement_score BETWEEN 50 AND 75 THEN 'High'
    WHEN ai_replacement_score > 75            THEN 'Critical'
END

-- 4. ai_net_position: worker's structural AI position
ai_net_position = CASE
    WHEN ai_adoption_level > 50 AND salary_change_percent > 0      THEN 'AI-Augmented'
    WHEN automation_risk_percent > 60 AND salary_change_percent < 0 THEN 'AI-Displaced'
    WHEN skill_demand_growth_percent > 10                           THEN 'Emerging Demand'
    ELSE 'Transitioning'
END
```

---

## 📊 SQL Queries — Full Index (26 Queries)

### Phase 1 — Foundation Queries
| # | Query Name | SQL Concepts |
|---|---|---|
| Q1 | Country-Level Pre/Post AI Salary Impact | `GROUP BY`, `AVG()`, `ORDER BY` |
| Q2 | Avg Replacement Score & Skill Demand Growth by Industry | `GROUP BY`, `AVG()`, `ROUND()` |
| Q3 | Sector Automation Exposure Ranking | `GROUP BY`, `AVG()`, `ORDER BY DESC` |
| Q4 | Gainer Trend By Year (2020–2026) | `CTE`, `SUM() OVER()`, `JOIN` |
| Q5 | AI Net Position Category Validation | `GROUP BY`, `COUNT()`, `AVG()`, `CASE WHEN` |
| Q6 | Replacement Risk Band Distribution | `GROUP BY`, `COUNT()`, `AVG()`, window `SUM()` |
| Q7 | Country-Level Salary Impact (Percentage View) | `GROUP BY`, `AVG()`, derived column |
| Q8 | Job Role Displacement Risk Ranking | `CTE`, `RANK()`, `PARTITION BY` |
| Q9 | Salary Gap Extreme Records (MAX & MIN) | `UNION ALL`, subquery `MAX()`/`MIN()` |
| Q10 | AI Adoption vs Skill Demand Growth | `GROUP BY`, `CASE WHEN` segmentation |

### Phase 2 — Intermediate Queries
| # | Query Name | SQL Concepts |
|---|---|---|
| Q11 | Net Salary Outcome by Country | `GROUP BY`, `SUM(CASE WHEN)`, ratio |
| Q12 | Automation Tier × Replacement Band Crosstab | `CASE WHEN`, `SUM() OVER (PARTITION BY)` |
| Q13 | Automation Tier Salary & Replacement Summary | `CASE WHEN` tiering, `GROUP BY`, `AVG()` |
| Q14 | AI Net Position — Industry Concentration | `GROUP BY`, `COUNT()`, `RANK() OVER` |
| Q15 | Salary Gap Amplification — Salary Bands | `CASE WHEN`, `GROUP BY`, `AVG()`, `SUM()` |
| Q16 | Education Level Risk & Salary Profiling | `GROUP BY`, `AVG()`, `CASE WHEN` |
| Q17 | High-Risk Roles by Country | `GROUP BY`, `HAVING`, `RANK() OVER` |
| Q18 | Automation Risk Trend — 2020 vs 2026 | `CTE`, `FIRST_VALUE()`, delta column |

### Phase 3 — Advanced Window Function Queries
| # | Query Name | SQL Concepts |
|---|---|---|
| Q19 | Post-AI Salary Ranking Across Countries | `RANK() OVER (PARTITION BY country)` |
| Q20 | Peak Exposure Records | `ROW_NUMBER() OVER (PARTITION BY job_role)` |
| Q21 | Replacement Band Migration — YoY Change | `LAG(count,1) OVER (PARTITION BY band)` |
| Q22 | Skill Gap Decile Amplification Analysis | `CTE chain`, `CASE WHEN` deciles, modal band |
| Q23 | Cumulative Salary Gap Trajectory | `SUM() OVER (ROWS UNBOUNDED PRECEDING)` |
| Q24 | Avg Replacement Score & Skill Gap (2026) | `WHERE year=2026`, `GROUP BY`, `AVG()` |
| Q25 | Job Role Displacement Risk Ranking — Version A | `CTE`, `RANK()`, `JOIN` |
| Q26 | Job Role Displacement Risk Ranking — Version B | `CTE`, `DENSE_RANK()`, refined logic |

---

## 🔑 Key Findings (Summary)

| # | Finding | Headline Number |
|---|---|---|
| 1 | AI affects all roles but creates structural winners and losers | +$11,627 (Data Analyst) vs −$20,051 (Accountant) over 7 years |
| 2 | Truck Driver and Accountant face the greatest displacement threat | Replacement scores: 81.86 and 75.22 |
| 3 | Software Engineers are the universal AI winners — in every country | +$10,356 avg gain in USA; 89–95% gainer rate globally |
| 4 | Transportation is the most exposed industry; Education the safest | 55.94% vs 29.56% avg automation risk |
| 5 | USA gains the most ($+406K net); India converts the most workers | India: 51.26% gainer rate — highest of all 9 countries |
| 6 | AI creates a $6,779 annual income gap between positions | AI-Augmented: +$3,718/yr vs AI-Displaced: −$3,061/yr |
| 7 | Critical-band workers have a 9-in-10 chance of salary loss | 90.70% negative outcome rate in Critical band |
| 8 | Deeper AI adoption = better outcomes for workers | Advanced (75–100): +$1,268 avg gain vs Growing (25–50): −$225 loss |
| 9 | High-automation jobs lose 7.57% salary; low-automation jobs gain 3.81% | Clear inverse relationship confirmed across all years |
| 10 | The share of workers benefiting from AI is shrinking every year | 7.51% gainers (2020) → 6.58% gainers (2026) |
| 11 | Mid-level education (Level 3) offers the best AI-era protection | +$1,220 avg gain; 64.40% gainer rate |
| 12 | The hardest-hit workers lose nearly $5,000 per year | Severe Loss band: −$4,959/yr avg; 83.44% AI-Displaced |

---

## 🚀 How to Use This Repository

### Step 1 — Set up the database
```sql
-- Create a schema and import the CSV
CREATE SCHEMA ai_case_study;
USE ai_case_study;

-- Import AI.csv as table named 'ai'
-- (Use MySQL Workbench Table Data Import Wizard or LOAD DATA INFILE)
```

### Step 2 — Run the Data Modelling section first
Open `AI___THE_FUTURE_OF_WORK.sql` and execute the **DATA MODELING** block at the top. This adds the 4 engineered columns that every subsequent query depends on.

```sql
-- Always run this block first before any analysis queries
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE ai ADD COLUMN salary_gap_usd ...
ALTER TABLE ai ADD COLUMN net_salary_outcome ...
ALTER TABLE ai ADD COLUMN replacement_risk_band ...
ALTER TABLE ai ADD COLUMN ai_net_position ...
```

### Step 3 — Run queries in order (Q1 → Q26)
Each query is self-contained and includes inline comments explaining the business question, SQL logic, and expected output. You can run them individually or sequentially.

### Step 4 — Read the Analysis Report
Open `AI_Workforce_Impact_Analysis_Report.pdf` to read the 12 synthesised findings — written in plain language — that combine all 26 query outputs into one connected narrative.

### Step 5 — Review the Question Sheet
Open `AI_SQL_Question_Sheet.docx` to see the structured questions that guided this analysis, organised by difficulty (Phase 1 → Phase 3). Useful for understanding the analytical thinking behind each query.

---

## 🛠️ Tools & Environment

| Tool | Purpose |
|---|---|
| **MySQL 8.0+** | Query execution environment |
| **MySQL Workbench** | IDE used for writing and running all queries |
| **SQL** | Primary language — CTEs, window functions, aggregations |

> ⚠️ **Note:** All queries are written for **MySQL 8.0+**. Some window function syntax (e.g. `RANK()`, `LAG()`, `ROW_NUMBER()`) requires MySQL 8.0 or above. They will not run on MySQL 5.x.

---

## 📐 SQL Concepts Demonstrated

```
✅ Common Table Expressions (CTEs)        ✅ RANK() / DENSE_RANK() / ROW_NUMBER()
✅ LAG() / FIRST_VALUE()                  ✅ Running totals — SUM() OVER (ROWS UNBOUNDED PRECEDING)
✅ PARTITION BY (multi-column)            ✅ Conditional aggregation — SUM(CASE WHEN)
✅ HAVING with aggregates                 ✅ UNION ALL
✅ Derived / engineered columns           ✅ Multi-CTE pipeline queries (4–6 CTEs chained)
✅ Subqueries inside WHERE                ✅ Year-on-year delta analysis
✅ CASE WHEN segmentation                 ✅ Modal category extraction via RANK() + filter
```

---

## 📈 Project Highlights for Recruiters

- **Scale:** 15,000 records × 15 columns × 26 queries — a full end-to-end analytical project
- **Depth:** Moves from simple GROUP BY aggregations to 6-CTE master dashboard queries
- **Business focus:** Every query answers a specific business question about AI's financial impact on workers
- **Self-documented:** Every query block includes the business question, story context, SQL logic explanation, and expected output type
- **Reproducible:** Any analyst with MySQL 8.0+ and the CSV can replicate every result exactly

---

## 📄 Resume Summary

**AI & Workforce Impact: SQL Case Study on Displacement Risk and Salary Outcomes**

- Analyzed 15,000 employment records across 10 roles, 9 countries & 7 industries (2020–2026); engineered 4 derived columns and executed 26 advanced SQL queries using CTEs, window functions, and running totals to quantify AI's financial impact on the global workforce.
- Identified Software Engineer as the top AI-beneficiary (+$10,356 avg gain, 89–95% gainer rate) and Truck Driver as highest-risk (replacement score 81.86, 80.8% Critical band); Critical-band workers showed a $4,996 avg annual salary deficit versus Low-band peers.
- Uncovered a steady decline in financial beneficiaries (7.51% → 6.58%, 2020–2026) despite rising AI adoption; Advanced-adoption roles yielded +$1,268 avg salary gain while Growing-stage roles produced −$225, confirming that partial AI adoption harms earnings before full integration delivers returns.

---

## 🤝 Connect

If you have questions about the methodology, want to discuss the findings, or are interested in collaborating — feel free to reach out via GitHub Issues or LinkedIn.

---

*Prepared as part of a SQL-Based Workforce AI Case Study | Dataset: 15,000 records, 2020–2026 | 26 SQL queries across 10 job roles, 9 countries, 8 industries*
