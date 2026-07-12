import streamlit as st
from connection import get_connection
from datetime import date
import pandas as pd




st.set_page_config(
    page_title="Sales Management System",
    layout="wide"
)

if "logged_in" not in st.session_state:
    st.session_state.logged_in = False

def logout():
    st.session_state.clear()
    st.rerun()

#login page

if not st.session_state.logged_in:



    st.title("Sales Management System")

    username = st.text_input("Username")
    password = st.text_input("Password", type="password")

    
    

    if st.button("Login"):

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT*FROM users
            WHERE username=%s
            AND password=%s
            """,
            (username, password)
        )

        user = cursor.fetchone()

        cursor.close()
        conn.close()

        if user:

            st.session_state.logged_in = True
            st.session_state.username = user["username"]
            st.session_state.role = user["role"]
            st.session_state.branch_id = user["branch_id"]

            st.rerun()

        else:
            st.error("Invalid username or password")
    col1, col2, col3 = st.columns([1, 2, 1])

    with col2:
        st.image(
        "login.png",
        width=800
        )

else:
    st.sidebar.write(
        "User:", 
        st.session_state.username
    )
    st.sidebar.write(
        "Role:",
        st.session_state.role
    )
    st.sidebar.write(
        "Branch:",
        st.session_state.branch_id
    )

    if st.sidebar.button("Logout"):
        logout()

    menu = st.sidebar.selectbox(
        "Menu",
        [
            "Add Sales",
            "Add Payment",
            "Sales Report",
            "Pending Payments",
            "Sales Status"
        ]
    )


    if menu == "Add Sales":

        st.title("Add Sales Entry")

        conn = get_connection()

        cursor = conn.cursor(dictionary=True)

        if st.session_state.role == "Super Admin":

            cursor.execute(
                """
                SELECT *
                FROM branches
                """
            )

            branches = cursor.fetchall()

            branch = st.selectbox(
                "Select Branch",
                branches,
                format_func=lambda x: x["branch_name"]
            )

            branch_id = branch["branch_id"]

        else:

            branch_id = st.session_state.branch_id

            st.info(
                f"Branch ID: {branch_id}"
            )

        sale_date = st.date_input(
            "Date",
            date.today()
        )

        name = st.text_input(
            "Customer Name"
        )

        mobile = st.text_input(
            "Mobile Number"
        )

        product = st.text_input(
            "Product Name"
        )

        gross_sales = st.number_input(
            "Gross Sales",
            min_value=0
        )

        status = st.selectbox(
            "Status",
            [
                "Open",
                "Close"
            ]
        )

        if st.button("Add Sale"):


            cursor.execute(
                """
                INSERT INTO customer_sales
                (
                branch_id,
                date,
                name,
                mobile_number,
                product_name,
                gross_sales,
                received_amount,
                status
                )

                VALUES
                (%s,%s,%s,%s,%s,%s,%s,%s)
                """,

                (
                branch_id,
                sale_date,
                name,
                mobile,
                product,
                gross_sales,
                0,
                status
                )
            )

            conn.commit()


            st.success(
                "Sale Added Successfully"
            )

        cursor.close()

        conn.close()

    elif menu == "Add Payment":


        st.title("Add Payment Split")


        sale_id = st.number_input(
            "Sale ID",
            min_value=1
        )


        payment_date = st.date_input(
            "Payment Date"
        )


        amount_paid = st.number_input(
            "Amount Paid",
            min_value=0
        )


        method = st.selectbox(
            "Payment Method",
            [
                "Cash",
                "Card",
                "UPI",
                "Bank"
            ]
        )

        if st.button("Add Payment"):


            conn = get_connection()

            cursor = conn.cursor()


            cursor.execute(
                """
                INSERT INTO payment_splits
                (
                sale_id,
                payment_date,
                amount_paid,
                payment_method
                )

                VALUES
                (%s,%s,%s,%s)
                """,

                (
                sale_id,
                payment_date,
                amount_paid,
                method
                )
            )

            conn.commit()

            cursor.close()

            conn.close()


            st.success(
                "Payment Added"
            )

    elif menu == "Sales Report":

        st.title("Sales Report")

        conn = get_connection()

        if st.session_state.role == "Super Admin":

            query = """
            SELECT *
            FROM customer_sales
            """
            df = pd.read_sql(
                query,
                conn
            )

        else:
            query = """
            SELECT *
            FROM customer_sales
            WHERE branch_id=%s
            """

            df = pd.read_sql(
                query,
                conn,
                params=(
                    st.session_state.branch_id,
                )
            )

        st.dataframe(df)

        conn.close()

    elif menu == "Pending Payments":

        st.title("Pending Payments")

        conn = get_connection()

        if st.session_state.role == "Super Admin":


            query = """
            SELECT 
            sale_id,
            branch_id,
            name,
            product_name,
            pending_amount,
            status
            FROM customer_sales
            WHERE pending_amount > 0
            """


            df = pd.read_sql(
                query,
                conn
            )

        else:


            query = """
            SELECT sale_id,
            branch_id,
            name, product_name,
            pending_amount, status
            FROM customer_sales
            WHERE pending_amount > 0
            AND branch_id = %s
            """


            df = pd.read_sql(
                query,
                conn,
                params=(
                    st.session_state.branch_id,
                )
            )


        st.dataframe(df)


        conn.close()

    elif menu == "Sales Status":


        st.title("Open vs Close Sales")


        conn = get_connection()


        query = """
        SELECT
        status,
        COUNT(*) AS total
        FROM customer_sales
        GROUP BY status
        """


        df = pd.read_sql(
            query,
            conn
        )

        st.dataframe(df)

        conn.close()