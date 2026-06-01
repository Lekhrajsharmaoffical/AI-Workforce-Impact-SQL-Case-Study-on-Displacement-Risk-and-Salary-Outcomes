-- ============================================================
--   AI & THE FUTURE OF WORK — SQL Case Study
--   Dataset : ai_case_study.ai  |  15,000 records  |  2020-2026
-- ============================================================


-- ============================================================
-- DATA MODELING
-- ============================================================

SELECT * FROM ai_case_study.ai;
SET SQL_SAFE_UPDATES = 0;

alter table ai
add column salary_gap_usd numeric(10,2)
after salary_after_usd;

update ai
set salary_gap_usd = round((salary_after_usd - salary_before_usd), 2);

select sum(salary_gap_usd) from ai where salary_gap_usd < 0;

alter table ai
add column net_salary_outcome varchar(200)
after salary_gap_usd;

update ai
set net_salary_outcome = case
    when salary_after_usd > salary_before_usd then 'Gainer'
    else 'Loser'
end;

select * from ai where net_salary_outcome = 'Gainer';

alter table ai
add column replacement_risk_band varchar(100)
after ai_replacement_score;

update ai
set replacement_risk_band = case
    when ai_replacement_score < 25            then 'Low'
    when ai_replacement_score between 25 and 50 then 'Moderate'
    when ai_replacement_score between 50 and 75 then 'High'
    when ai_replacement_score > 75            then 'Critical'
end;

alter table ai
add column ai_net_position varchar(100);

update ai
set ai_net_position = case
    when ai_adoption_level > 50 and salary_change_percent > 0   then 'AI-Augmented'
    when automation_risk_percent > 60 and salary_change_percent < 0 then 'AI-Displaced'
    when skill_demand_growth_percent > 10                        then 'Emerging Demand'
    else 'Transitioning'
end;

select * from ai;


-- ============================================================
-- Q1 ----- Country-Level Pre/Post AI Salary Impact
-- ============================================================
-- Story   : Every country felt the AI wave differently — some rode it to higher wages,
--           others were pulled under. The conflict: the same technology produces opposite
--           outcomes depending on where you work.
--           Resolution: ranking countries by avg salary gap reveals who truly benefited.
-- Heading : "The Global Pay Divide — Who Gained and Who Lost Across Nine Nations"
-- ============================================================

select country,
    round(avg(salary_before_usd), 2) avg_salary_before_usd,
    round(avg(salary_after_usd),  2) as avg_salary_after_usd,
    round(avg(salary_gap_usd),    2) as avg_salary_gap_usd
from ai
group by country
order by avg_salary_gap_usd desc;


-- ============================================================
-- Q2 ----- Avg Replacement Score & Skill Demand Growth by Industry
-- ============================================================
-- Story   : Industries that invested in skill-building absorbed AI more smoothly;
--           those that ignored it saw demand stagnate or fall. Conflict: adoption
--           without reskilling creates an unequal playing field across sectors.
--           Resolution: measuring avg skill demand growth exposes which industries
--           are preparing their workers and which are not.
-- Heading : "Prepared or Left Behind — Industry Skill Demand in the AI Era"
-- ============================================================

select industry,
    round(avg(skill_demand_growth_percent), 2) as mean_skill_demand_growth_percent,
    round(avg(ai_adoption_level),           2) as avg_ai_adoption,
    count(*)                                   as total_records
from ai
group by industry
order by round(avg(skill_demand_growth_percent), 2) asc;


-- ============================================================
-- Q3 ----- Sector Automation Exposure Ranking
-- ============================================================
-- Story   : Not every industry stands on the same ground — some face a tide of
--           automation while others barely feel the current. Conflict: automation
--           risk is invisible until it is measured and ranked.
--           Resolution: assigning a rank to each industry's avg automation risk
--           makes the hierarchy undeniable.
-- Heading : "Ranked by Risk — Which Industries Are Most Exposed to Automation"
-- ============================================================

select industry,
    round(avg(automation_risk_percent), 2)             as avg_automation_risk_percent,
    rank() over(order by avg(automation_risk_percent) desc) as rnk
from ai
group by industry
order by avg(automation_risk_percent) desc;


-- ============================================================
-- Q4 ----- Gainer Trend By Year (2020–2026)
-- ============================================================
-- Story   : Year after year, fewer workers benefit financially from AI — even as
--           adoption grows. Conflict: rising AI investment is not translating into
--           a rising share of financial winners.
--           Resolution: tracking gainer percentage over time reveals the shrinking
--           dividend and demands an urgent reskilling response.
-- Heading : "The Shrinking Dividend — Fewer Workers Gain from AI Each Year"
-- ============================================================

with total_records as (
    select year,
        count(*)           as year_records,
        sum(count(*)) over() as total_records
    from ai
    group by year
    order by year asc
),
with_gainer as (
    select year, count(*) as gainer_records
    from ai
    where net_salary_outcome = 'Gainer'
    group by year
)
select r.year,
    r.year_records,
    r.total_records,
    g.gainer_records,
    (g.gainer_records / r.total_records) * 100 as gainer_pct
