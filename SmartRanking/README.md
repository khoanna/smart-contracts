# Smart Contract for Student Exam Results

## Overview

This smart contract is developed to track the exam results of students, where each student is assigned a unique roll number and a set of marks. The marks are computed based on multiple factors like the quality of the solution and submission time, ensuring that no two students receive the same score. 

The contract provides functionality to insert students' results and retrieve specific details based on the students' ranks.

## Features

- **Insert Marks**: Allows the insertion of a student's roll number and marks.
- **Query by Rank**: Retrieve the marks and roll number of students based on their ranks.

## Public Functions

### `insertMarks(uint _rollNumber, uint _marks)`

This function allows the insertion of the roll number and corresponding marks of a student who has taken the exam. 

#### Parameters:
- `_rollNumber`: A unique identifier for each student. It is an unsigned integer that should be in the range of `0 <= _rollNumber < 2^256`.
- `_marks`: The marks scored by the student in the exam. It is an unsigned integer that should be in the range of `0 <= _marks < 2^256`.

#### Description:
The function inserts the roll number and marks into the smart contract. It ensures that no two students have the same score by using a complex algorithm that takes multiple factors into account.

### `scoreByRank(uint rank)`

This function returns the marks obtained by a student with a particular rank.

#### Parameters:
- `rank`: The rank of the student, represented as an unsigned integer.

#### Description:
This function will return the marks of the student corresponding to the provided rank. It ensures that the marks are returned based on the order determined by the rank.

### `rollNumberByRank(uint rank)`

This function returns the roll number of the student who has a particular rank.

#### Parameters:
- `rank`: The rank of the student, represented as an unsigned integer.

#### Description:
This function will return the roll number of the student who holds the provided rank. It ensures that the student with the specified rank is identified correctly.

