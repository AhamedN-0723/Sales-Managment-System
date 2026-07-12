# Sales Management System

A database-driven Sales Management System built using **Python, Streamlit, and MySQL**.  
The application allows users to manage sales records, payment details, pending payments, and generate sales reports with role-based access control.

---

# Project Overview

The Sales Management System is designed to manage sales operations across multiple branches.

The system provides secure login authentication and supports two user roles:

- **Super Admin**
  - Can access sales data from all branches
  - Can add sales for any branch
  - Can view complete sales reports
  - Can monitor pending payments

- **Admin**
  - Can add sales only for their assigned branch
  - Can add payment split details
  - Can view branch-specific sales data
  - Can track pending payments

The project also includes database triggers to automatically update received amounts and pending payments whenever payment records are added.

---

# Features

## Authentication Module

- Username and password-based login
- User validation using MySQL users table
- Session-based authentication using Streamlit session state
- Logout functionality


## Sales Management

- Add new sales entries
- Assign sales to specific branches
- Super Admin can select any branch
- Admin can only add sales for their assigned branch


## Payment Management

- Add payment split records
- Store multiple payments for a single sale
- Automatically update received amount using SQL triggers


## Reports and Analysis

- View sales reports
- View pending payments
- View open and closed sales status
- Branch-based data filtering


## Database Management

The SQL file contains:

- Database creation
- Table creation
- Primary keys and foreign keys
- Constraints
- Triggers
- SQL analysis queries

---

# Technologies Used

## Programming Language

**Python**

Used for application logic and database interaction.


## Frontend Framework

**Streamlit**

Used to create the interactive web dashboard.


## Database

**MySQL**

Used to store:

- User details
- Branch information
- Sales records
- Payment details


## Python Libraries

### Streamlit

Used for creating UI components.

### mysql-connector-python

Used for connecting Python application with MySQL database.

### Pandas

Used for displaying SQL query results in tabular format.

---

# Project Structure