from total_records as r
join with_gainer   as g on r.year = g.year
order by r.year asc;


-- ============================================================
-- Q5 ----- AI Net Position Category Validation
-- ============================================================
-- Story   : Behind every job title lies a position relative to AI — augmented,
--           displaced, transitioning, or emerging. Conflict: without categorising
--           workers, the aggregate numbers hide who is truly winning or losing.
--           Resolution: the four-category breakdown exposes the real distribution
--           and its salary consequences.
-- Heading : "Four Fates — How AI Positions Every Worker on the Salary Spectrum"
-- ============================================================

SELECT
    ai_net_position,
    COUNT(*)                                    AS record_count,
    ROUND((COUNT(*) * 100.0) / 15000, 2)        AS pct_of_total,
    ROUND(AVG(automation_risk_percent), 2)       AS avg_automation_risk,
    ROUND(AVG(salary_change_percent), 2)         AS avg_salary_change_pct,
    ROUND(AVG(ai_adoption_level), 2)             AS avg_ai_adoption_level,
    ROUND(AVG(salary_gap_usd), 2)                AS avg_salary_gap_usd
FROM ai
GROUP BY ai_net_position
ORDER BY avg_salary_gap_usd DESC;


-- ============================================================
-- Q6 ----- Replacement Risk Band Distribution
-- ============================================================
-- Story   : Every worker carries a score that predicts how likely AI is to replace
--           them. Conflict: most workers are unaware their role sits in a High or
--           Critical band where negative salary outcomes are near-certain.
--           Resolution: distributing records across four risk bands — with outcome
--           percentages — makes the danger visible and measurable.
-- Heading : "The Risk Ladder — From Low Exposure to Critical Displacement"
-- ============================================================

