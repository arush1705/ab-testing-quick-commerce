DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    device VARCHAR(20) NOT NULL,
    user_type VARCHAR(20) NOT NULL,
    signup_date DATE NOT NULL
);

DROP TABLE IF EXISTS sessions;

CREATE TABLE sessions (
    session_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    session_start TIMESTAMP NOT NULL,
    pages_viewed INT NOT NULL,

    CONSTRAINT fk_sessions_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);

DROP TABLE IF EXISTS cart_events;

CREATE TABLE cart_events (
    cart_id INT PRIMARY KEY,
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    cart_value NUMERIC(10,2) NOT NULL,
    items INT NOT NULL,

    CONSTRAINT fk_cart_session
        FOREIGN KEY (session_id)
        REFERENCES sessions(session_id),

    CONSTRAINT fk_cart_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);

DROP TABLE IF EXISTS checkout_events;

CREATE TABLE checkout_events (
    checkout_id INT PRIMARY KEY,
    cart_id INT NOT NULL,
    user_id INT NOT NULL,
    checkout_started INT NOT NULL,
    completed_checkout INT NOT NULL,

    CONSTRAINT fk_checkout_cart
        FOREIGN KEY (cart_id)
        REFERENCES cart_events(cart_id),

    CONSTRAINT fk_checkout_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    checkout_id INT NOT NULL,
    order_value NUMERIC(10,2) NOT NULL,
    delivery_fee INT NOT NULL,
    coupon_value INT NOT NULL,
    cancelled INT NOT NULL,
    margin NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_orders_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_orders_checkout
        FOREIGN KEY (checkout_id)
        REFERENCES checkout_events(checkout_id)
);

DROP TABLE IF EXISTS experiment_assignment;

CREATE TABLE experiment_assignment (
    user_id INT PRIMARY KEY,
    experiment_group VARCHAR(10) NOT NULL,
    assigned_date DATE NOT NULL,

    CONSTRAINT fk_experiment_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);

---Phase 1: Data Validation 

---Check row counts
SELECT COUNT(*) FROM users;

SELECT COUNT(*) FROM experiment_assignment;

SELECT COUNT(*) FROM sessions;

SELECT COUNT(*) FROM cart_events;

SELECT COUNT(*) FROM checkout_events;

SELECT COUNT(*) FROM orders;

---Check for duplicate primary keys
SELECT user_id, COUNT(user_id) FROM users
GROUP BY user_id HAVING COUNT(user_id) > 1;

SELECT session_id, COUNT(session_id) FROM sessions
GROUP BY session_id HAVING COUNT(session_id) > 1;

SELECT cart_id, COUNT(user_id) FROM cart_events
GROUP BY cart_id HAVING COUNT(cart_id) > 1;

SELECT checkout_id, COUNT(checkout_id) FROM checkout_events
GROUP BY checkout_id HAVING COUNT(checkout_id) > 1;

SELECT order_id, COUNT(order_id) FROM orders
GROUP BY order_id HAVING COUNT(order_id) > 1;

SELECT user_id, COUNT(user_id) FROM experiment_assignment
GROUP BY user_id HAVING COUNT(user_id) > 1;

---Check for NULL values
SELECT * FROM users
WHERE 
ORcity IS NULL
OR device IS NULL
OR user_type IS NULL
OR signup_date IS NULL;

SELECT * FROM sessions
WHERE session_id IS NULL
OR user_id IS NULL
OR session_start IS NULL
OR pages_viewed IS NULL;

SELECT * FROM cart_events
WHERE cart_id IS NULL
OR session_id IS NULL
OR user_id IS NULL
OR cart_value IS NULL
OR items IS NULL;

SELECT * FROM checkout_events
WHERE checkout_id IS NULL
OR cart_id IS NULL
OR user_id IS NULL
OR checkout_started IS NULL
OR completed_checkout IS NULL;

SELECT * FROM orders
WHERE order_id IS NULL
OR user_id IS NULL
OR checkout_id IS NULL
OR order_value IS NULL
OR coupon_value IS NULL
OR cancelled IS NULL
OR margin IS NULL
OR delivery_fee IS NULL;
				
