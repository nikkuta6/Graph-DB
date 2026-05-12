/*
Created: 10.05.2026
Modified: 11.05.2026
Model: ProjectManagementGraphDB
Database: MS SQL Server 2019
*/
USE [master];
GO

IF DB_ID(N'ProjectManagementGraphDB') IS NOT NULL
BEGIN
    ALTER DATABASE [ProjectManagementGraphDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [ProjectManagementGraphDB];
END
GO

CREATE DATABASE [ProjectManagementGraphDB];
GO

USE [ProjectManagementGraphDB];
GO


-- Create tables section -------------------------------------------------

-- Table Executor

CREATE TABLE [Executor]
(
 [ExecutorID] Int NOT NULL,
 [FullName] Nvarchar(100) NOT NULL,
 [RoleName] Nvarchar(50) NOT NULL,
 [Grade] Nvarchar(20) NOT NULL,
 [Email] Nvarchar(100) NOT NULL,
  CONSTRAINT [CK_Executor_Grade] CHECK (Grade IN (N'Junior', N'Middle', N'Senior', N'Lead'))
)
AS NODE
go

-- Add keys for table Executor

ALTER TABLE [Executor] ADD CONSTRAINT [PK_Executor] PRIMARY KEY ([ExecutorID])
go

ALTER TABLE [Executor] ADD CONSTRAINT [UQ_Executor_Email] UNIQUE ([Email])
go

-- Table ProjectTask

CREATE TABLE [ProjectTask]
(
 [TaskID] Int NOT NULL,
 [TaskCode] Nvarchar(20) NOT NULL,
 [Title] Nvarchar(200) NOT NULL,
 [TaskType] Nvarchar(30) NOT NULL,
 [TaskStatus] Nvarchar(30) NOT NULL,
 [Priority] Nvarchar(20) NOT NULL,
 [EstimateHours] Int NOT NULL,
 [CreatedAt] Date NOT NULL,
  CONSTRAINT [CK_ProjectTask_TaskType] CHECK (TaskType IN (N'Feature', N'Bugfix', N'DevOps', N'Research', N'Refactoring', N'UI')),
  CONSTRAINT [CK_ProjectTask_TaskStatus] CHECK (TaskStatus IN (N'Backlog', N'InProgress', N'Done', N'Blocked')),
  CONSTRAINT [CK_ProjectTask_Priority] CHECK (Priority IN (N'Low', N'Medium', N'High', N'Critical')),
  CONSTRAINT [CK_ProjectTask_EstimateHours] CHECK (EstimateHours > 0)
)
AS NODE
go

-- Add keys for table ProjectTask

ALTER TABLE [ProjectTask] ADD CONSTRAINT [PK_ProjectTask] PRIMARY KEY ([TaskID])
go

ALTER TABLE [ProjectTask] ADD CONSTRAINT [UQ_ProjectTask_TaskCode] UNIQUE ([TaskCode])
go

-- Table Bug

CREATE TABLE [Bug]
(
 [BugID] Int NOT NULL,
 [BugCode] Nvarchar(20) NOT NULL,
 [Title] Nvarchar(200) NOT NULL,
 [Severity] Nvarchar(20) NOT NULL,
 [BugStatus] Nvarchar(30) NOT NULL,
 [Environment] Nvarchar(50) NOT NULL,
 [CreatedAt] Date NOT NULL,
  CONSTRAINT [CK_Bug_Severity] CHECK (Severity IN (N'Minor', N'Major', N'Critical', N'Blocker')),
  CONSTRAINT [CK_Bug_BugStatus] CHECK (BugStatus IN (N'Open', N'InProgress', N'Resolved', N'Closed'))
)
AS NODE
go

-- Add keys for table Bug

ALTER TABLE [Bug] ADD CONSTRAINT [PK_Bug] PRIMARY KEY ([BugID])
go

ALTER TABLE [Bug] ADD CONSTRAINT [UQ_Bug_BugCode] UNIQUE ([BugCode])
go

-- Table AssignedTo

CREATE TABLE [AssignedTo]
(
 [AssignedAt] Date NOT NULL,
 [AssignmentStatus] Nvarchar(30) NOT NULL,
 [WorkloadPercent] Int NOT NULL,
  CONSTRAINT [CK_AssignedTo_AssignmentStatus] CHECK (AssignmentStatus IN (N'Active', N'Paused', N'Finished')),
  CONSTRAINT [CK_AssignedTo_WorkloadPercent] CHECK (WorkloadPercent BETWEEN 1 AND 100)
)
AS EDGE
go

-- Table Reported

CREATE TABLE [Reported]
(
 [ReportedAt] Date NOT NULL,
 [ReportChannel] Nvarchar(30) NOT NULL,
 [ReportPriority] Nvarchar(20) NOT NULL,
  CONSTRAINT [CK_Reported_ReportChannel] CHECK (ReportChannel IN (N'Jira', N'TestRail', N'Email', N'Meeting')),
  CONSTRAINT [CK_Reported_ReportPriority] CHECK (ReportPriority IN (N'Low', N'Medium', N'High', N'Critical'))
)
AS EDGE
go

-- Table BugBlocksTask

CREATE TABLE [BugBlocksTask]
(
 [BlockedFrom] Date NOT NULL,
 [BlockStatus] Nvarchar(30) NOT NULL,
 [BlockWeight] Int NOT NULL,
  CONSTRAINT [CK_BugBlocksTask_BlockWeight] CHECK (BlockWeight BETWEEN 1 AND 10),
  CONSTRAINT [CK_BugBlocksTask_BlockStatus] CHECK (BlockStatus IN (N'Active', N'Resolved'))
)
AS EDGE
go

-- Table TaskBlocksTask

CREATE TABLE [TaskBlocksTask]
(
 [BlockedFrom] Date NOT NULL,
 [Reason] Nvarchar(200) NOT NULL,
 [BlockStatus] Nvarchar(30) NOT NULL,
  CONSTRAINT [CK_TaskBlocksTask_BlockStatus] CHECK (BlockStatus IN (N'Active', N'Resolved'))
)
AS EDGE
go





USE [ProjectManagementGraphDB];
GO


/* 
   CONNECTION CONSTRAINT:
   ограничиваем, какие узлы может соединять каждое ребро.
*/

ALTER TABLE [AssignedTo]
ADD CONSTRAINT [EC_AssignedTo]
CONNECTION ([dbo].[ProjectTask] TO [dbo].[Executor]);
GO

ALTER TABLE [Reported]
ADD CONSTRAINT [EC_Reported]
CONNECTION ([dbo].[Executor] TO [dbo].[Bug]);
GO

ALTER TABLE [BugBlocksTask]
ADD CONSTRAINT [EC_BugBlocksTask]
CONNECTION ([dbo].[Bug] TO [dbo].[ProjectTask]);
GO

ALTER TABLE [TaskBlocksTask]
ADD CONSTRAINT [EC_TaskBlocksTask]
CONNECTION ([dbo].[ProjectTask] TO [dbo].[ProjectTask]);
GO


/* 
   Заполнение таблиц узлов.
   По заданию: для каждой таблицы узлов не менее 10 строк.
*/

INSERT INTO [Executor]
    ([ExecutorID], [FullName], [RoleName], [Grade], [Email])
VALUES
    (1,  N'Иван Петров',       N'Backend Developer',  N'Middle', N'ivan.petrov@company.local'),
    (2,  N'Анна Смирнова',     N'Frontend Developer', N'Junior', N'anna.smirnova@company.local'),
    (3,  N'Олег Кузнецов',     N'QA Engineer',        N'Middle', N'oleg.kuznetsov@company.local'),
    (4,  N'Мария Иванова',     N'Project Manager',    N'Lead',   N'maria.ivanova@company.local'),
    (5,  N'Дмитрий Соколов',   N'DevOps Engineer',    N'Middle', N'dmitry.sokolov@company.local'),
    (6,  N'Елена Морозова',    N'UI/UX Designer',     N'Senior', N'elena.morozova@company.local'),
    (7,  N'Павел Волков',      N'Backend Developer',  N'Senior', N'pavel.volkov@company.local'),
    (8,  N'Юлия Алексеева',    N'QA Engineer',        N'Junior', N'yulia.alekseeva@company.local'),
    (9,  N'Сергей Новиков',    N'Business Analyst',   N'Middle', N'sergey.novikov@company.local'),
    (10, N'Никита Орлов',      N'Frontend Developer', N'Middle', N'nikita.orlov@company.local');
GO


INSERT INTO [ProjectTask]
    ([TaskID], [TaskCode], [Title], [TaskType], [TaskStatus], [Priority], [EstimateHours], [CreatedAt])
VALUES
    (1,  N'TASK-101', N'Реализовать авторизацию пользователя',       N'Feature',     N'InProgress', N'High',     16, '2025-09-01'),
    (2,  N'TASK-102', N'Реализовать регистрацию пользователя',       N'Feature',     N'Done',       N'Medium',   12, '2025-09-02'),
    (3,  N'TASK-103', N'Разработать REST API для задач',             N'Feature',     N'InProgress', N'High',     24, '2025-09-03'),
    (4,  N'TASK-104', N'Сделать Kanban-доску',                       N'UI',          N'Backlog',    N'Medium',   20, '2025-09-04'),
    (5,  N'TASK-105', N'Добавить уведомления о дедлайнах',           N'Feature',     N'Blocked',    N'High',     14, '2025-09-05'),
    (6,  N'TASK-106', N'Реализовать экспорт отчётов',                N'Feature',     N'Blocked',    N'Medium',   18, '2025-09-06'),
    (7,  N'TASK-107', N'Настроить CI/CD pipeline',                   N'DevOps',      N'InProgress', N'Critical', 10, '2025-09-07'),
    (8,  N'TASK-108', N'Сверстать страницу профиля',                 N'UI',          N'Done',       N'Low',       8, '2025-09-08'),
    (9,  N'TASK-109', N'Добавить поиск по задачам',                  N'Feature',     N'InProgress', N'Medium',   15, '2025-09-09'),
    (10, N'TASK-110', N'Провести рефакторинг модуля проектов',       N'Refactoring', N'Backlog',    N'Low',      22, '2025-09-10');
GO


INSERT INTO [Bug]
    ([BugID], [BugCode], [Title], [Severity], [BugStatus], [Environment], [CreatedAt])
VALUES
    (1,  N'BUG-201', N'Ошибка входа при пустом пароле',                         N'Critical', N'Open',       N'Test', '2025-09-11'),
    (2,  N'BUG-202', N'Дублирование задач на Kanban-доске',                     N'Major',    N'InProgress', N'Test', '2025-09-12'),
    (3,  N'BUG-203', N'Некорректный счётчик уведомлений',                       N'Major',    N'Open',       N'Dev',  '2025-09-13'),
    (4,  N'BUG-204', N'Падение экспорта отчёта в PDF',                          N'Blocker',  N'Open',       N'Test', '2025-09-14'),
    (5,  N'BUG-205', N'Зависание поиска при длинном запросе',                   N'Critical', N'InProgress', N'Test', '2025-09-15'),
    (6,  N'BUG-206', N'Неверная роль пользователя после регистрации',            N'Major',    N'Resolved',   N'Dev',  '2025-09-16'),
    (7,  N'BUG-207', N'Ошибка сборки в pipeline',                               N'Blocker',  N'Open',       N'CI',   '2025-09-17'),
    (8,  N'BUG-208', N'Сломана адаптивная вёрстка профиля',                     N'Minor',    N'Closed',     N'Test', '2025-09-18'),
    (9,  N'BUG-209', N'Не сохраняется оценка времени задачи',                   N'Major',    N'Open',       N'Dev',  '2025-09-19'),
    (10, N'BUG-210', N'Нельзя закрыть задачу с открытым блокирующим багом',      N'Critical', N'InProgress', N'Test', '2025-09-20');
GO


/* 
   Пункт 4.
   Заполнение таблиц рёбер.
   Устанавливаем связи между узлами графа.
*/


/* 
   AssignedTo: ProjectTask -> Executor
   Задача назначена исполнителю.
*/
INSERT INTO [AssignedTo]
    ($from_id, $to_id, [AssignedAt], [AssignmentStatus], [WorkloadPercent])
VALUES
    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 1),
     (SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 1),
     '2025-09-21', N'Active', 80),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 1),
     (SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 7),
     '2025-09-21', N'Active', 40),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 2),
     (SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 2),
     '2025-09-22', N'Finished', 70),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 3),
     (SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 7),
     '2025-09-23', N'Active', 90),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 4),
     (SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 2),
     '2025-09-24', N'Paused', 50),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 4),
     (SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 6),
     '2025-09-24', N'Active', 60),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 5),
     (SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 10),
     '2025-09-25', N'Paused', 40),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 6),
     (SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 1),
     '2025-09-26', N'Paused', 30),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 7),
     (SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 5),
     '2025-09-27', N'Active', 100),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 8),
     (SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 6),
     '2025-09-28', N'Finished', 70),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 9),
     (SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 9),
     '2025-09-29', N'Active', 50),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 10),
     (SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 7),
     '2025-09-30', N'Active', 60);
