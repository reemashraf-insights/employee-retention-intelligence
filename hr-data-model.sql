CREATE DATABASE HR;
USE HR;

--اتاكد ان البيانات دخلت صح 
SELECT COUNT(*)FROM [dbo].[IBM_HR_CLEANED]  as Total_Rows;


--تأكد من نوع كل عمود
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'IBM_HR_CLEANED';




-- DimAttrition: Dimension table listing distinct employee attrition values (Yes/No)
-- with a generated surrogate key (AttritionSK) used to link to the fact table
--DimAttrition 
CREATE VIEW dbo.DimAttrition AS
SELECT
    DENSE_RANK() OVER (ORDER BY Attrition) AS AttritionSK,
    Attrition
FROM (SELECT DISTINCT Attrition FROM [dbo].[IBM_HR_CLEANED]) t;
GO

SELECT * FROM dbo.DimAttrition;


-- DimEducation: Dimension table listing distinct combinations of education level and field
-- with a readable label (EducationLabel) and a surrogate key (EducationSK) for linking to the fact table
--DimEducation 
CREATE VIEW dbo.DimEducation AS
SELECT
    DENSE_RANK() OVER (ORDER BY Education, EducationField) AS EducationSK,
    Education,
    CASE Education
        WHEN 1 THEN 'Below College'
        WHEN 2 THEN 'College'
        WHEN 3 THEN 'Bachelor'
        WHEN 4 THEN 'Master'
        WHEN 5 THEN 'Doctor'
    END AS EducationLabel,
    EducationField
FROM (SELECT DISTINCT Education, EducationField FROM [dbo].[IBM_HR_CLEANED]) t;

SELECT * FROM dbo.DimEducation;



-- DimJob: Dimension table listing distinct combinations of job-related attributes 
--(Department, JobRole, JobLevel, BusinessTravel, OverTime, StockOptionLevel)

-- with readable labels for JobLevel and StockOptionLevel, 
--and a surrogate key (JobSK) for linking to the fact table
--DimJob
CREATE VIEW dbo.DimJob AS
SELECT
    DENSE_RANK() OVER (ORDER BY Department, JobRole, JobLevel, BusinessTravel, OverTime, StockOptionLevel) AS JobSK,
    Department,
    JobRole,
    JobLevel,
    CASE JobLevel
        WHEN 1 THEN 'Entry'
        WHEN 2 THEN 'Junior'
        WHEN 3 THEN 'Mid'
        WHEN 4 THEN 'Senior'
        WHEN 5 THEN 'Executive'
    END AS JobLevelLabel,
    BusinessTravel,
    OverTime,
    StockOptionLevel,
    CASE StockOptionLevel
        WHEN 0 THEN 'No Stock Options'
        WHEN 1 THEN 'Level 1'
        WHEN 2 THEN 'Level 2'
        WHEN 3 THEN 'Level 3'
    END AS StockOptionLevelLabel
FROM (
    SELECT DISTINCT Department, JobRole, JobLevel, BusinessTravel, OverTime, StockOptionLevel
    FROM [dbo].[IBM_HR_CLEANED]
) t;

SELECT * FROM dbo.DimJob;


-- DimSource: Dimension table listing distinct employee recruitment sources (EmployeeSource)
-- with a generated surrogate key (SourceSK) used to link to the fact table
--DimSource
CREATE VIEW dbo.DimSource AS
SELECT 
    DENSE_RANK() OVER (ORDER BY [Employee_Source]) AS SourceSK,
    [Employee_Source] AS EmployeeSource
FROM (SELECT DISTINCT [Employee_Source] FROM [dbo].[IBM_HR_CLEANED]) t;

SELECT * FROM dbo.DimSource;





-- DimSatisfaction: Dimension table listing distinct combinations of employee satisfaction and performance metrics (EnvironmentSatisfaction,
--JobSatisfaction, RelationshipSatisfaction, WorkLifeBalance, JobInvolvement, PerformanceRating)