SELECT * FROM experiment_assignment
WHERE user_id IS NULL
OR experiment_group IS NULL
OR assigned_date IS NULL;				

---Validate foreign keys 
SELECT s.*
FROM sessions s  
LEFT JOIN users u
ON u.user_id = s.user_id
WHERE u.user_id IS NULL;

SELECT c.*
FROM cart_events c
LEFT JOIN sessions s
ON c.session_id = s.session_id
WHERE s.session_id IS NULL;

SELECT c.*
FROM cart_events c  
LEFT JOIN users u
ON c.user_id = u.user_id
WHERE u.user_id IS NULL;

SELECT ce.*
FROM checkout_events ce
LEFT JOIN cart_events c
ON ce.cart_id = c.cart_id
WHERE c.cart_id IS NULL;

SELECT ce.*
FROM checkout_events ce  
LEFT JOIN users u
ON ce.user_id = u.user_id
WHERE u.user_id IS NULL;

SELECT o.*
FROM orders o  
LEFT JOIN users u
ON o.user_id = u.user_id
WHERE u.user_id IS NULL;

SELECT o.*
FROM orders o
LEFT JOIN checkout_events ce
ON o.checkout_id = ce.checkout_id
WHERE ce.checkout_id IS NULL;

SELECT ea.*
FROM experiment_assignment ea  
LEFT JOIN users u
ON ea.user_id = u.user_id
WHERE u.user_id IS NULL;

---Phase 2: Validate Experiment

---A/B Split
SELECT experiment_group, COUNT(*),
ROUND(100*COUNT(*)/(SELECT COUNT(*)FROM experiment_assignment),2) AS Percentage
FROM experiment_assignment
GROUP BY experiment_group;

---Check City Distribution
SELECT ea.experiment_group, u.city, COUNT(u.user_id) AS users
FROM users u JOIN experiment_assignment ea 
ON u.user_id = ea.user_id
GROUP BY ea.experiment_group, u.city
ORDER BY u.city,ea.experiment_group;

---Check Device Distribution
SELECT ea.experiment_group, u.device, COUNT(u.user_id) 
FROM users u JOIN experiment_assignment ea 
ON u.user_id = ea.user_id
GROUP BY ea.experiment_group, u.device
ORDER BY u.device,ea.experiment_group; 

---Check User Type Distribution
SELECT ea.experiment_group, u.user_type, COUNT(u.user_id) 
FROM users u JOIN experiment_assignment ea 
ON u.user_id = ea.user_id
GROUP BY ea.experiment_group, u.user_type
ORDER BY u.user_type,ea.experiment_group; 

---Check Signup Date Distribution
SELECT experiment_group, 
MIN(signup_date) AS first_signup, 
MAX(signup_date) AS last_signup,
ROUND(AVG(CURRENT_DATE - signup_date),2) AS avg_account_age_days
FROM experiment_assignment ea
JOIN users u
ON ea.user_id = u.user_id
GROUP BY experiment_group;

---Phase 3:Overall Business Metrics (Baseline Analysis)

---1. Total Sessions
SELECT COUNT(*) AS total_sessions
FROM sessions;

---2. Average Pages Viewed
SELECT ROUND(AVG(pages_viewed),2) AS avg_pages_viewed
FROM sessions;

---3. Cart Statistics
SELECT COUNT(*) AS total_carts,
ROUND(AVG(cart_value),2) AS avg_cart_value,
ROUND(AVG(items),2) AS avg_items
FROM cart_events;

---4. Checkout Statistics
SELECT SUM(checkout_started) AS checkout_started,
SUM(completed_checkout) AS completed_checkout 
FROM checkout_events;

---5. Order Statistics
SELECT COUNT(*) AS total_orders,
ROUND(AVG(order_value),2) AS avg_order_value,
ROUND(AVG(delivery_fee),2) AS avg_delivery_fee,
ROUND(AVG(coupon_value),2) AS avg_coupon,
ROUND(AVG(margin),2) AS avg_margin
FROM orders;

---6. Cancellation Rate
SELECT ROUND(100*SUM(cancelled)/ COUNT(*),2) AS cancellation_rate
FROM orders;