GO


/* 
   Reported: Executor -> Bug
   Исполнитель сообщил о баге.
*/
INSERT INTO [Reported]
    ($from_id, $to_id, [ReportedAt], [ReportChannel], [ReportPriority])
VALUES
    ((SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 3),
     (SELECT $node_id FROM [Bug] WHERE [BugID] = 1),
     '2025-10-01', N'Jira', N'Critical'),

    ((SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 8),
     (SELECT $node_id FROM [Bug] WHERE [BugID] = 2),
     '2025-10-02', N'TestRail', N'High'),

    ((SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 3),
     (SELECT $node_id FROM [Bug] WHERE [BugID] = 3),
     '2025-10-03', N'Jira', N'High'),

    ((SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 8),
     (SELECT $node_id FROM [Bug] WHERE [BugID] = 4),
     '2025-10-04', N'TestRail', N'Critical'),

    ((SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 3),
     (SELECT $node_id FROM [Bug] WHERE [BugID] = 5),
     '2025-10-05', N'Jira', N'Critical'),

    ((SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 9),
     (SELECT $node_id FROM [Bug] WHERE [BugID] = 6),
     '2025-10-06', N'Meeting', N'Medium'),

    ((SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 5),
     (SELECT $node_id FROM [Bug] WHERE [BugID] = 7),
     '2025-10-07', N'Jira', N'Critical'),

    ((SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 8),
     (SELECT $node_id FROM [Bug] WHERE [BugID] = 8),
     '2025-10-08', N'TestRail', N'Low'),

    ((SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 1),
     (SELECT $node_id FROM [Bug] WHERE [BugID] = 9),
     '2025-10-09', N'Email', N'High'),

    ((SELECT $node_id FROM [Executor] WHERE [ExecutorID] = 3),
     (SELECT $node_id FROM [Bug] WHERE [BugID] = 10),
     '2025-10-10', N'Jira', N'Critical');
