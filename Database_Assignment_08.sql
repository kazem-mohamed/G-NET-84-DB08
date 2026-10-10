USE Hospital;
GO

-- ============================================================
-- Database Assignment 08 - Indexes
-- Questions 1 to 14 (all questions in the assignment)
-- Database: Hospital (restore Hospital (1).bak before running)
-- ============================================================

-- ============================================================
-- Q1. Create a clustered index on PatientIndexDemo.PatientId
-- ============================================================
DROP TABLE IF EXISTS dbo.PatientIndexDemo;

SELECT Id AS PatientId,
       Name AS PatientName,
       DOB,
       WardId
INTO dbo.PatientIndexDemo
FROM dbo.Patients;

CREATE CLUSTERED INDEX CIX_PatientIndexDemo_PatientId
ON dbo.PatientIndexDemo (PatientId);
GO

-- ============================================================
-- Q2. Create a clustered index on ConsultantIndexDemo.ConsultantId
-- ============================================================
DROP TABLE IF EXISTS dbo.ConsultantIndexDemo;

SELECT Id AS ConsultantId,
       Name AS ConsultantName,
       Salary
INTO dbo.ConsultantIndexDemo
FROM dbo.Consultants;

CREATE CLUSTERED INDEX CIX_ConsultantIndexDemo_ConsultantId
ON dbo.ConsultantIndexDemo (ConsultantId);
GO

-- ============================================================
-- Q3. Index Patients by Ward
-- ============================================================
DROP INDEX IF EXISTS IX_Patients_WardId ON dbo.Patients;

CREATE NONCLUSTERED INDEX IX_Patients_WardId
ON dbo.Patients (WardId);
GO

-- ============================================================
-- Q4. Index Consultants by Salary
-- ============================================================
DROP INDEX IF EXISTS IX_Consultants_Salary ON dbo.Consultants;

CREATE NONCLUSTERED INDEX IX_Consultants_Salary
ON dbo.Consultants (Salary);
GO

-- ============================================================
-- Q5. Composite nonclustered index on DrugAdministrations
-- ============================================================
DROP INDEX IF EXISTS IX_DrugAdministrations_PatientId_DrugCode
ON dbo.DrugAdministrations;

CREATE NONCLUSTERED INDEX IX_DrugAdministrations_PatientId_DrugCode
ON dbo.DrugAdministrations (PatientId, DrugCode);
GO

-- ============================================================
-- Q6. Nonclustered index on WardId including Name and DOB
-- ============================================================
DROP INDEX IF EXISTS IX_Patients_WardId_Include_Name_DOB ON dbo.Patients;

CREATE NONCLUSTERED INDEX IX_Patients_WardId_Include_Name_DOB
ON dbo.Patients (WardId)
INCLUDE (Name, DOB);
GO

-- ============================================================
-- Q7. Unique consultant names
-- ============================================================
DROP INDEX IF EXISTS UX_Consultants_Name ON dbo.Consultants;

CREATE UNIQUE NONCLUSTERED INDEX UX_Consultants_Name
ON dbo.Consultants (Name);
GO

-- ============================================================
-- Q8. Composite unique index on PatientDrugAssignmentDemo
-- ============================================================
DROP TABLE IF EXISTS dbo.PatientDrugAssignmentDemo;

CREATE TABLE dbo.PatientDrugAssignmentDemo
(
    PatientId INT NOT NULL,
    DrugCode INT NOT NULL,
    StartDate DATE NOT NULL
);

CREATE UNIQUE NONCLUSTERED INDEX UX_PatientDrugAssignmentDemo_PatientId_DrugCode
ON dbo.PatientDrugAssignmentDemo (PatientId, DrugCode);
GO

-- ============================================================
-- Q9. Test the unique composite index
-- The failed duplicate insert is handled so the script continues.
-- ============================================================
DECLARE @DemoPatientId INT =
(
    SELECT TOP (1) Id
    FROM dbo.Patients
    ORDER BY Id
);

DECLARE @DemoDrugCode INT =
(
    SELECT TOP (1) Code
    FROM dbo.Drugs
    ORDER BY Code
);

IF @DemoPatientId IS NOT NULL AND @DemoDrugCode IS NOT NULL
BEGIN
    INSERT INTO dbo.PatientDrugAssignmentDemo (PatientId, DrugCode, StartDate)
    VALUES (@DemoPatientId, @DemoDrugCode, CAST(GETDATE() AS DATE));

    BEGIN TRY
        INSERT INTO dbo.PatientDrugAssignmentDemo (PatientId, DrugCode, StartDate)
        VALUES (@DemoPatientId, @DemoDrugCode, DATEADD(DAY, 1, CAST(GETDATE() AS DATE)));
    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS ErrorNumber,
               ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
ELSE
    PRINT 'Question 9 skipped: Patients or Drugs has no row available for the test.';
GO

-- ============================================================
-- Q10. Display indexes defined on Patients
-- ============================================================
SELECT i.name AS IndexName,
       i.type_desc AS IndexType,
       i.is_unique AS IsUnique,
       i.is_primary_key AS IsPrimaryKey
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID(N'dbo.Patients')
  AND i.index_id > 0
ORDER BY i.index_id;
GO

-- ============================================================
-- Q11. Display all Hospital table indexes from system catalogs
-- ============================================================
SELECT SCHEMA_NAME(t.schema_id) AS SchemaName,
       t.name AS TableName,
       i.name AS IndexName,
       i.type_desc AS IndexType
FROM sys.indexes AS i
INNER JOIN sys.tables AS t ON t.object_id = i.object_id
WHERE i.index_id > 0
ORDER BY SchemaName, TableName, IndexName;
GO

-- ============================================================
-- Q12. Drop the nonclustered index created in Question 4
-- ============================================================
DROP INDEX IF EXISTS IX_Consultants_Salary ON dbo.Consultants;
GO

-- ============================================================
-- Q13. Index patient searches by WardId and DOB
-- ============================================================
DROP INDEX IF EXISTS IX_Patients_WardId_DOB ON dbo.Patients;

CREATE NONCLUSTERED INDEX IX_Patients_WardId_DOB
ON dbo.Patients (WardId, DOB);
GO

-- ============================================================
-- Q14. Reporting index for medication administrations
-- ============================================================
DROP INDEX IF EXISTS IX_DrugAdministrations_PatientId_Date_Reporting
ON dbo.DrugAdministrations;

CREATE NONCLUSTERED INDEX IX_DrugAdministrations_PatientId_Date_Reporting
ON dbo.DrugAdministrations (PatientId, [DATE])
INCLUDE (DrugCode, Dosage, Quantity);
GO
