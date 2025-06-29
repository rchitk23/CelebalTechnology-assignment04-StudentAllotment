🎓 SQL Subject Allotment System

A SQL Server-based subject allotment simulation that assigns elective subjects to students based on GPA and preference order, respecting subject seat limits.

OUTPUT PREVIEW
### 🎓 Allotted Students
| Subject ID | Student ID  |
|------------|-------------|
| PO1491     | 159103041   |
| PO1491     | 159103036   |
| PO1492     | 159103039   |
| PO1492     | 159103038   |
| PO1492     | 159103040   |
| PO1492     | 159103037   |

 ❌ Unallotted Students
| Student ID  |
|-------------|
| (none)   |



 🖼️ Output Screenshot

Below is the actual output from SQL Server Management Studio after running the procedure:

![image](https://github.com/user-attachments/assets/e11ef187-5685-41a3-971b-5acb45e0d8da)

 📖 Problem Statement

Each student selects **5 elective subjects** in priority order. Based on GPA and subject availability:

- Students are processed in descending order of GPA
- Each is assigned the highest available preferred subject
- If no preferred subject has seats, the student is marked unallotted

 🧱 Database Schema

 StudentDetails
| Column       | Type      |
|--------------|-----------|
| StudentId    | VARCHAR   |
| StudentName  | VARCHAR   |
| GPA          | FLOAT     |
| Branch       | VARCHAR   |
| Section      | CHAR      |

 `SubjectDetails`
| Column         | Type    |
|----------------|---------|
| SubjectId      | VARCHAR |
| SubjectName    | VARCHAR |
| MaxSeats       | INT     |
| RemainingSeats | INT     |

 `StudentPreference`
| Column      | Type    |
|-------------|---------|
| StudentId   | VARCHAR |
| SubjectId   | VARCHAR |
| Preference  | INT     |

 `Allotments`
| Column     | Type    |
|------------|---------|
| SubjectId  | VARCHAR |
| StudentId  | VARCHAR |

 `UnallotedStudents`
| Column     | Type    |
|------------|---------|
| StudentId  | VARCHAR |

 ⚙️ Stored Procedure Logic

Procedure: `AllocateSubjects`

1. Sorts students by GPA (descending)
2. Iterates over each student's subject preferences
3. Allots the first subject with available seats
4. If all preferred subjects are full, marks student unallotted
5. Final output is displayed with labels using `UNION ALL`

---By Rachit Kumar