GO


/* 
   BugBlocksTask: Bug -> ProjectTask
   Баг блокирует задачу.
*/
INSERT INTO [BugBlocksTask]
    ($from_id, $to_id, [BlockedFrom], [BlockStatus], [BlockWeight])
VALUES
    ((SELECT $node_id FROM [Bug] WHERE [BugID] = 1),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 1),
     '2025-10-11', N'Active', 9),

    ((SELECT $node_id FROM [Bug] WHERE [BugID] = 2),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 4),
     '2025-10-12', N'Active', 6),

    ((SELECT $node_id FROM [Bug] WHERE [BugID] = 3),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 5),
     '2025-10-13', N'Active', 7),

    ((SELECT $node_id FROM [Bug] WHERE [BugID] = 4),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 6),
     '2025-10-14', N'Active', 10),

    ((SELECT $node_id FROM [Bug] WHERE [BugID] = 5),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 9),
     '2025-10-15', N'Active', 8),

    ((SELECT $node_id FROM [Bug] WHERE [BugID] = 6),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 2),
     '2025-10-16', N'Resolved', 5),

    ((SELECT $node_id FROM [Bug] WHERE [BugID] = 7),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 7),
     '2025-10-17', N'Active', 10),

    ((SELECT $node_id FROM [Bug] WHERE [BugID] = 8),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 8),
     '2025-10-18', N'Resolved', 2),

    ((SELECT $node_id FROM [Bug] WHERE [BugID] = 9),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 10),
     '2025-10-19', N'Active', 6),

    ((SELECT $node_id FROM [Bug] WHERE [BugID] = 10),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 5),
     '2025-10-20', N'Active', 9);