-- with readable labels for each metric, and a surrogate key (SatisfactionSK) for linking to the fact table
--DimSatisfaction
CREATE VIEW dbo.DimSatisfaction AS
SELECT
    DENSE_RANK() OVER (ORDER BY EnvironmentSatisfaction, JobSatisfaction, RelationshipSatisfaction,
                                 WorkLifeBalance, JobInvolvement, PerformanceRating) AS SatisfactionSK,
    EnvironmentSatisfaction,
    CASE EnvironmentSatisfaction WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High' WHEN 4 THEN 'Very High' END AS EnvironmentSatisfactionLabel,
    JobSatisfaction,
    CASE JobSatisfaction WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High' WHEN 4 THEN 'Very High' END AS JobSatisfactionLabel,
    RelationshipSatisfaction,
    CASE RelationshipSatisfaction WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High' WHEN 4 THEN 'Very High' END AS RelationshipSatisfactionLabel,
    WorkLifeBalance,
    CASE WorkLifeBalance WHEN 1 THEN 'Bad' WHEN 2 THEN 'Good' WHEN 3 THEN 'Better' WHEN 4 THEN 'Best' END AS WorkLifeBalanceLabel,
    JobInvolvement,
    CASE JobInvolvement WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High' WHEN 4 THEN 'Very High' END AS JobInvolvementLabel,
    PerformanceRating,
    CASE PerformanceRating WHEN 1 THEN 'Low' WHEN 2 THEN 'Good' WHEN 3 THEN 'Excellent' WHEN 4 THEN 'Outstanding' END AS PerformanceRatingLabel
FROM (
    SELECT DISTINCT EnvironmentSatisfaction, JobSatisfaction, RelationshipSatisfaction,
                     WorkLifeBalance, JobInvolvement, PerformanceRating
    FROM dbo.IBM_HR_CLEANED
) t;


SELECT * FROM dbo.DimSatisfaction;



-- DimDemographics: Dimension table listing distinct combinations of 
--employee demographic attributes (Age, Gender, MaritalStatus, DistanceFromHome)

-- with a generated surrogate key (DemographicSK) used to link to the fact table
--DimDemographics
CREATE VIEW dbo.DimDemographics AS
SELECT
    DENSE_RANK() OVER (ORDER BY Age, Gender, MaritalStatus, DistanceFromHome) AS DemographicSK,
    Age,
    Gender,
    MaritalStatus,
    DistanceFromHome
FROM (
    SELECT DISTINCT Age, Gender, MaritalStatus, DistanceFromHome
    FROM dbo.IBM_HR_CLEANED
) t;



SELECT * FROM dbo.DimDemographics;



-- FactHR: Fact table containing employee-level measures (salary, tenure, promotions, etc.)

-- linked to all dimension tables (Education, Job, Attrition, Source, Satisfaction, Demographics)
--via their surrogate keys, forming the star schema for HR analysis
--FactHR
CREATE VIEW dbo.FactHR AS
SELECT
    r.EmployeeNumber,
    r.[Application_ID] AS ApplicationID,
    e.EducationSK,
    j.JobSK,
    a.AttritionSK,
    s.SourceSK,
    sat.SatisfactionSK,
    d.DemographicSK,
    r.DailyRate,
    r.HourlyRate,
    r.MonthlyIncome,
    r.MonthlyRate,
    r.PercentSalaryHike,
    r.NumCompaniesWorked,
    r.TotalWorkingYears,
    r.TrainingTimesLastYear,
    r.YearsAtCompany,
    r.YearsInCurrentRole,
    r.YearsSinceLastPromotion,
    r.YearsWithCurrManager
FROM dbo.IBM_HR_CLEANED r
JOIN dbo.DimEducation e 
    ON r.Education = e.Education AND r.EducationField = e.EducationField
JOIN dbo.DimJob j 
    ON r.Department = j.Department AND r.JobRole = j.JobRole AND r.JobLevel = j.JobLevel
   AND r.BusinessTravel = j.BusinessTravel AND r.OverTime = j.OverTime AND r.StockOptionLevel = j.StockOptionLevel
JOIN dbo.DimAttrition a 
    ON r.Attrition = a.Attrition
JOIN dbo.DimSource s 
    ON r.[Employee_Source] = s.EmployeeSource
JOIN dbo.DimSatisfaction sat 
    ON r.EnvironmentSatisfaction = sat.EnvironmentSatisfaction AND r.JobSatisfaction = sat.JobSatisfaction
   AND r.RelationshipSatisfaction = sat.RelationshipSatisfaction AND r.WorkLifeBalance = sat.WorkLifeBalance
   AND r.JobInvolvement = sat.JobInvolvement AND r.PerformanceRating = sat.PerformanceRating
JOIN dbo.DimDemographics d 
    ON r.Age = d.Age AND r.Gender = d.Gender AND r.MaritalStatus = d.MaritalStatus AND r.DistanceFromHome = d.DistanceFromHome;