SELECT
    replacement_risk_band,
    COUNT(*)                                                     AS record_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)          AS pct_of_total,
    ROUND(AVG(salary_gap_usd), 2)                                AS avg_salary_gap_usd,
    ROUND(MIN(salary_gap_usd), 2)                                AS min_salary_gap_usd,
    ROUND(MAX(salary_gap_usd), 2)                                AS max_salary_gap_usd,
    ROUND(SUM(CASE WHEN salary_gap_usd > 0
              THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)          AS positive_outcome_pct,
    ROUND(SUM(CASE WHEN salary_gap_usd < 0
              THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)          AS negative_outcome_pct
FROM ai
GROUP BY replacement_risk_band
ORDER BY
    CASE replacement_risk_band
        WHEN 'Low'      THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'High'     THEN 3
        WHEN 'Critical' THEN 4
    END;


-- ============================================================
-- Q7 ----- Country-Level Salary Impact (Percentage View)
-- ============================================================
-- Story   : Dollar figures alone do not tell the full story — a $100 gain means
--           something very different in Brazil versus the USA. Conflict: comparing
--           raw salary gaps across countries with very different wage baselines
--           distorts the real impact.
--           Resolution: expressing the gap as a percentage of pre-AI salary
--           levels the field and reveals where AI truly moved the needle most.
-- Heading : "Relative Gains — Which Country's Workers Felt AI the Most in Their Pay"
-- ============================================================

select country,
    round(avg(salary_before_usd), 2)                                   as avg_salary_before_usd,
    round(avg(salary_after_usd),  2)                                   as avg_salary_after_usd,
    round(avg(salary_gap_usd),    2)                                   as avg_dollar_change,
    round((avg(salary_gap_usd) / avg(salary_before_usd)) * 100, 2)    as avg_pct_change
from ai
group by country
order by avg_pct_change desc;


-- ============================================================
-- Q8 ----- Job Role Displacement Risk Ranking
-- ============================================================
-- Story   : Every job role holds a different position in the AI displacement
--           hierarchy. Conflict: average scores alone obscure which risk band
--           dominates a role — a role with a moderate average might still have
--           the majority of its workers in the Critical band.
--           Resolution: combining the mean replacement score with the dominant
--           band and its share gives a complete risk portrait for each role.
-- Heading : "Hierarchy of Threat — Ranking Every Job Role by AI Displacement Risk"
-- Best Solution: the dominant_band CTE isolates the modal risk band cleanly,
--               and RANK() OVER on the outer aggregation avoids a self-join.
-- ============================================================

with band_count as (
    select job_role, replacement_risk_band,
        count(*) as band_count,
        rank() over(partition by job_role order by count(*) desc) as band_rank
    from ai
    group by job_role, replacement_risk_band
),
dominent_band as (
    select job_role,
        replacement_risk_band as dominent_band,
        band_count
    from band_count
    where band_rank = 1
)
select rank() over(order by avg(a.ai_replacement_score) desc) as overall_rank,
    a.job_role,
    round(avg(a.ai_replacement_score), 2) as mean_replacement_score,
    d.dominent_band,
    d.band_count                          as dominent_band_count,
    count(*)                              as total_rocords,
    round((d.band_count / count(*)) * 100, 2) as dominant_band_pct
from ai as a
join dominent_band as d on d.job_role = a.job_role
group by a.job_role, d.dominent_band, d.band_count
order by mean_replacement_score desc;


-- ============================================================
-- Q9 ----- Salary Gap Extreme Records (MAX & MIN)
-- ============================================================
-- Story   : At the extremes of this dataset live two very different realities —
--           one worker whose salary soared by over $30,000 and another whose
--           fell by more than $21,000. Conflict: averages hide these outliers
--           completely, yet they represent the true ceiling and floor of AI's impact.
--           Resolution: pulling the exact MAX and MIN records with UNION ALL
--           puts a human face on the best and worst AI outcomes.
-- Heading : "Best Case, Worst Case — The Two Extreme Salary Stories in the Data"
-- ============================================================

SELECT
    job_role, industry, country, year,
    salary_before_usd, salary_after_usd,
    salary_gap_usd, salary_change_percent, ai_net_position
FROM ai
WHERE salary_gap_usd = (SELECT MAX(salary_gap_usd) FROM ai)
UNION ALL
SELECT
    job_role, industry, country, year,
    salary_before_usd, salary_after_usd,
    salary_gap_usd, salary_change_percent, ai_net_position
FROM ai
WHERE salary_gap_usd = (SELECT MIN(salary_gap_usd) FROM ai);


-- ============================================================
-- Q10 ----- AI Adoption vs Skill Demand Growth (Adoption Segments)
-- ============================================================
-- Story   : Companies sit at very different stages of their AI journey — from
--           those who have barely started to those running fully advanced systems.
--           Conflict: the assumption that more AI always means better outcomes for
--           workers is wrong; the Growing segment (25–50) actually produces net losses.
--           Resolution: segmenting by adoption depth reveals that only deep,
--           committed adoption consistently lifts worker salaries.
-- Heading : "Depth Over Dabbling — Why Half-Committed AI Adoption Hurts Workers Most"
-- ============================================================

select case
    when ai_adoption_level < 25               then '1 - Nascent (0-25)'
    when ai_adoption_level between 25 and 50  then '2 - Growing (25-50)'
    when ai_adoption_level between 50 and 75  then '3 - Established (50-75)'
    when ai_adoption_level between 75 and 100 then '4 - Advanced (75-100)'
end as ai_adoption_segment,
    count(*)                                                            as total_records,
    ROUND(SUM(CASE WHEN net_salary_outcome = 'Gainer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as gainer_pct_within_segment,
    ROUND(SUM(CASE WHEN net_salary_outcome = 'Loser'  THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as loser_pct_within_segment,
    round(avg(salary_gap_usd),              2) as avg_salary_gap,
    round(avg(skill_demand_growth_percent), 2) as avg_skill_demand_growth_pct,
    ROUND(AVG(ai_adoption_level),           2) AS avg_adoption_level,
    ROUND(AVG(automation_risk_percent),     2) AS avg_automation_risk,
    ROUND(AVG(salary_change_percent),       2) AS avg_salary_change_pct
from ai
group by ai_adoption_segment
order by ai_adoption_segment;


-- ============================================================
-- Q11 ----- Net Salary Outcome by Country
-- ============================================================
-- Story   : Every country produces both winners and losers from AI — the question
--           is which side is heavier. Conflict: a country can have large gross gains
--           and still be near-breakeven if its losses are equally large (see Australia).
--           Resolution: calculating the net monetary balance and ranking countries
--           by it separates genuine AI beneficiaries from those treading water.
-- Heading : "The National Balance Sheet — Net Monetary Winners and Losers of AI"
-- ============================================================

select country,
    sum(case when net_salary_outcome = 'Gainer' then salary_gap_usd end)         as Gainer_total_salary_gap,
    abs(sum(case when net_salary_outcome = 'Loser' then salary_gap_usd end))     as Loser_total_salary_gap,
    sum(case when net_salary_outcome = 'Gainer' then salary_gap_usd end) -
    abs(sum(case when net_salary_outcome = 'Loser' then salary_gap_usd end))     as Net_monetry,
    round(sum(case when net_salary_outcome = 'Gainer' then 1 else 0 end) * 100 / count(*), 2) as Gainer_pct,
    rank() over(order by
        sum(case when net_salary_outcome = 'Gainer' then salary_gap_usd end) -
        abs(sum(case when net_salary_outcome = 'Loser' then salary_gap_usd end)) desc
    ) as rank_country
from ai
group by country
order by rank_country asc;


-- ============================================================
-- Q12 ----- Automation Tier × Replacement Band Crosstab
-- ============================================================
-- Story   : High automation risk and high replacement risk tend to travel together —
--           but just how tightly? Conflict: looking at either metric alone misses
--           how they compound inside a single worker's situation.
--           Resolution: crossing the two dimensions in a crosstab shows the exact
--           concentration of Critical-band workers inside the High Automation Tier.
-- Heading : "Double Jeopardy — When High Automation Risk Meets High Replacement Risk"
-- ============================================================

select case
    when automation_risk_percent < 33               then 'Low Automation Tier'
    when automation_risk_percent between 33 and 66  then 'Medium Automation Tier'
    else                                                 'High Automation Tier'
end as segment_of_automation_risk,
    replacement_risk_band,
    count(*) as total_records,
    round((count(*) * 100 / sum(count(*)) over(partition by case
        when automation_risk_percent < 33              then 'Low Automation Tier'
        when automation_risk_percent between 33 and 66 then 'Medium Automation Tier'
        else                                                'High Automation Tier'
    end)), 2) as pct_within_automation_segment
from ai
group by segment_of_automation_risk, replacement_risk_band
order by segment_of_automation_risk;


-- ============================================================
-- Q13 ----- Automation Tier Salary & Replacement Summary
-- ============================================================
-- Story   : The three automation tiers tell three very different salary stories.
--           Conflict: grouping all workers together hides the fact that High-tier
--           workers lose 7.57% of salary on average while Low-tier workers gain.
--           Resolution: summarising salary change and replacement score by tier
--           draws the clearest possible line between safe and endangered roles.
-- Heading : "Three Worlds of Work — How Automation Tier Determines Your Pay Trajectory"
-- ============================================================

select case
    when automation_risk_percent < 33               then 'Low Automation Tier'
    when automation_risk_percent between 33 and 66  then 'Medium Automation Tier'
    else                                                 'High Automation Tier'
end as segment_of_automation_risk,
    round((count(*) / 15000) * 100,        2) as total_records,
    round(avg(salary_change_percent),      2) as mean_salary_change_percent,
    round(avg(ai_replacement_score),       2) as mean_ai_replacement_score
from ai
group by segment_of_automation_risk;


-- ============================================================
-- Q14 ----- AI Net Position — Industry Concentration
-- ============================================================
-- Story   : The same industry can contain workers being augmented by AI and workers
--           being displaced by it — sometimes in the same building. Conflict: industry-
--           level averages obscure the internal split between those benefiting and
--           those suffering.
--           Resolution: breaking out all four net positions per industry, with
--           conditional salary averages, exposes the hidden internal divide.
-- Heading : "Industry Divided — The Hidden Split Between Augmented and Displaced Workers"
-- ============================================================

SELECT
    industry,
    COUNT(*) AS total_records,
    ROUND(SUM(CASE WHEN ai_net_position = 'AI-Augmented'    THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ai_augmented_pct,
    ROUND(SUM(CASE WHEN ai_net_position = 'AI-Displaced'    THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ai_displaced_pct,
    ROUND(SUM(CASE WHEN ai_net_position = 'Emerging Demand' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS emerging_demand_pct,
    ROUND(SUM(CASE WHEN ai_net_position = 'Transitioning'   THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS transitioning_pct,
    ROUND(AVG(salary_gap_usd), 2) AS avg_salary_gap_usd,
    ROUND(AVG(CASE WHEN ai_net_position = 'AI-Displaced' THEN salary_gap_usd ELSE NULL END), 2) AS displaced_avg_gap_usd,
    ROUND(AVG(CASE WHEN ai_net_position = 'AI-Augmented' THEN salary_gap_usd ELSE NULL END), 2) AS augmented_avg_gap_usd,
    ROUND(AVG(automation_risk_percent), 2) AS avg_automation_risk,
    ROUND(AVG(ai_adoption_level),       2) AS avg_ai_adoption
FROM ai
GROUP BY industry
ORDER BY ai_displaced_pct DESC;


-- ============================================================
-- Q15 ----- Salary Gap Amplification with Dollar Impact (Salary Bands)
-- ============================================================
-- Story   : The size of your salary change is not random — it is tightly linked
--           to whether AI displaced you or augmented you. Conflict: workers in
--           the Severe Loss band are not just unlucky; 83% of them are AI-Displaced,
--           meaning the band is almost a perfect proxy for displacement.
--           Resolution: crossing salary bands with AI net position and flagging
--           the highest-displacement band makes the structural cause undeniable.
-- Heading : "Bands of Fate — How Salary Change Percentage Mirrors AI Displacement"
-- ============================================================

WITH salary_bands AS (
    SELECT
        job_role, industry, country, ai_net_position,
        salary_gap_usd, salary_change_percent,
        CASE
            WHEN salary_change_percent > 10                   THEN 'Strong Gain'
            WHEN salary_change_percent BETWEEN 1 AND 10       THEN 'Moderate Gain'
            WHEN salary_change_percent BETWEEN -1 AND 1       THEN 'Flat'
            WHEN salary_change_percent BETWEEN -10 AND -1     THEN 'Moderate Loss'
            ELSE                                                   'Severe Loss'
        END AS salary_band
    FROM ai
),
band_summary AS (
    SELECT
        salary_band,
        COUNT(*) AS total_records,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_share,
        ROUND(AVG(salary_gap_usd), 2) AS mean_salary_gap_usd,
        CASE
            WHEN SUM(CASE WHEN ai_net_position = 'AI-Displaced' THEN 1 ELSE 0 END)
              >= GREATEST(
                    SUM(CASE WHEN ai_net_position = 'AI-Augmented' THEN 1 ELSE 0 END),
                    SUM(CASE WHEN ai_net_position = 'Neutral'      THEN 1 ELSE 0 END)
                 ) THEN 'AI-Displaced'
            WHEN SUM(CASE WHEN ai_net_position = 'AI-Augmented' THEN 1 ELSE 0 END)
              >= SUM(CASE WHEN ai_net_position = 'Neutral' THEN 1 ELSE 0 END) THEN 'AI-Augmented'
            ELSE 'Neutral'
        END AS dominant_ai_net_position,
        ROUND(SUM(CASE WHEN ai_net_position = 'AI-Displaced' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ai_displaced_percentage
    FROM salary_bands
    GROUP BY salary_band
)
SELECT
    salary_band,
    total_records,
    percentage_share,
    mean_salary_gap_usd,
    dominant_ai_net_position,
    ai_displaced_percentage,
    CASE
        WHEN ai_displaced_percentage = (SELECT MAX(ai_displaced_percentage) FROM band_summary)
        THEN 'Highest AI-Displaced Concentration'
        ELSE ''
    END AS displacement_flag
FROM band_summary
ORDER BY
    CASE salary_band
        WHEN 'Strong Gain'   THEN 1
        WHEN 'Moderate Gain' THEN 2
        WHEN 'Flat'          THEN 3
        WHEN 'Moderate Loss' THEN 4
        WHEN 'Severe Loss'   THEN 5
    END;


-- ============================================================
-- Q16 ----- Education Level Risk & Salary Profiling
-- ============================================================
-- Story   : Education is supposed to protect workers from displacement — but the
--           data tells a more complicated story. Conflict: Level 4 (highest education)
--           still averages a salary loss, while Level 3 is the only group with a gain.
--           Resolution: profiling each education level with dominant risk band and
--           gainer rate shows that role alignment matters more than credentials alone.
-- Heading : "Credentials Are Not Enough — Why Education Level Alone Won't Save You"
-- ============================================================

WITH base_metrics AS (
    SELECT
        education_requirement_level,
        ROUND(AVG(automation_risk_percent), 2)  AS mean_automation_risk,
        ROUND(AVG(ai_replacement_score),    2)  AS mean_replacement_score,
        ROUND(AVG(salary_gap_usd),          2)  AS mean_salary_gap,
        COUNT(*)                                AS total_records,
        SUM(CASE WHEN net_salary_outcome = 'Gainer' THEN 1 ELSE 0 END) AS gainer_count,
        ROUND(SUM(CASE WHEN net_salary_outcome = 'Gainer' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS gainer_pct
    FROM ai
    GROUP BY education_requirement_level
),
band_counts AS (
    SELECT
        education_requirement_level,
        replacement_risk_band,
        COUNT(*) AS band_count
    FROM ai
    GROUP BY education_requirement_level, replacement_risk_band
),
band_ranked AS (
    SELECT
        education_requirement_level,
        replacement_risk_band,
        band_count,
        ROW_NUMBER() OVER (
            PARTITION BY education_requirement_level
            ORDER BY band_count DESC
        ) AS rn
    FROM band_counts
)
SELECT
    b.education_requirement_level,
    b.mean_automation_risk,
    b.mean_replacement_score,
    r.replacement_risk_band AS dominant_risk_band,
    r.band_count            AS dominant_band_count,
    b.gainer_pct,
    b.mean_salary_gap,
    b.total_records
FROM base_metrics  b
JOIN band_ranked   r
    ON  r.education_requirement_level = b.education_requirement_level
    AND r.rn = 1
ORDER BY b.education_requirement_level ASC;


-- ============================================================
-- Q17 ----- High-Risk Roles by Country (HAVING + RANK)
-- ============================================================
-- Story   : Within each country, certain role-combinations carry both high automation
--           exposure and negative salary outcomes — a dangerous combination. Conflict:
--           without a combined filter, high-automation roles with positive salaries
--           and low-automation roles with negative salaries would both appear,
--           diluting the insight.
--           Resolution: HAVING filters to only the truly at-risk combinations, and
--           RANK orders them by severity of salary loss.
-- Heading : "The Danger Zone — High Automation and Negative Pay in the Same Role"
-- ============================================================

select country,
    job_role,
    round(avg(automation_risk_percent), 2) as avg_automation_risk_percent,
    round(avg(salary_gap_usd),          2) as avg_salary_gap_usd,
    rank() over(order by avg(salary_gap_usd) asc) as rank_of_salary_gap
from ai
group by country, job_role
having avg(automation_risk_percent) > 60
   and avg(salary_gap_usd) < 0
order by rank_of_salary_gap;


-- ============================================================
-- Q18 ----- Automation Risk Trend — 2020 vs 2026 Signal
-- ============================================================
-- Story   : Six years is enough time to see whether an industry's automation risk
--           is genuinely rising or falling — and whether wages are moving in the
--           same or opposite direction. Conflict: looking at either year alone gives
--           a snapshot; only the comparison reveals the trajectory.
--           Resolution: pivoting 2020 and 2026 risk into columns, combining with
--           2026 salary, and applying a four-way signal CASE turns raw numbers
--           into actionable directional labels.
-- Heading : "Signal or Noise — Tracking Automation Risk Trajectory Across Six Years"
-- Best Solution: the three-CTE structure — risk per year, pivot to columns,
--               then join salary — keeps each concern separated and readable.
-- ============================================================

with automation_risk as (
    select industry, year,
        avg(automation_risk_percent) as mean_automation_risk
    from ai
    group by industry, year
),
automation_year as (
    select industry,
        round(avg(case when year = 2020 then mean_automation_risk end), 2) as risk_2020,
        round(avg(case when year = 2026 then mean_automation_risk end), 2) as risk_2026,
        round((avg(case when year = 2026 then mean_automation_risk end) -
               avg(case when year = 2020 then mean_automation_risk end)), 2) as automation_net_change
    from automation_risk
    group by industry
),
salary_gap as (
    select industry,
        round(avg(salary_gap_usd), 2) as mean_salary_gap_2026
    from ai
    where year = 2026
    group by industry
)
select y.industry,
    y.risk_2020,
    y.risk_2026,
    y.automation_net_change,
    g.mean_salary_gap_2026,
    case
        when y.automation_net_change > 0 and g.mean_salary_gap_2026 < 0 then 'Rising risk + wage loss'
        when y.automation_net_change > 0 and g.mean_salary_gap_2026 > 0 then 'Rising risk + wage gain'
        when y.automation_net_change < 0 and g.mean_salary_gap_2026 > 0 then 'Falling risk + wage gain'
        when y.automation_net_change < 0 and g.mean_salary_gap_2026 < 0 then 'Falling risk + wage loss'
    end as risk_wage_signal
from automation_year as y
join salary_gap      as g on y.industry = g.industry
order by y.automation_net_change desc;


-- ============================================================
-- Q19 ----- Post-AI Salary Ranking — RANK() Across Countries
-- ============================================================
-- Story   : In every country, one job role stands tall above all others in AI salary
--           gains — and one sits at the very bottom. Conflict: the same role can be
--           the top winner in one country and near the bottom in another, which raw
--           averages would never reveal.
--           Resolution: ranking roles within each country and filtering to only
--           the top and bottom exposes the universal winner and the consistent loser.
-- Heading : "Country Champions and Casualties — The Best and Worst AI Salary Roles Per Nation"
-- ============================================================

WITH role_country_agg AS (
    SELECT job_role, country,
        ROUND(AVG(salary_gap_usd), 2) AS mean_salary_gap,
        ROUND(SUM(CASE WHEN net_salary_outcome = 'Gainer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS gainer_pct,
        COUNT(*) AS total_records
    FROM ai
    GROUP BY job_role, country
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY country ORDER BY mean_salary_gap DESC) AS rnk
    FROM role_country_agg
),
max_ranks AS (
    SELECT country, MAX(rnk) AS max_rank
    FROM ranked
    GROUP BY country
),
extremes AS (
    SELECT r.*, m.max_rank,
        CASE
            WHEN r.rnk = 1           THEN 'AI Winner'
            WHEN r.rnk = m.max_rank  THEN 'AI Loser'
        END AS country_position
    FROM ranked r
    JOIN max_ranks m ON r.country = m.country
    WHERE r.rnk = 1 OR r.rnk = m.max_rank
)
SELECT
    country, country_position, job_role, rnk,
    mean_salary_gap, gainer_pct, total_records
FROM extremes
ORDER BY country, rnk;


-- ============================================================
-- Q20 ----- Peak Exposure Records — ROW_NUMBER()
-- ============================================================
-- Story   : For each job role, there exists one record that represents the absolute
--           peak of automation exposure — the highest-risk instance ever recorded.
--           Conflict: using MAX() alone cannot return the full row with all context
--           columns; it only returns the single value.
--           Resolution: ROW_NUMBER() partitioned by job role and ordered by
--           automation risk descending returns the full peak record cleanly, with
--           no ties and no duplicate rows.
-- Heading : "Maximum Exposure — One Record Per Role at the Peak of Automation Risk"
-- ============================================================

with job_rank as (
    select country, job_role, industry, year,
        automation_risk_percent, ai_replacement_score,
        replacement_risk_band, ai_net_position,
        row_number() over(
            partition by job_role
            order by automation_risk_percent desc
        ) as rn
    from ai
),
peak_records as (
    select * from job_rank where rn = 1
)
SELECT
    job_role, country, industry, year,
    automation_risk_percent, ai_replacement_score,
    replacement_risk_band, ai_net_position
FROM peak_records
ORDER BY automation_risk_percent DESC;


-- ============================================================
-- Q21 ----- Replacement Band Migration — LAG()
-- ============================================================
-- Story   : The size of each risk band is not fixed — it grows and shrinks from
--           year to year as economic conditions and AI adoption shift workers
--           between categories. Conflict: a static snapshot of band sizes says
--           nothing about the direction of travel.
--           Resolution: LAG() captures the previous year's count alongside the
--           current, and the delta plus trend label reveals whether each band is
--           growing or contracting.
-- Heading : "Rising or Falling — Year-on-Year Migration Across Replacement Risk Bands"
-- ============================================================

WITH band_year_counts AS (
    SELECT replacement_risk_band, year,
        COUNT(*) AS current_count
    FROM ai
    GROUP BY replacement_risk_band, year
),
band_lag AS (
    SELECT replacement_risk_band, year, current_count,
        LAG(current_count, 1) OVER (
            PARTITION BY replacement_risk_band
            ORDER BY year
        ) AS prior_count,
        current_count - LAG(current_count, 1) OVER (
            PARTITION BY replacement_risk_band
            ORDER BY year
        ) AS delta
    FROM band_year_counts
)
SELECT
    replacement_risk_band, year, current_count,
    prior_count, delta,
    CASE
        WHEN delta > 0 THEN 'Growing'
        WHEN delta < 0 THEN 'Shrinking'
        WHEN delta = 0 THEN 'Flat'
        ELSE                'Base Year'
    END AS trend_direction
FROM band_lag
ORDER BY replacement_risk_band, year;


-- ============================================================
-- Q22 ----- Skill Gap Amplification with Dollar Impact (Decile Analysis)
-- ============================================================
-- Story   : Among the most skill-gap-affected roles, does a larger skill gap
--           actually translate into a higher replacement score and a larger
--           salary loss? Conflict: a simple correlation would miss the non-linear
--           nature of the relationship across different bands and deciles.
--           Resolution: bucketing workers into ten skill-gap deciles and
--           calculating mean replacement score, dominant risk band, and mean
--           salary gap per decile exposes the exact shape of the relationship.
-- Heading : "The Skill Gap Penalty — How Widening Gaps Drive Replacement Risk and Wage Loss"
-- Best Solution: the five-CTE chain — top_roles → role_deciles → decile_aggregates
--               → dominant_band → final join — separates each logical step,
--               making it easy to debug or extend any single stage.
-- ============================================================

WITH top_roles AS (
    SELECT job_role
    FROM ai
    GROUP BY job_role
    ORDER BY AVG(skill_gap_index) DESC
    LIMIT 3
),
role_deciles AS (
    SELECT a.job_role,
        a.skill_gap_index, a.ai_replacement_score,
        a.replacement_risk_band, a.salary_gap_usd,
        CASE
            WHEN a.skill_gap_index <= 10 THEN '0-10'
            WHEN a.skill_gap_index <= 20 THEN '10-20'
            WHEN a.skill_gap_index <= 30 THEN '20-30'
            WHEN a.skill_gap_index <= 40 THEN '30-40'
            WHEN a.skill_gap_index <= 50 THEN '40-50'
            WHEN a.skill_gap_index <= 60 THEN '50-60'
            WHEN a.skill_gap_index <= 70 THEN '60-70'
            WHEN a.skill_gap_index <= 80 THEN '70-80'
            WHEN a.skill_gap_index <= 90 THEN '80-90'
            ELSE                              '90-100'
        END AS skill_gap_decile
    FROM ai a
    WHERE a.job_role IN (SELECT job_role FROM top_roles)
),
decile_aggregates AS (
    SELECT
        job_role, skill_gap_decile,
        ROUND(AVG(ai_replacement_score), 2) AS mean_ai_replacement_score,
        ROUND(AVG(salary_gap_usd),       2) AS mean_salary_gap_usd
    FROM role_deciles
    GROUP BY job_role, skill_gap_decile
),
dominant_band AS (
    SELECT
        job_role, skill_gap_decile, replacement_risk_band,
        COUNT(*) AS band_count,
        ROW_NUMBER() OVER (
            PARTITION BY job_role, skill_gap_decile
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM role_deciles
    GROUP BY job_role, skill_gap_decile, replacement_risk_band
)
SELECT
    da.job_role, da.skill_gap_decile,
    da.mean_ai_replacement_score,
    db.replacement_risk_band AS dominant_replacement_risk_band,
    da.mean_salary_gap_usd
FROM decile_aggregates da
JOIN dominant_band db
    ON  da.job_role         = db.job_role
    AND da.skill_gap_decile = db.skill_gap_decile
WHERE db.rn = 1
ORDER BY
    da.job_role,
    CASE da.skill_gap_decile
        WHEN '0-10'   THEN 1  WHEN '10-20' THEN 2  WHEN '20-30' THEN 3
        WHEN '30-40'  THEN 4  WHEN '40-50' THEN 5  WHEN '50-60' THEN 6
        WHEN '60-70'  THEN 7  WHEN '70-80' THEN 8  WHEN '80-90' THEN 9
        WHEN '90-100' THEN 10
    END;


-- ============================================================
-- Q23 ----- Cumulative Salary Gap Trajectory — Running SUM()
-- ============================================================
-- Story   : A single year's salary change is a data point; seven years of cumulative
--           change is a verdict. Conflict: some roles fluctuate year to year, making
--           it hard to judge their overall direction without a running total.
--           Resolution: ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW accumulates
--           every year's mean gap forward, and the Positive/Negative Territory label
--           turns the number into a clear directional judgement.
-- Heading : "Verdict Over Time — The Cumulative Salary Trajectory of Every Job Role"
-- Best Solution: splitting the logic into role_year_avg (mean per year) and
--               cumulative (running total) keeps the SUM() OVER frame clause
--               clean and the final CASE trivial to add.
-- ============================================================

WITH role_year_avg AS (
    SELECT job_role, year,
        ROUND(AVG(salary_gap_usd), 2) AS mean_salary_gap
    FROM ai
    GROUP BY job_role, year
),
cumulative AS (
    SELECT job_role, year, mean_salary_gap,
        ROUND(SUM(mean_salary_gap) OVER (
            PARTITION BY job_role
            ORDER BY year
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2) AS cumulative_salary_gap
    FROM role_year_avg
)
SELECT
    job_role, year, mean_salary_gap, cumulative_salary_gap,
    CASE
        WHEN cumulative_salary_gap > 0 THEN 'Positive Territory'
        WHEN cumulative_salary_gap < 0 THEN 'Negative Territory'
        ELSE                                'Breakeven'
    END AS cumulative_position
FROM cumulative
ORDER BY job_role, year;


-- ============================================================
-- Q24 ----- Avg Replacement Score & Skill Gap Index (2026 Only)
-- ============================================================
-- Story   : The most recent year of the dataset captures where each role truly
--           stands today. Conflict: multi-year averages dilute the current signal
--           by mixing in historical data from before AI adoption peaked.
--           Resolution: filtering to year = 2026 and ranking by replacement score
--           gives the clearest present-day risk portrait for every job role.
-- Heading : "The 2026 Snapshot — Current Replacement Risk and Skill Gaps by Role"
-- ============================================================

select job_role,
    round(avg(ai_replacement_score), 2) as avg_replacement_score,
    round(avg(skill_gap_index),      2) as avg_skill_gap_index
from ai
where year = 2026
group by job_role
order by avg_replacement_score desc;


-- ============================================================
-- Q25 ----- Job Role Displacement Risk Ranking — Version A
-- ============================================================
-- Story   : The average replacement score tells you how dangerous a role is;
--           the dominant band tells you what that danger looks like in practice.
--           Conflict: a role with a mean score of 75 could have its workers spread
--           evenly across bands, or almost entirely concentrated in Critical —
--           very different realities.
--           Resolution: joining the modal band back to the aggregated role data
--           adds the missing distributional context to the simple ranking.
-- Heading : "Beyond the Average — Dominant Risk Bands That Reveal the Real Story"
-- ============================================================

with band_count as (
    select job_role, replacement_risk_band,
        count(*) as band_count,
        rank() over(
            partition by job_role
            order by count(*) desc
        ) as band_rank
    from ai
    group by job_role, replacement_risk_band
),
dominent_band as (
    select job_role,
        replacement_risk_band as dominent_band,
        band_count
    from band_count
    where band_rank = 1
)
select rank() over(order by avg(a.ai_replacement_score) desc) as overall_rank,
    a.job_role,
    round(avg(a.ai_replacement_score), 2) as mean_replacement_score,
    d.dominent_band,
    d.band_count                          as dominent_band_count,
    count(*)                              as total_rocords,
    round((d.band_count / count(*)) * 100, 2) as dominant_band_pct
from ai as a
join dominent_band as d on d.job_role = a.job_role
group by a.job_role, d.dominent_band, d.band_count
order by mean_replacement_score desc;


-- ============================================================
-- Q26 ----- Job Role Displacement Risk Ranking — Version B (Refined)
-- ============================================================
-- Story   : The same analysis, rebuilt with cleaner CTE naming and 1 decimal
--           precision. Conflict: Version A used informal CTE names and 2 dp —
--           fine for exploration, but harder to read in a shared case study.
--           Resolution: renaming CTEs to band_counts / dominant_band and rounding
--           to 1 dp produces identical results with improved readability, showing
--           that good SQL is as much about clarity as correctness.
-- Heading : "Refined and Readable — Refactoring the Risk Ranking for Clarity"
-- ============================================================

WITH band_counts AS (
    SELECT
        job_role, replacement_risk_band,
        COUNT(*) AS band_count,
        RANK() OVER (
            PARTITION BY job_role
            ORDER BY COUNT(*) DESC
        ) AS band_rank
    FROM ai
    GROUP BY job_role, replacement_risk_band
),
dominant_band AS (
    SELECT job_role,
        replacement_risk_band AS dominant_band,
        band_count
    FROM band_counts
    WHERE band_rank = 1
)
SELECT
    RANK() OVER (ORDER BY AVG(a.ai_replacement_score) DESC) AS overall_rank,
    a.job_role,
    ROUND(AVG(a.ai_replacement_score), 2)  AS mean_replacement_score,
    d.dominant_band,
    d.band_count                           AS dominant_band_count,
    COUNT(*)                               AS total_records,
    ROUND(d.band_count / COUNT(*) * 100, 1) AS dominant_band_pct
FROM ai a
JOIN dominant_band d ON a.job_role = d.job_role
GROUP BY a.job_role, d.dominant_band, d.band_count
ORDER BY mean_replacement_score DESC;


-- ============================================================
--   END OF FILE
--   AI & The Future of Work — SQL Case Study
--   Total Queries : 26  |  Data Modeling + Q1 through Q26
-- ============================================================