GO


/* 
   TaskBlocksTask: ProjectTask -> ProjectTask
   Одна задача блокирует другую задачу.
*/
INSERT INTO [TaskBlocksTask]
    ($from_id, $to_id, [BlockedFrom], [Reason], [BlockStatus])
VALUES
    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 2),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 1),
     '2025-10-21', N'Регистрация нужна до полноценной авторизации', N'Active'),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 1),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 3),
     '2025-10-22', N'API задач требует готовой авторизации', N'Active'),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 3),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 5),
     '2025-10-23', N'Уведомления используют REST API задач', N'Active'),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 5),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 6),
     '2025-10-24', N'Экспорт должен учитывать уведомления о дедлайнах', N'Active'),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 7),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 6),
     '2025-10-25', N'Экспорт отчётов зависит от стабильного pipeline', N'Active'),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 8),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 4),
     '2025-10-26', N'Kanban-доска использует элементы профиля', N'Resolved'),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 3),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 9),
     '2025-10-27', N'Поиск по задачам требует готового API задач', N'Active'),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 10),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 3),
     '2025-10-28', N'Рефакторинг модуля проектов влияет на API задач', N'Active'),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 4),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 5),
     '2025-10-29', N'Уведомления должны отображаться на Kanban-доске', N'Active'),

    ((SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 9),
     (SELECT $node_id FROM [ProjectTask] WHERE [TaskID] = 6),
     '2025-10-30', N'Отчёты используют результаты поиска по задачам', N'Active');