---Phase 4: Funnel Analysis (A/B Comparison)

---Assigned Users
        ↓
---Started Session
        ↓
---Added to Cart
        ↓
---Started Checkout
        ↓
---Completed Checkout
        ↓
---Placed Order

---Assigned Users
SELECT ea.experiment_group,
COUNT(*) assigned_users
FROM experiment_assignment ea
LEFT JOIN users u
ON ea.user_id = u.user_id
GROUP BY ea.experiment_group;

---Started Session
SELECT ea.experiment_group,
COUNT(DISTINCT s.user_id) AS session_users
FROM experiment_assignment ea
LEFT JOIN sessions s
ON s.user_id = ea.user_id
GROUP BY ea.experiment_group;

---Added to Cart
SELECT ea.experiment_group,
COUNT(DISTINCT c.user_id) AS cart_added_users
FROM experiment_assignment ea
LEFT JOIN cart_events c
ON c.user_id = ea.user_id
GROUP BY ea.experiment_group;

---Started Checkout
SELECT ea.experiment_group,
COUNT(DISTINCT ce.user_id) AS checkout_started_users
FROM experiment_assignment ea
LEFT JOIN checkout_events ce
ON  ea.user_id =  ce.user_id
WHERE ce.checkout_started = 1
GROUP BY ea.experiment_group;

---Completed Checkout
SELECT ea.experiment_group,
COUNT(DISTINCT ce.user_id) AS completed_checkout_users
FROM experiment_assignment ea
LEFT JOIN checkout_events ce
ON  ea.user_id =  ce.user_id
WHERE ce.completed_checkout = 1
GROUP BY ea.experiment_group;

---Placed Order
SELECT ea.experiment_group,
COUNT(DISTINCT o.user_id) AS ordered_users
FROM experiment_assignment ea
LEFT JOIN orders o
ON o.user_id = ea.user_id
GROUP BY ea.experiment_group;

---4.4 Conversion Rates

WITH assigned AS (
SELECT
experiment_group,
COUNT(*) AS assigned_users
FROM experiment_assignment
GROUP BY experiment_group
),

sessions AS (
SELECT ea.experiment_group,
COUNT(DISTINCT s.user_id) AS session_users
FROM experiment_assignment ea
LEFT JOIN sessions s
ON ea.user_id = s.user_id
GROUP BY ea.experiment_group
),

cart AS (
SELECT ea.experiment_group,
COUNT(DISTINCT c.user_id) AS cart_added_users
FROM experiment_assignment ea
LEFT JOIN cart_events c
ON c.user_id = ea.user_id
GROUP BY ea.experiment_group
),

checkout_started AS (
SELECT ea.experiment_group,
COUNT(DISTINCT ce.user_id) AS checkout_started_users
FROM experiment_assignment ea
LEFT JOIN checkout_events ce
ON  ea.user_id =  ce.user_id
WHERE ce.checkout_started = 1
GROUP BY ea.experiment_group
),

checkout_completed AS (
SELECT ea.experiment_group,
COUNT(DISTINCT ce.user_id) AS completed_checkout_users
FROM experiment_assignment ea
LEFT JOIN checkout_events ce
ON  ea.user_id =  ce.user_id
WHERE ce.completed_checkout = 1
GROUP BY ea.experiment_group
),

orders AS (
SELECT ea.experiment_group,
COUNT(DISTINCT o.user_id) AS ordered_users
FROM experiment_assignment ea
LEFT JOIN orders o
ON o.user_id = ea.user_id
GROUP BY ea.experiment_group
)

SELECT
a.experiment_group,
assigned_users,
session_users,
cart_added_users,
checkout_started_users,
completed_checkout_users,
ordered_users,
ROUND(100 * session_users / assigned_users,2) AS session_conversion,
ROUND(100 * cart_added_users / session_users,2) AS cart_conversion,
ROUND(100 *  checkout_started_users / cart_added_users,2) AS checkout_start_conversion,
ROUND(100 *  completed_checkout_users / checkout_started_users,2) AS checkout_complete_conversion,
ROUND(100 * ordered_users / completed_checkout_users,2) AS cart_conversion,
ROUND(100 * ordered_users / assigned_users,2) AS overall_conversion