SELECT * FROM dbo.FactHR;


--Check
SELECT COUNT(*) AS Original_Count FROM dbo.IBM_HR_CLEANED;
SELECT COUNT(*) AS Fact_Count FROM dbo.FactHR;




USE HR;
GO

/* ==========================================================
   كويريز تحليلية على HR Star Schema
   تعتمد على: FactHR, DimAttrition, DimEducation, DimJob,
              DimSource, DimSatisfaction, DimDemographics
   ========================================================== */


-- 1) نسبة ترك العمل (Attrition Rate) الإجمالية
SELECT
    a.Attrition,
    COUNT(*) AS EmployeeCount,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS Percentage
FROM dbo.FactHR f
JOIN dbo.DimAttrition a ON f.AttritionSK = a.AttritionSK
GROUP BY a.Attrition;


-- 2) نسبة ترك العمل حسب القسم (Department)
SELECT
    j.Department,
    a.Attrition,
    COUNT(*) AS EmployeeCount,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY j.Department) AS DECIMAL(5,2)) AS PctWithinDept
FROM dbo.FactHR f
JOIN dbo.DimJob j ON f.JobSK = j.JobSK
JOIN dbo.DimAttrition a ON f.AttritionSK = a.AttritionSK
GROUP BY j.Department, a.Attrition
ORDER BY j.Department, a.Attrition;


-- 3) نسبة ترك العمل حسب JobRole (مرتبة تنازليًا لأعلى نسبة ترك)
SELECT
    j.JobRole,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) AS Leavers,
    CAST(SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
FROM dbo.FactHR f
JOIN dbo.DimJob j ON f.JobSK = j.JobSK
JOIN dbo.DimAttrition a ON f.AttritionSK = a.AttritionSK
GROUP BY j.JobRole
ORDER BY AttritionRatePct DESC;


-- 4) تأثير العمل الإضافي (OverTime) على ترك العمل
SELECT
    j.OverTime,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) AS Leavers,
    CAST(SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
FROM dbo.FactHR f
JOIN dbo.DimJob j ON f.JobSK = j.JobSK
JOIN dbo.DimAttrition a ON f.AttritionSK = a.AttritionSK
GROUP BY j.OverTime;


-- 5) متوسط الدخل الشهري حسب الإدارة والمستوى الوظيفي
SELECT
    j.Department,
    j.JobLevelLabel,
    COUNT(*) AS EmployeeCount,
    CAST(AVG(f.MonthlyIncome) AS DECIMAL(10,2)) AS AvgMonthlyIncome
FROM dbo.FactHR f
JOIN dbo.DimJob j ON f.JobSK = j.JobSK
GROUP BY j.Department, j.JobLevelLabel
ORDER BY j.Department, j.JobLevelLabel;


-- 6) هل الرضا الوظيفي المنخفض مرتبط بترك العمل؟
SELECT
    sat.JobSatisfactionLabel,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) AS Leavers,
    CAST(SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
FROM dbo.FactHR f
JOIN dbo.DimSatisfaction sat ON f.SatisfactionSK = sat.SatisfactionSK
JOIN dbo.DimAttrition a ON f.AttritionSK = a.AttritionSK
GROUP BY sat.JobSatisfactionLabel
ORDER BY AttritionRatePct DESC;


-- 7) تأثير التوازن بين العمل والحياة (WorkLifeBalance) على ترك العمل
SELECT
    sat.WorkLifeBalanceLabel,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) AS Leavers,
    CAST(SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
FROM dbo.FactHR f
JOIN dbo.DimSatisfaction sat ON f.SatisfactionSK = sat.SatisfactionSK
JOIN dbo.DimAttrition a ON f.AttritionSK = a.AttritionSK
GROUP BY sat.WorkLifeBalanceLabel
ORDER BY AttritionRatePct DESC;


-- 8) متوسط سنوات الخبرة والترقية الأخيرة لكل من ترك العمل مقابل من بقي
SELECT
    a.Attrition,
    COUNT(*) AS EmployeeCount,
    CAST(AVG(f.TotalWorkingYears) AS DECIMAL(5,2)) AS AvgTotalWorkingYears,
    CAST(AVG(f.YearsAtCompany) AS DECIMAL(5,2)) AS AvgYearsAtCompany,
    CAST(AVG(f.YearsSinceLastPromotion) AS DECIMAL(5,2)) AS AvgYearsSinceLastPromotion