GO


/* 
   Пункт 5.
   Запросы с использованием MATCH.
   Каждый запрос использует цепочку из 3 и более узлов.
*/


/* 
   Запрос 1.
   Найти задачи и баги, которые сообщили исполнители,
   назначенные на эти задачи.

   Цепочка:
   ProjectTask -> AssignedTo -> Executor -> Reported -> Bug
*/
SELECT DISTINCT
    T.[TaskCode] AS [Код задачи],
    T.[Title] AS [Задача],
    E.[FullName] AS [Исполнитель],
    E.[RoleName] AS [Роль исполнителя],
    B.[BugCode] AS [Код бага],
    B.[Title] AS [Баг],
    B.[Severity] AS [Критичность бага],
    R.[ReportPriority] AS [Приоритет сообщения]
FROM [ProjectTask] AS T,
     [AssignedTo] AS A,
     [Executor] AS E,
     [Reported] AS R,
     [Bug] AS B
WHERE MATCH(T-(A)->E-(R)->B)
ORDER BY T.[TaskCode], E.[FullName], B.[BugCode];
GO


/* 
   Запрос 2.
   Найти баги, которые были заведены исполнителями
   и блокируют задачи.

   Цепочка:
   Executor -> Reported -> Bug -> BugBlocksTask -> ProjectTask
*/
SELECT DISTINCT
    E.[FullName] AS [Кто сообщил],
    E.[RoleName] AS [Роль],
    B.[BugCode] AS [Код бага],
    B.[Title] AS [Баг],
    B.[Severity] AS [Критичность],
    BB.[BlockWeight] AS [Вес блокировки],
    T.[TaskCode] AS [Код заблокированной задачи],
    T.[Title] AS [Заблокированная задача],
    T.[TaskStatus] AS [Статус задачи]
