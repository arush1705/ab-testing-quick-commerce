# 🚀 A/B Testing in Quick Commerce
### Product Experiment: Free Delivery Progress Bar

## 📌 Overview

This project simulates an end-to-end Product A/B Testing experiment for a Quick Commerce platform (similar to Zepto, Blinkit, Instamart).

The objective was to evaluate whether introducing a **Free Delivery Progress Bar** during checkout encourages users to complete purchases and improves overall business performance.

---

# 📖 Business Problem

Users frequently abandon checkout before completing purchases.

The product team proposed introducing a **Free Delivery Progress Bar** that displays the remaining amount required to unlock free delivery.

### Existing Checkout

Delivery Fee: ₹40

↓

### Treatment Checkout

🚚 Add ₹65 more to unlock FREE DELIVERY


The hypothesis was that this feature would encourage customers to add more items to their cart, resulting in:

- Higher Conversion Rate
- Higher Revenue per User
- Higher Average Order Value
- Improved Profitability

without negatively affecting customer experience.

---

# 🎯 Business Objective

Evaluate whether the feature improves business performance while maintaining healthy guardrail metrics.

---

# 🧪 Experiment Design

| Experiment | A/B Test |
|------------|----------|
| Users | 10,000 |
| Control | Existing Checkout |
| Treatment | Free Delivery Progress Bar |
| Significance Level | 5% |
| Statistical Test | Two-Proportion Z-Test |

---

# 💡 Business Hypothesis

Displaying a Free Delivery Progress Bar encourages users to increase basket size and complete purchases, leading to improved business metrics.

---

# 📊 Statistical Hypothesis

### Null Hypothesis (H₀)

The feature has **no effect** on Conversion Rate.

```
H₀ : pA = pB
```

### Alternative Hypothesis (H₁)

The feature **changes** Conversion Rate.

```
H₁ : pA ≠ pB
```

---

# 🗂 Dataset

The experiment was conducted using six relational tables.

| Table |
|--------|
| users |
| sessions |
| cart_events |
| checkout_events |
| orders |
| experiment_assignment |

<img width="1917" height="1077" alt="schema" src="https://github.com/user-attachments/assets/f62a62a7-10a1-4d18-8262-f69ac4ca5472" />


---

# ✅ Data Validation

The following validation checks were performed before analysis.

- Row Count Validation
- NULL Value Checks
- Duplicate Checks
- Foreign Key Validation

<img width="1917" height="1077" alt="data_validation" src="https://github.com/user-attachments/assets/1ac8a8b1-bfee-493a-9273-956a151f5d51" />


---

# 🔀 Experiment Validation

The quality of experiment randomization was validated using SQL.

Checks performed:

- 50-50 User Split
- City Distribution
- Device Distribution
- User Type Distribution

Result:

✅ Experiment groups were well balanced, indicating successful randomization.

<img width="1918" height="1078" alt="experiment_validation" src="https://github.com/user-attachments/assets/9845098e-996b-4d46-89d6-76eef9a886d8" />


---

# 📈 Funnel Analysis

User Journey:

Assigned Users

↓

Sessions

↓

Cart

↓

Checkout

↓

Orders

The funnel was analyzed to identify user drop-offs between each stage.

<img width="1502" height="917" alt="funnel" src="https://github.com/user-attachments/assets/92f76986-5a36-4d79-bc87-0314d582701e" />


---

# 📊 Business Metrics

The following KPIs were analyzed using SQL.

- Conversion Rate
- Average Order Value
- Revenue per User
- Average Margin
- Cancellation Rate

---

# 📋 Experiment Results

| Metric | Control | Treatment | Absolute Lift | Relative Lift |
|--------|---------:|----------:|--------------:|--------------:|
| Conversion Rate | **56.63%** | **58.18%** | **+1.55 pp** | **+2.74%** |
| Revenue per User | ₹292.83 | ₹303.82 | +₹10.99 | +3.75% |
| Average Order Value | ₹324.00 | ₹322.17 | -₹1.83 | -0.56% |
| Average Margin | ₹58.32 | ₹57.99 | -₹0.33 | -0.57% |
| Cancellation Rate | **3.31%** | **2.96%** | **-0.35 pp** | **-10.57%** |

<img width="1918" height="1078" alt="kpis" src="https://github.com/user-attachments/assets/740146a4-fe41-4973-a308-0afa78bac554" />


---

# 📉 Statistical Significance

Python was used to perform a **Two-Proportion Z-Test**.

### Results

| Metric | Value |
|---------|------:|
| Z Statistic | **-1.57** |
| P-value | **0.116** |
| Significance Level | **0.05** |

Since

```
P-value > 0.05
```

we **Fail to Reject the Null Hypothesis.**

<img width="1216" height="546" alt="ztest" src="https://github.com/user-attachments/assets/d07d87ab-c487-474f-a5fb-695e25a7a30b" />


---

# 📌 Interpretation

Although the Treatment group achieved a higher Conversion Rate (**58.18%**) compared to the Control group (**56.63%**), the observed improvement was **not statistically significant**.

The increase could reasonably have occurred due to random variation.

---

# 💼 Business Recommendation

## ❌ Do Not Roll Out Yet

Although several business metrics improved,

- ✅ Higher Conversion Rate
- ✅ Higher Revenue per User
- ✅ Lower Cancellation Rate

the improvement in the primary metric was **not statistically significant**.

### Recommended Next Steps

- Increase sample size
- Extend experiment duration
- Perform city-level segmentation
- Analyze device-specific performance
- Monitor long-term business impact

---

# 🛠 Tools Used

- PostgreSQL
- SQL
- Python
- Microsoft Excel

---

# 📚 SQL Concepts Used

- CTEs
- JOINs
- Aggregate Functions
- Window Functions
- CASE Statements
- GROUP BY
- Subqueries
- Funnel Analysis
- KPI Analysis
- Lift Analysis

---

# 🐍 Python

- Two-Proportion Z-Test
- Hypothesis Testing
- Statistical Significance Testing


---

# ⭐ Key Learnings

Through this project I learned:

- Designing an end-to-end A/B experiment
- Validating experiment quality
- Product analytics using SQL
- Measuring business KPIs
- Performing statistical significance testing using Python
- Translating analytical findings into product recommendations
