import streamlit as st
import mysql.connector
import pandas as pd

# 1. PAGE CONFIGURATION
st.set_page_config(page_title="CIMS Enterprise System", layout="wide", page_icon="🏢")

# 2. DATABASE CONNECTION
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="1234MySQL", 
        database="cims_db"
    )

# 3. SIDEBAR NAVIGATION
st.sidebar.title("🏢 CIMS System")
st.sidebar.write("Logged in as: **Admin (Root)**")
menu = st.sidebar.radio(
    "Select Module:", 
    ["📊 Executive Dashboard", "🗂️ Master Database", "📈 Analytics & Reports"]
)

# ---------------------------------------------------------
# MODULE 1: EXECUTIVE DASHBOARD
# ---------------------------------------------------------
if menu == "📊 Executive Dashboard":
    st.title("🚀 Executive Dashboard")
    st.markdown("Real-time overview of company assets and performance.")
    st.divider()

    try:
        conn = get_db_connection()
        
        # KEY METRICS (KPIs)
        col1, col2, col3, col4 = st.columns(4)
        
        # 1. Total Investment
        df_inv = pd.read_sql("SELECT SUM(p_invest) as total FROM package", conn)
        col1.metric("💰 Total Capital", f"${df_inv['total'][0]:,.0f}")
        
        # 2. Total Customers
        df_cust = pd.read_sql("SELECT COUNT(*) as count FROM customer", conn)
        col2.metric("👥 Active Investors", df_cust['count'][0])
        
        # 3. Total Managers
        df_mgr = pd.read_sql("SELECT COUNT(*) as count FROM manager", conn)
        col3.metric("👔 Managers", df_mgr['count'][0])

        # 4. Total Agents
        df_agent = pd.read_sql("SELECT COUNT(*) as count FROM agent", conn)
        col4.metric("🆔 Field Agents", df_agent['count'][0])
        
        st.divider()

        # CHARTS
        c1, c2 = st.columns(2)
        with c1:
            st.subheader("📦 Investment Package Popularity")
            df_pkg = pd.read_sql("SELECT p_name, p_invest FROM package", conn)
            st.bar_chart(df_pkg.set_index("p_name"))
            
        with c2:
            st.subheader("📍 Operator Locations")
            df_op = pd.read_sql("SELECT op_name, op_address FROM operator", conn)
            st.dataframe(df_op, use_container_width=True)

        conn.close()

    except Exception as e:
        st.error(f"Database Error: {e}")

# ---------------------------------------------------------
# MODULE 2: MASTER DATABASE (ALL TABLES)
# ---------------------------------------------------------
elif menu == "🗂️ Master Database":
    st.title("🗂️ Master Database Records")
    st.markdown("Direct access to all departmental tables.")
    
    # Create Tabs for every single table in your SQL
    tab1, tab2, tab3, tab4, tab5, tab6 = st.tabs([
        "👤 Customers", "📦 Packages", "👔 Managers", "🆔 Agents", "⚙️ Operators", "👑 Owners"
    ])
    
    conn = get_db_connection()

    with tab1:
        st.subheader("Customer Directory")
        search = st.text_input("🔍 Search Customer by Name:", key="cust_search")
        if search:
            query = f"SELECT * FROM customer WHERE c_name LIKE '%{search}%'"
        else:
            query = "SELECT * FROM customer"
        st.dataframe(pd.read_sql(query, conn), use_container_width=True)

    with tab2:
        st.subheader("Investment Packages")
        st.dataframe(pd.read_sql("SELECT * FROM package", conn), use_container_width=True)

    with tab3:
        st.subheader("Regional Managers")
        st.dataframe(pd.read_sql("SELECT * FROM manager", conn), use_container_width=True)

    with tab4:
        st.subheader("Field Agents")
        st.dataframe(pd.read_sql("SELECT * FROM agent", conn), use_container_width=True)

    with tab5:
        st.subheader("System Operators")
        st.dataframe(pd.read_sql("SELECT * FROM operator", conn), use_container_width=True)
        
    with tab6:
        st.subheader("Board of Directors (Owners)")
        st.dataframe(pd.read_sql("SELECT * FROM owner", conn), use_container_width=True)
        
    conn.close()

# ---------------------------------------------------------
# MODULE 3: ANALYTICS & REPORTS (YOUR SQL VIEWS)
# ---------------------------------------------------------
elif menu == "📈 Analytics & Reports":
    st.title("📈 Strategic Reports")
    st.markdown("These reports are generated from your **SQL Views** (Joins & Analytics).")
    
    conn = get_db_connection()
    
    # Report 1: ROI Analysis (from join1)
    st.subheader("1. 📊 Investment ROI Analysis")
    st.info("Source: SQL View `join1` (Joins Control & Package tables)")
    df_roi = pd.read_sql("SELECT * FROM join1", conn)
    st.dataframe(df_roi, use_container_width=True)
    
    st.divider()

    # Report 2: Manager Salary Audit (from join2)
    st.subheader("2. 💸 Manager Salary Audit")
    st.info("Source: SQL View `join2` (Self-Join on Manager table)")
    df_sal = pd.read_sql("SELECT * FROM join2", conn)
    st.dataframe(df_sal, use_container_width=True)

    st.divider()

    # Report 3: Total Payroll (from v21)
    st.subheader("3. 💼 Total Management Payroll")
    st.info("Source: SQL View `v21` (Aggregation)")
    df_payroll = pd.read_sql("SELECT * FROM v21", conn)
    st.metric("Total Monthly Salary Payout", f"${df_payroll['summation_of_sal'][0]:,.2f}")

    conn.close()