FROM [Executor] AS E,
     [Reported] AS R,
     [Bug] AS B,
     [BugBlocksTask] AS BB,
     [ProjectTask] AS T
WHERE MATCH(E-(R)->B-(BB)->T)
ORDER BY B.[Severity], B.[BugCode], T.[TaskCode];
GO


/* 
   Запрос 3.
   Найти баги, которые блокируют задачи,
   и исполнителей, назначенных на эти заблокированные задачи.

   Цепочка:
   Bug -> BugBlocksTask -> ProjectTask -> AssignedTo -> Executor
*/
SELECT DISTINCT
    B.[BugCode] AS [Код бага],
    B.[Title] AS [Баг],
    B.[BugStatus] AS [Статус бага],
    BB.[BlockStatus] AS [Статус блокировки],
    BB.[BlockWeight] AS [Вес блокировки],
    T.[TaskCode] AS [Код задачи],
    T.[Title] AS [Заблокированная задача],
    E.[FullName] AS [Назначенный исполнитель],
    A.[AssignmentStatus] AS [Статус назначения]
FROM [Bug] AS B,
     [BugBlocksTask] AS BB,
     [ProjectTask] AS T,
     [AssignedTo] AS A,
     [Executor] AS E
WHERE MATCH(B-(BB)->T-(A)->E)
ORDER BY BB.[BlockWeight] DESC, B.[BugCode], T.[TaskCode];
GO


/* 
   Запрос 4.
   Найти задачи, которые блокируют другие задачи,
   и исполнителей заблокированных задач.

   Цепочка:
   ProjectTask -> TaskBlocksTask -> ProjectTask -> AssignedTo -> Executor
*/
SELECT DISTINCT
    T1.[TaskCode] AS [Код задачи-блокера],
    T1.[Title] AS [Задача-блокер],
    TB.[Reason] AS [Причина блокировки],
    TB.[BlockStatus] AS [Статус блокировки],
    T2.[TaskCode] AS [Код заблокированной задачи],
    T2.[Title] AS [Заблокированная задача],
    T2.[Priority] AS [Приоритет заблокированной задачи],
    E.[FullName] AS [Исполнитель заблокированной задачи]
FROM [ProjectTask] AS T1,
     [TaskBlocksTask] AS TB,
     [ProjectTask] AS T2,
     [AssignedTo] AS A,
     [Executor] AS E
WHERE MATCH(T1-(TB)->T2-(A)->E)
ORDER BY T1.[TaskCode], T2.[TaskCode], E.[FullName];
GO


/* 
   Запрос 5.
   Найти цепочки, где исполнитель сообщил баг,
   баг блокирует задачу, а эта задача блокирует другую задачу.

   Цепочка:
   Executor -> Reported -> Bug -> BugBlocksTask -> ProjectTask -> TaskBlocksTask -> ProjectTask
*/
SELECT DISTINCT
    E.[FullName] AS [Исполнитель],
    B.[BugCode] AS [Код бага],
    B.[Title] AS [Баг],
    T1.[TaskCode] AS [Задача, заблокированная багом],
    T1.[Title] AS [Название задачи],
    T2.[TaskCode] AS [Следующая заблокированная задача],
    T2.[Title] AS [Название следующей задачи],
    TB.[Reason] AS [Причина связи задач]
FROM [Executor] AS E,
     [Reported] AS R,
     [Bug] AS B,
     [BugBlocksTask] AS BB,
     [ProjectTask] AS T1,
     [TaskBlocksTask] AS TB,
     [ProjectTask] AS T2
WHERE MATCH(E-(R)->B-(BB)->T1-(TB)->T2)
ORDER BY E.[FullName], B.[BugCode], T1.[TaskCode], T2.[TaskCode];
GO


