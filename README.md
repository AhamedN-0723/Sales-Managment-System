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

```
Sales Management System/
│
├── app.py
│   └── Streamlit application
│
├── connection.py
│   └── MySQL database connection setup
│
├── salesmanage.sql
│   ├── Database creation
│   ├── Tables
│   ├── Triggers
│   └── SQL analysis queries
│
├── Sales Management Datasets.zip/
│   └── Demo data files
│
└── README.md
```


---

# Database Design

The project contains the following main tables:

## Users Table

Stores login information and user roles.

Example fields:

- user_id
- username
- password
- role
- branch_id


## Branches Table

Stores branch information.

Example fields:

- branch_id
- branch_name


## Customer Sales Table

Stores sales transactions.

Example fields:

- sale_id
- branch_id
- customer details
- product details
- gross sales
- received amount
- pending amount
- status


## Payment Splits Table

Stores individual payment records.

Example fields:

- payment_id
- sale_id
- payment date
- amount paid
- payment method

---

# Trigger Implementation

A database trigger is implemented to maintain financial accuracy.

When a payment split is inserted:

1. The total received amount is recalculated.
2. The received_amount column in customer_sales is updated.
3. The pending_amount is automatically adjusted.

This ensures payment information remains consistent without manual updates.

---

# Installation and Setup

## 1. Clone the repository
  git clone <repository-url>
---

## 2. Install required libraries
pip install streamlit
pip install mysql-connector-python
pip install pandas

---

## 3. Setup MySQL Database

Open MySQL and run:
sales_management.sql

This will create:

- Database
- Tables
- Relationships
- Triggers
- Sample queries

---

## 4. Configure Database Connection

Update `connection.py` with your MySQL credentials.

Example:

```python
def get_connection():

    return mysql.connector.connect(
        host="localhost",
        user="your_username",
        password="your_password",
        database="sales_management"
    )

```
##5. Run the Application

Run:

streamlit run app.py

The application will open in your browser.

Application Workflow
User logs into the system.
System validates credentials from MySQL.
User role is identified.
Dashboard access is provided based on role.
Users can add sales and payment records.
SQL triggers automatically update payment calculations.
Reports display current sales and payment status.
SQL Analysis Performed

The project includes SQL analysis queries for:

Sales reports
Branch-wise sales analysis
Pending payment tracking
Open vs Closed sales analysis
Payment details analysis
Business performance monitoring
Future Improvements
Password encryption using hashing
Advanced dashboard charts
Export reports to Excel/PDF
Better exception handling
Additional analytics dashboards
Author

Your Name

Sales Management System Project


This README matches exactly what you built:
- `app.py` → Streamlit application  
- `connection.py` → MySQL connection  
- `Sales Management Datasets.zip` → demo data  
- `salesmanage.sql` → database + trigger + analysis queries  

It is also written in a way that a mentor evaluating your project can understand the architecture quickly.