FROM assigned a
JOIN sessions s
ON a.experiment_group=s.experiment_group
JOIN cart c
ON a.experiment_group=c.experiment_group
JOIN checkout_started cs
ON a.experiment_group=cs.experiment_group
JOIN checkout_completed cc
ON a.experiment_group=cc.experiment_group
JOIN orders o
ON a.experiment_group=o.experiment_group;

---Phase 5: A/B Test Analysis (Business Metrics)

---5.1 — Primary Metric: Conversion Rate
WITH assigned AS (
SELECT
experiment_group,
COUNT(*) AS assigned_users
FROM experiment_assignment
GROUP BY experiment_group
),

orders AS (
SELECT ea.experiment_group,
COUNT(DISTINCT o.user_id) AS ordered_users
FROM experiment_assignment ea
LEFT JOIN orders o
ON o.user_id = ea.user_id
GROUP BY ea.experiment_group
)

SELECT
a.experiment_group,
a.assigned_users,
o.ordered_users,
ROUND(100 * ordered_users / assigned_users,2) AS conversion_rate

FROM assigned a
JOIN orders o
ON a.experiment_group=o.experiment_group;

---5.2 — Average Order Value (AOV)
SELECT ea.experiment_group,
ROUND(SUM(order_value)/COUNT(o.order_id),2) AS average_order_value
FROM experiment_assignment ea
JOIN orders o
ON ea.user_id = o.user_id
GROUP BY ea.experiment_group;

---5.3 — Revenue
SELECT ea.experiment_group,
ROUND(SUM(o.order_value),2) AS revenue
FROM experiment_assignment ea
JOIN orders o
ON ea.user_id = o.user_id
GROUP BY ea.experiment_group;

---5.4 — Revenue Per User (RPU)
WITH assigned AS (
SELECT
experiment_group,
COUNT(*) AS assigned_users
FROM experiment_assignment
GROUP BY experiment_group
),

revenue AS (
SELECT ea.experiment_group,
ROUND(SUM(o.order_value),2) AS total_revenue
FROM experiment_assignment ea
JOIN orders o
ON ea.user_id = o.user_id
GROUP BY ea.experiment_group
)

SELECT a.experiment_group,
ROUND((r.total_revenue/a.assigned_users),2) as revenue_per_user
FROM assigned a
JOIN revenue r
ON r.experiment_group = a.experiment_group;

---5.5 — Delivery Fee
SELECT ea.experiment_group,
ROUND(AVG(o.delivery_fee),2) AS average_delivery_fee
FROM experiment_assignment ea
JOIN orders o
ON ea.user_id = o.user_id
GROUP BY ea.experiment_group;

---5.6 — Coupon Usage
SELECT ea.experiment_group,
ROUND(AVG(o.coupon_value),2) AS average_coupon_value
FROM experiment_assignment ea
JOIN orders o
ON ea.user_id = o.user_id
GROUP BY ea.experiment_group;

---5.7 — Cancellation Rate
SELECT ea.experiment_group,
ROUND(100* AVG(o.cancelled),2) AS cancellation_rate
FROM experiment_assignment ea
JOIN orders o
ON ea.user_id = o.user_id
GROUP BY ea.experiment_group;

---5.8 — Margin
SELECT ea.experiment_group,
ROUND(AVG(o.margin),2) AS average_margin
FROM experiment_assignment ea
JOIN orders o
ON ea.user_id = o.user_id
GROUP BY ea.experiment_group;

---5.9 & 5.10 
---Absolute & Relative Lift, Conversion Rate 
WITH metrics AS (
SELECT ea.experiment_group,
ROUND(COUNT(DISTINCT o.user_id)*100.0 /COUNT(DISTINCT ea.user_id),2) AS conversion_rate
FROM experiment_assignment ea
LEFT JOIN orders o
ON ea.user_id = o.user_id
GROUP BY ea.experiment_group)