/* 
   Пункт 6. Запрос 1.
   SHORTEST_PATH с шаблоном "+".

   Найти кратчайшие цепочки задач, которые прямо или косвенно
   зависят от TASK-102, и показать исполнителей конечных задач.
*/

SELECT
    StartTask.[TaskCode] AS [Начальная задача],
    StartTask.[Title] AS [Название начальной задачи],
    STRING_AGG(PathTask.[TaskCode], N' -> ') WITHIN GROUP (GRAPH PATH) AS [Путь по задачам],
    LAST_VALUE(PathTask.[TaskCode]) WITHIN GROUP (GRAPH PATH) AS [Конечная задача],
    E.[FullName] AS [Исполнитель конечной задачи],
    E.[RoleName] AS [Роль исполнителя]
FROM [ProjectTask] AS StartTask,
     [TaskBlocksTask] FOR PATH AS TB,
     [ProjectTask] FOR PATH AS PathTask,
     [AssignedTo] AS A,
     [Executor] AS E
WHERE MATCH
(
    SHORTEST_PATH(StartTask(-(TB)->PathTask)+)
    AND LAST_NODE(PathTask)-(A)->E
)
AND StartTask.[TaskCode] = N'TASK-102'
ORDER BY [Конечная задача], E.[FullName];
GO


/* 
   Пункт 6. Запрос 2.
   SHORTEST_PATH с шаблоном "{1,5}".

   Найти кратчайший путь от TASK-102 до TASK-106
   длиной от 1 до 5 шагов и показать исполнителя конечной задачи.
*/

SELECT
    Q.[Начальная задача],
    Q.[Путь по задачам],
    Q.[Конечная задача],
    Q.[Исполнитель конечной задачи],
    Q.[Роль исполнителя]
FROM
(
    SELECT
        StartTask.[TaskCode] AS [Начальная задача],
        STRING_AGG(PathTask.[TaskCode], N' -> ') WITHIN GROUP (GRAPH PATH) AS [Путь по задачам],
        LAST_VALUE(PathTask.[TaskCode]) WITHIN GROUP (GRAPH PATH) AS [Конечная задача],
        E.[FullName] AS [Исполнитель конечной задачи],
        E.[RoleName] AS [Роль исполнителя]
    FROM [ProjectTask] AS StartTask,
         [TaskBlocksTask] FOR PATH AS TB,
         [ProjectTask] FOR PATH AS PathTask,
         [AssignedTo] AS A,
         [Executor] AS E
    WHERE MATCH
    (
        SHORTEST_PATH(StartTask(-(TB)->PathTask){1,5})
        AND LAST_NODE(PathTask)-(A)->E
    )
    AND StartTask.[TaskCode] = N'TASK-102'
) AS Q
WHERE Q.[Конечная задача] = N'TASK-106';
GO


/* Проверка результата */

SELECT
    [name] AS [TableName],
    CASE 
        WHEN [is_node] = 1 THEN N'true'
        ELSE N'false'
    END AS [IsNode],
    CASE 
        WHEN [is_edge] = 1 THEN N'true'
        ELSE N'false'
    END AS [IsEdge]
FROM sys.tables
WHERE [is_node] = 1 OR [is_edge] = 1
ORDER BY [name];
GO

SELECT N'Executor' AS [TableName], COUNT(*) AS [RowCount] FROM [Executor]
UNION ALL
SELECT N'ProjectTask', COUNT(*) FROM [ProjectTask]
UNION ALL
SELECT N'Bug', COUNT(*) FROM [Bug]
UNION ALL
SELECT N'AssignedTo', COUNT(*) FROM [AssignedTo]
UNION ALL
SELECT N'Reported', COUNT(*) FROM [Reported]
UNION ALL
SELECT N'BugBlocksTask', COUNT(*) FROM [BugBlocksTask]
UNION ALL
SELECT N'TaskBlocksTask', COUNT(*) FROM [TaskBlocksTask];
GO
