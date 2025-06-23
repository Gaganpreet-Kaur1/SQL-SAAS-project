DevifyX MySQL Assignment - Subscription-Based SaaS Database

OVERVIEW
========
This project implements a complete MySQL database schema for a SaaS platform 
managing users, subscriptions, payments, usage tracking, and invoicing. The 
system supports multiple subscription plans with different billing cycles and 
comprehensive audit trails.

CORE FEATURES IMPLEMENTED (All 8 Required)
==========================================
✓ User Management - users table with status tracking (active/inactive/suspended)
✓ Subscription Plans - subscription_plans with 7 tiers (Starter, Pro, Business + Annual variants)
✓ User Subscriptions - user_subscriptions tracking plan assignments and date ranges
✓ Payment Tracking - payments supporting 4 payment methods with transaction status
✓ Usage Tracking - usage_tracking monitoring API calls and storage against plan limits
✓ Invoicing - invoices with tax calculation and billing cycle management
✓ Plan Changes - subscription_history audit trail for upgrades/downgrades/cancellations
✓ Failed Payments - failed_payments with retry logic and failure code tracking

BONUS FEATURES
==============
✓ Coupon System - coupons table with discount codes, usage limits, and expiration dates

DATABASE DESIGN
================
- Normalization: 3NF compliant with proper foreign key relationships
- Sample Data: 8 users, 7 subscription plans, 8 subscriptions, 8 payments, 8 invoices
- Constraints: Primary keys, foreign keys with CASCADE/SET NULL, unique constraints
- Indexes: Strategic indexing on email, status, dates, and foreign keys for performance

COMPLEX QUERIES IMPLEMENTED (5+)
=================================
1. Active Users with Subscriptions - Multi-table JOIN showing current active subscriptions
2. Usage Limit Violations - Users exceeding API/storage limits with plan comparison
3. Unpaid Invoices Report - Outstanding payments ordered by due date
4. Subscription Change History - Complete audit trail with LEFT JOINs for plan transitions
5. Failed Payment Analysis - Payment failures with retry scheduling and user details

KEY TECHNICAL DECISIONS
========================
- Data Types: DECIMAL(10,2) for currency, ENUM for status fields, TIMESTAMP for audit trails
- Billing: Monthly/yearly cycles with separate annual discount plans
- Usage Tracking: Daily granularity with unique constraints preventing duplicate records
- Payment Methods: credit_card, paypal, bank_transfer, stripe support
- Invoice Format: Unique numbering with date prefix (INV-YYYYMMDD-XXX)

SCHEMA RELATIONSHIPS
====================
users (1:M) user_subscriptions (M:1) subscription_plans
users (1:M) payments (1:M) failed_payments
users (1:M) invoices, usage_tracking, subscription_history

ASSUMPTIONS
===========
- Single active subscription per user at any time
- Daily usage tracking sufficient for monitoring
- Indian market focus (INR pricing, Indian names in sample data)
- Tax calculation included in invoicing (9% standard rate)
- Automatic retry for failed payments with configurable intervals

This implementation satisfies all DevifyX assignment requirements with comprehensive 
feature coverage, normalized database design, realistic sample data, and complex 
analytical queries.