SELECT 
MAX(CASE WHEN experiment_group = 'A' THEN conversion_rate END ) AS control_conversion_rate ,
MAX(CASE WHEN experiment_group = 'B' THEN conversion_rate END ) AS treatment_conversion_rate,
ROUND(
 MAX(CASE WHEN experiment_group = 'B' THEN conversion_rate END ) 
- MAX(CASE WHEN experiment_group = 'A' THEN conversion_rate END ) 
,2) AS absolute_lift,

ROUND(
(MAX(CASE WHEN experiment_group = 'B' THEN conversion_rate END ) 
- MAX(CASE WHEN experiment_group = 'A' THEN conversion_rate END )) 
/MAX(CASE WHEN experiment_group = 'A' THEN conversion_rate END )*100 
,2) AS relative_lift 

FROM metrics;

---Absolute & Relative Lift, AOV
WITH metrics AS (
SELECT ea.experiment_group,
ROUND(SUM(order_value)/COUNT(o.order_id),2) AS average_order_value
FROM experiment_assignment ea
JOIN orders o
ON ea.user_id = o.user_id
GROUP BY ea.experiment_group)

SELECT 
MAX(CASE WHEN experiment_group = 'A' THEN average_order_value END ) AS control_aov ,
MAX(CASE WHEN experiment_group = 'B' THEN average_order_value END ) AS treatment_aov,
ROUND(
 MAX(CASE WHEN experiment_group = 'B' THEN average_order_value END ) 
- MAX(CASE WHEN experiment_group = 'A' THEN average_order_value END ) 
,2) AS absolute_lift,

ROUND(
(MAX(CASE WHEN experiment_group = 'B' THEN average_order_value END ) 
- MAX(CASE WHEN experiment_group = 'A' THEN average_order_value END )) 
/MAX(CASE WHEN experiment_group = 'A' THEN average_order_value END )*100 
,2) AS relative_lift 

FROM metrics;

---Absolute & Relative Lift, Revenue per User (RPU)
WITH assigned AS (
SELECT
experiment_group,
COUNT(*) AS assigned_users
FROM experiment_assignment
GROUP BY experiment_group
),

revenue AS (
SELECT ea.experiment_group,
ROUND(SUM(o.order_value),2) AS total_revenue
FROM experiment_assignment ea
JOIN orders o
ON ea.user_id = o.user_id
GROUP BY ea.experiment_group
),

metrics AS (
SELECT a.experiment_group,
ROUND((r.total_revenue/a.assigned_users),2) as revenue_per_user
FROM assigned a
JOIN revenue r
ON r.experiment_group = a.experiment_group)

SELECT 
MAX(CASE WHEN experiment_group = 'A' THEN revenue_per_user END ) AS control_revenue_per_user ,
MAX(CASE WHEN experiment_group = 'B' THEN revenue_per_user END ) AS treatment_revenue_per_user,
ROUND(
 MAX(CASE WHEN experiment_group = 'B' THEN revenue_per_user END ) 
- MAX(CASE WHEN experiment_group = 'A' THEN revenue_per_user END ) 
,2) AS absolute_lift,

ROUND(
(MAX(CASE WHEN experiment_group = 'B' THEN revenue_per_user END ) 
- MAX(CASE WHEN experiment_group = 'A' THEN revenue_per_user END )) 
/MAX(CASE WHEN experiment_group = 'A' THEN revenue_per_user END )*100 
,2) AS relative_lift 

FROM metrics;

---Absolute & Relative Lift, Average Margin
WITH metrics AS (
SELECT ea.experiment_group,
ROUND(AVG(o.margin),2) AS average_margin
FROM experiment_assignment ea
JOIN orders o
ON ea.user_id = o.user_id
GROUP BY ea.experiment_group)

SELECT 
MAX(CASE WHEN experiment_group = 'A' THEN average_margin END ) AS control_average_margin ,
MAX(CASE WHEN experiment_group = 'B' THEN average_margin END ) AS treatment_average_margin,
ROUND(
 MAX(CASE WHEN experiment_group = 'B' THEN average_margin END ) 
- MAX(CASE WHEN experiment_group = 'A' THEN average_margin END ) 
,2) AS absolute_lift,

