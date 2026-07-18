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
        "Dashboard",
        "Add Sales",
        "Add Payment",
        "Sales Report",
        "Pending Payments",
        "Sales Status",
        "Payment Summary",
        "SQL Analysis"
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
    
    elif menu == "Payment Summary":

        st.title("Payment Summary")

        conn = get_connection()

        if st.session_state.role == "Super Admin":

            query = """
            SELECT
            ps.payment_id,
            ps.sale_id,
            ps.payment_date,
            ps.amount_paid,
            ps.payment_method,
            cs.name,
            cs.product_name,
            b.branch_name
            FROM payment_splits ps
            JOIN customer_sales cs
            ON ps.sale_id = cs.sale_id
            JOIN branches b
            ON cs.branch_id = b.branch_id
            """

            df = pd.read_sql(
                query,
                conn
            )


        else:

            query = """
            SELECT
            ps.payment_id,
            ps.sale_id,
            ps.payment_date,
            ps.amount_paid,
            ps.payment_method,
            cs.name,
            cs.product_name,
            b.branch_name
            FROM payment_splits ps
            JOIN customer_sales cs
            ON ps.sale_id = cs.sale_id
            JOIN branches b
            ON cs.branch_id = b.branch_id
            WHERE cs.branch_id=%s
            """

            df = pd.read_sql(
                query,
                conn,
                params=(
                    st.session_state.branch_id,
                )
            )


        total_payment = df["amount_paid"].sum()

        total_transactions = len(df)


        col1, col2 = st.columns(2)


        col1.metric(
            "Total Payment Received",
            f"₹ {total_payment:,.2f}"
        )


        col2.metric(
            "Total Transactions",
            total_transactions
        )


        st.divider()


    
        st.subheader(
            "Payment Method Wise Collection"
        )


        payment_method_df = (
            df.groupby("payment_method")
            ["amount_paid"]
            .sum()
            .reset_index()
        )


        st.dataframe(
            payment_method_df
        )


        st.bar_chart(
            payment_method_df.set_index(
                "payment_method"
            )
        )


        st.divider()


        conn.close()

    elif menu == "Dashboard":

        st.title("Dashboard")

        conn = get_connection()


        # GET SALES DATA
    
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


    
        total_sales = df["gross_sales"].sum()

        received = df["received_amount"].sum()

        pending = df["pending_amount"].sum()

        total_orders = len(df)


        col1, col2, col3, col4 = st.columns(4)


        col1.metric(
            "Total Sales",
            f"₹ {total_sales:,.2f}"
        )


        col2.metric(
            "Received",
            f"₹ {received:,.2f}"
        )


        col3.metric(
            "Pending",
            f"₹ {pending:,.2f}"
        )


        col4.metric(
            "Total Sales",
            total_orders
        )



        st.divider()



        st.subheader(
            "Sales Status"
        )


        status = (
            df.groupby("status")
            .size()
            .reset_index(
                name="Count"
            )
        )


        st.bar_chart(
            status.set_index(
                "status"
            )
        )



        st.divider()

        conn.close()
    
    elif menu == "SQL Analysis":

        st.title("SQL Analysis")

        conn = get_connection()


        analysis = st.selectbox(
            "Select Query Analysis",
            [
                "View All Customer Sales",
                "View All Branches",
                "View All Payments",
                "Open Sales",

                "Total Gross Sales",
                "Total Received Amount",
                "Total Pending Amount",
                "Sales Count Per Branch",

                "Sales Details With Branch Name",
                "Branch Wise Total Sales",
                "Sales With Payment Method",
                "Sales With Total Payment Received",

                "Pending Amount Greater Than 5000",
                "Top 3 Highest Sales",
                "Top Branch By Sales",
                "Payment Method Collection"
            ]
        )

        # BASIC QUERIES


        if analysis == "View All Customer Sales":

            query = """
            SELECT *
            FROM customer_sales
            """


        elif analysis == "View All Branches":

            query = """
            SELECT *
            FROM branches
            """


        elif analysis == "View All Payments":

            query = """
            SELECT *
            FROM payment_splits
            """


        elif analysis == "Open Sales":

            query = """
            SELECT *
            FROM customer_sales
            WHERE status='Open'
            """


        # AGGREGATION QUERIES
    
        elif analysis == "Total Gross Sales":

            query = """
            SELECT
            SUM(gross_sales) AS total_gross_sales
            FROM customer_sales
            """


        elif analysis == "Total Received Amount":

            query = """
            SELECT
            SUM(received_amount) AS total_received_amount
            FROM customer_sales
            """


        elif analysis == "Total Pending Amount":

            query = """
            SELECT
            SUM(pending_amount) AS total_pending_amount
            FROM customer_sales
            """


        elif analysis == "Sales Count Per Branch":

            query = """
            SELECT
            branch_id,
            COUNT(sale_id) AS total_sales
            FROM customer_sales
            GROUP BY branch_id
            """

        # JOIN QUERIES
        
        elif analysis == "Sales Details With Branch Name":

            query = """
            SELECT
            cs.*,
            b.branch_name
            FROM customer_sales cs
            JOIN branches b
            ON cs.branch_id=b.branch_id
            """



        elif analysis == "Branch Wise Total Sales":

            query = """
            SELECT
            b.branch_name,
            SUM(cs.gross_sales) AS total_sales
            FROM customer_sales cs
            JOIN branches b
            ON cs.branch_id=b.branch_id
            GROUP BY b.branch_name
            """



        elif analysis == "Sales With Payment Method":

            query = """
            SELECT
            cs.sale_id,
            cs.name,
            ps.payment_method,
            ps.amount_paid
            FROM customer_sales cs
            JOIN payment_splits ps
            ON cs.sale_id=ps.sale_id
            """



        elif analysis == "Sales With Total Payment Received":

            query = """
            SELECT
            cs.sale_id,
            cs.name,
            cs.gross_sales,
            SUM(ps.amount_paid) AS total_received
            FROM customer_sales cs
            JOIN payment_splits ps
            ON cs.sale_id=ps.sale_id
            GROUP BY cs.sale_id
            """

        # FINANCIAL TRACKING
       
        elif analysis == "Pending Amount Greater Than 5000":

            query = """
            SELECT *
            FROM customer_sales
            WHERE pending_amount > 5000
            """



        elif analysis == "Top 3 Highest Sales":

            query = """
            SELECT *
            FROM customer_sales
            ORDER BY gross_sales DESC
            LIMIT 3
            """



        elif analysis == "Top Branch By Sales":

            query = """
            SELECT
            b.branch_name,
            SUM(cs.gross_sales) AS total_sales
            FROM customer_sales cs
            JOIN branches b
            ON cs.branch_id=b.branch_id
            GROUP BY b.branch_name
            ORDER BY total_sales DESC
            LIMIT 3
            """



        elif analysis == "Payment Method Collection":

            query = """
            SELECT
            payment_method,
            SUM(amount_paid) AS total_collection
            FROM payment_splits
            GROUP BY payment_method
            """

        df = pd.read_sql(
            query,
            conn
        )


        st.subheader(
            analysis
        )


        st.dataframe(
            df,
            use_container_width=True
        )

        conn.close()