FROM dbo.FactHR f
JOIN dbo.DimAttrition a ON f.AttritionSK = a.AttritionSK
GROUP BY a.Attrition;


-- 9) تأثير المسافة من السكن للعمل (DistanceFromHome) على ترك العمل
SELECT
    CASE
        WHEN d.DistanceFromHome <= 5 THEN '0-5'
        WHEN d.DistanceFromHome <= 10 THEN '6-10'
        WHEN d.DistanceFromHome <= 20 THEN '11-20'
        ELSE '20+'
    END AS DistanceBucket,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) AS Leavers,
    CAST(SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
FROM dbo.FactHR f
JOIN dbo.DimDemographics d ON f.DemographicSK = d.DemographicSK
JOIN dbo.DimAttrition a ON f.AttritionSK = a.AttritionSK
GROUP BY CASE
        WHEN d.DistanceFromHome <= 5 THEN '0-5'
        WHEN d.DistanceFromHome <= 10 THEN '6-10'
        WHEN d.DistanceFromHome <= 20 THEN '11-20'
        ELSE '20+'
    END
ORDER BY DistanceBucket;


-- 10) أفضل/أسوأ مصادر التوظيف من حيث نسبة بقاء الموظفين
SELECT
    s.EmployeeSource,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) AS Leavers,
    CAST(SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
FROM dbo.FactHR f
JOIN dbo.DimSource s ON f.SourceSK = s.SourceSK
JOIN dbo.DimAttrition a ON f.AttritionSK = a.AttritionSK
GROUP BY s.EmployeeSource
ORDER BY AttritionRatePct DESC;


-- 11) توزيع الموظفين حسب الفئة العمرية والحالة الاجتماعية
SELECT
    CASE
        WHEN d.Age < 25 THEN 'Under 25'
        WHEN d.Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN d.Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN d.Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS AgeGroup,
    d.MaritalStatus,
    COUNT(*) AS EmployeeCount
FROM dbo.FactHR f
JOIN dbo.DimDemographics d ON f.DemographicSK = d.DemographicSK
GROUP BY
    CASE
        WHEN d.Age < 25 THEN 'Under 25'
        WHEN d.Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN d.Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN d.Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END,
    d.MaritalStatus
ORDER BY AgeGroup, d.MaritalStatus;


-- 12) مستوى التعليم مقابل متوسط الدخل الشهري
SELECT
    e.EducationLabel,
    e.EducationField,
    COUNT(*) AS EmployeeCount,
    CAST(AVG(f.MonthlyIncome) AS DECIMAL(10,2)) AS AvgMonthlyIncome
FROM dbo.FactHR f
JOIN dbo.DimEducation e ON f.EducationSK = e.EducationSK
GROUP BY e.EducationLabel, e.EducationField
ORDER BY AvgMonthlyIncome DESC;


-- 13) تأثير خيارات الأسهم (StockOptionLevel) على ترك العمل
SELECT
    j.StockOptionLevelLabel,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) AS Leavers,
    CAST(SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
FROM dbo.FactHR f
JOIN dbo.DimJob j ON f.JobSK = j.JobSK
JOIN dbo.DimAttrition a ON f.AttritionSK = a.AttritionSK
GROUP BY j.StockOptionLevelLabel
ORDER BY AttritionRatePct DESC;


-- 14) هل السفر الكثير في العمل (BusinessTravel) بيزود نسبة ترك العمل؟
SELECT
    j.BusinessTravel,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) AS Leavers,
    CAST(SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
FROM dbo.FactHR f
JOIN dbo.DimJob j ON f.JobSK = j.JobSK
JOIN dbo.DimAttrition a ON f.AttritionSK = a.AttritionSK
GROUP BY j.BusinessTravel
ORDER BY AttritionRatePct DESC;


-- 15) أكثر 10 موظفين مضى عليهم وقت طويل بدون ترقية (مرشحين لمراجعة الأداء/الاحتفاظ بهم)
SELECT TOP 10
    f.EmployeeNumber,
    j.Department,
    j.JobRole,
    f.YearsAtCompany,
    f.YearsSinceLastPromotion,
    f.MonthlyIncome
FROM dbo.FactHR f
JOIN dbo.DimJob j ON f.JobSK = j.JobSK
ORDER BY f.YearsSinceLastPromotion DESC;