ROUND(
(MAX(CASE WHEN experiment_group = 'B' THEN average_margin END ) 
- MAX(CASE WHEN experiment_group = 'A' THEN average_margin END )) 
/MAX(CASE WHEN experiment_group = 'A' THEN average_margin END )*100 
,2) AS relative_lift 

FROM metrics;

---Absolute & Relative Lift, Cancellation Rate (Guardrail Metric)
WITH metrics AS (
SELECT ea.experiment_group,
ROUND(100.0* AVG(o.cancelled),2) AS cancellation_rate
FROM experiment_assignment ea
JOIN orders o
ON ea.user_id = o.user_id
GROUP BY ea.experiment_group)

SELECT 
MAX(CASE WHEN experiment_group = 'A' THEN cancellation_rate END ) AS control_cancellation_rate ,
MAX(CASE WHEN experiment_group = 'B' THEN cancellation_rate END ) AS treatment_cancellation_rate,
ROUND(
 MAX(CASE WHEN experiment_group = 'B' THEN cancellation_rate END ) 
- MAX(CASE WHEN experiment_group = 'A' THEN cancellation_rate END ) 
,2) AS absolute_lift,

ROUND(
(MAX(CASE WHEN experiment_group = 'B' THEN cancellation_rate END ) 
- MAX(CASE WHEN experiment_group = 'A' THEN cancellation_rate END )) 
/MAX(CASE WHEN experiment_group = 'A' THEN cancellation_rate END )*100 
,2) AS relative_lift 

FROM metrics;


---
WITH metrics AS (

-- Conversion Rate
SELECT
'Conversion Rate' AS metric,
ROUND(
COUNT(DISTINCT CASE WHEN ea.experiment_group = 'A' THEN o.user_id END) * 100.0 /
COUNT(DISTINCT CASE WHEN ea.experiment_group = 'A' THEN ea.user_id END),2
) AS control,

ROUND(
COUNT(DISTINCT CASE WHEN ea.experiment_group = 'B' THEN o.user_id END) * 100.0 /
COUNT(DISTINCT CASE WHEN ea.experiment_group = 'B' THEN ea.user_id END),2
) AS treatment

FROM experiment_assignment ea
LEFT JOIN orders o
ON ea.user_id = o.user_id

UNION ALL

-- Average Order Value
SELECT
'Average Order Value',
ROUND(AVG(CASE WHEN ea.experiment_group='A' THEN o.order_value END),2),
ROUND(AVG(CASE WHEN ea.experiment_group='B' THEN o.order_value END),2)
FROM experiment_assignment ea
JOIN orders o
ON ea.user_id=o.user_id

UNION ALL

-- Revenue Per User
SELECT
'Revenue Per User',

ROUND(
SUM(CASE WHEN ea.experiment_group='A' THEN o.order_value END)/
COUNT(DISTINCT CASE WHEN ea.experiment_group='A' THEN ea.user_id END)
,2),

ROUND(
SUM(CASE WHEN ea.experiment_group='B' THEN o.order_value END)/
COUNT(DISTINCT CASE WHEN ea.experiment_group='B' THEN ea.user_id END)
,2)

FROM experiment_assignment ea
LEFT JOIN orders o
ON ea.user_id=o.user_id

UNION ALL

-- Average Margin
SELECT
'Average Margin',
ROUND(AVG(CASE WHEN ea.experiment_group='A' THEN o.margin END),2),
ROUND(AVG(CASE WHEN ea.experiment_group='B' THEN o.margin END),2)
FROM experiment_assignment ea
JOIN orders o
ON ea.user_id=o.user_id

UNION ALL

-- Cancellation Rate
SELECT
'Cancellation Rate',
ROUND(100.0*AVG(CASE WHEN ea.experiment_group='A' THEN o.cancelled END),2),
ROUND(100.0*AVG(CASE WHEN ea.experiment_group='B' THEN o.cancelled END),2)
FROM experiment_assignment ea
JOIN orders o
ON ea.user_id=o.user_id

)

SELECT
metric,

control,

treatment,

ROUND(treatment-control,2) AS absolute_lift,

ROUND(((treatment-control)/control)*100,2) AS relative_lift

FROM metrics;
