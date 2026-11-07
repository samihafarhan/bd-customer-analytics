# Bangladesh E-commerce Customer Analysis

A small project where I look at customer data from an online shop to answer two questions:

1. Which customers bring in the most money, and which ones are we losing?
2. How many customers come back after their first order?

**Tools:** Excel, SQL (SQLite), Power BI

**Data:** Made-up (synthetic) data that looks like a Bangladeshi online shop. It has 3,000 customers and about 17,000 order lines from Jan 2024 to Dec 2025. Prices are in BDT.

## What I did

1. **Excel:** Removed duplicate rows, fixed messy category names, removed cancelled and returned orders, and made pivot tables for monthly sales, category profit and payment methods.
2. **SQL:** Grouped customers into segments using RFM (how recently they bought, how often, how much they spent). Also measured how many customers come back each month after their first order (cohort retention).
3. **Power BI:** Built two dashboard pages from the SQL results.

## What I found

- Total sales were about 49.9M BDT with a profit margin of about 22%.
- **Champions** (best customers) are 25% of customers but bring in 63% of revenue.
- **At Risk** customers (503 of them) have not ordered in over a year on average, but they still account for 15% of revenue. They are the best group to win back.
- **Lost** customers are 22% of customers but only 3% of revenue, so they are not worth a big effort.
- About 20% of customers come back the month after their first order. After that it slowly drops to about 15% by month 12. (Later months use fewer groups of customers, so they are less reliable.)
- Facebook Ads brings the most customers, but the share who become Champions is about the same for every channel (24-27%).
- Electronics make 52% of sales but only a 13% margin. Fashion and Beauty give about 54% of the profit.
- Cash on Delivery (40%) and bKash (38%) are the most used payment methods.

## What I would suggest

- Send a win-back offer to At Risk customers.
- Reward Champions so they stay.
- Check Electronics prices and discounts, and promote Fashion and Beauty more.

## Dashboard

![Customer segments](Screenshots/power%20bi/retention.png)

![Retention](Screenshots/power%20bi/segment.png)

## Files

- `data/` – CSV files
- `excel/` – cleaning and pivot tables
- `sql/queries.sql` – all SQL queries
- `customer_dashboard.pbix` – dashboard file
- `screenshots/` – images of the work

*Note: the data is synthetic, so the results show my method, not real business facts.*